import torch
from torch.nn import MultiheadAttention
from torch.nn import Linear, ReLU, BatchNorm1d
from torch.nn import ModuleList, Sequential, Embedding
from torch_geometric.utils import to_dense_adj
import torch.nn.functional as F
from torch_scatter import scatter_mean
from .hsp_gin_layer import instantiate_mlp

avail_device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

class DRew_GIN_Layer(torch.nn.Module):
    def __init__(
        self,
        t,
        nu,
        in_channels,
        out_channels,
        max_distance,
        eps=0.0,
        inside_aggr="sum",
        outside_aggr="weight",
        nhead=8,
        nb_edge_types=1,
        batch_norm=True,
        edgesum_relu=True,
        dataset=None,
        device=avail_device,
    ):
        """
        :param in_channels: Dimension size of input. We denote this by I.
        :param out_channels: Dimension size of output: We denote this by O.
        :param max_distance: Maximal shortest distance we're considering.
                             By K we will denote max_distance + 1, so that we
                             take into account the node itself (i.e. distance = 0).
        :param eps: The epsilon value used by GIN
        :param inside_aggr: The aggregation function used inside every hop
        :param outside_aggr: The overall aggregation function used to combine all hop representations
        :param nhead: (For attention outside agg) The number of attention heads
        :param batch_norm: A Boolean specifying whether batch norm is used inside the model MLPs
        """
        super(DRew_GIN_Layer, self).__init__()

        self.in_channels = in_channels
        self.out_channels = out_channels
        self.max_distance = max_distance
        self.nb_edge_types = nb_edge_types
        self.dataset = dataset
        self.nu = nu

        # The aggregation function of the neighbours on each level
        if (
            inside_aggr[0] == "r"
        ):  # Using a ``relational'' variant. Define the necessary MLPs
            # Keep the dimensionality constant inside, prior to applying the final MLP
            self.loop_mlp = instantiate_mlp(
                in_channels=in_channels,
                out_channels=in_channels,
                device=device,
                final_activation=False,
                batch_norm=batch_norm,
            )
            self.rel_mlps = ModuleList(
                [
                    instantiate_mlp(
                        in_channels=in_channels,
                        out_channels=in_channels,
                        device=device,
                        final_activation=False,
                        batch_norm=batch_norm,
                    )
                    for i in range(nb_edge_types)
                ]
            )
            higher_hop_mlps = []
            for k in range(2, t+2):
                higher_hop_mlps.append(
                    instantiate_mlp(
                        in_channels=in_channels,
                        out_channels=in_channels,
                        device=device,
                        final_activation=False,
                        batch_norm=batch_norm,
                    )
                )
            self.higher_hop_mlps = ModuleList(higher_hop_mlps)
        if inside_aggr != "rsum":
            self.gin_mlp = instantiate_mlp(
                in_channels=in_channels,
                out_channels=out_channels,
                device=device,
                final_activation=True,
                batch_norm=batch_norm,
            )

        self.edgesum_relu = edgesum_relu
        self.eps_val = eps
        self.eps = eps
        self.device = device

        self.inside_aggr = inside_aggr
        if inside_aggr == "attn_nh":
            self.hop_level_attn = ModuleList(
                [
                    MultiheadAttention(
                        embed_dim=self.in_channels, num_heads=nhead, batch_first=True
                    ).to(device)
                    for _ in range(self.max_distance)
                ]
            )
        elif inside_aggr == "global_attn_nh":
            self.hop_level_attn = ModuleList(
                [
                    MultiheadAttention(
                        embed_dim=self.in_channels, num_heads=nhead, batch_first=True
                    ).to(device)
                    for _ in range(self.max_distance)
                ]
            )

        if self.dataset and self.dataset in [
            "MUV",
            "HIV",
            "BACE",
            "BBBP",
            "Tox21",
            "ToxCast",
            "SIDER",
            "ClinTox",
        ]:
            self.bond_embedding = Embedding(5, in_channels)
            self.direction_embedding = Embedding(3, in_channels)

        self.outside_aggr = outside_aggr
        if outside_aggr in ["weight", "eps_weight"]:
            self.hop_coef = torch.nn.Parameter( # alpha_k weights for each k-hop - variable length depending on t
                torch.randn(t+1).to(device), requires_grad=True 
            )
            if outside_aggr == "eps_weight":
                self.eps = torch.nn.Parameter(
                    torch.randn(1).to(device), requires_grad=True
                )

    def forward(
        self,
        t,
        node_embeddings,
        edge_index,
        edge_weights,
        batch=None,
        edge_attr=None,
        direct_edge_embs=None,
    ):
        """
        :param node_embeddings: A FloatTensor of shape [num_layers, N, In_dim]
        :param edge_index: A LongTensor of shape [2, #Edges]
        :param edge_weights: The weights by SP_length
        :param batch: The batch size
        :param edge_attr: (For multi-relational graphs [B: graphs with edge types]) The edge types for [B: unfinished]
        :param direct_edge_embs: (For OGBG datasets), edge attributes that are summed with node attributes
        (then passed through ReLU).
        :return: A forward propagation of the input through the HSP layer
        """
        node_embedding_t = node_embeddings[t]  # The embeddings at the current layer
        if self.dataset and self.dataset in [
            "MUV",
            "HIV",
            "BACE",
            "BBBP",
            "Tox21",
            "ToxCast",
            "SIDER",
            "ClinTox",
        ]:  # Refactor
            direct_edge_attr = edge_attr[
                edge_weights == 1, :
            ]  # Fetch the direct edge attributes
            direct_edge_embs = self.bond_embedding(
                direct_edge_attr[:, 0]
            ) + self.direction_embedding(direct_edge_attr[:, 1])

        nb_nodes = node_embedding_t.size(0)  # Number of nodes
        unsq_node_embeddings = node_embedding_t.unsqueeze(
            0
        )  # Unsqueezed embeddings, shape [1, N, In_Dim] # unused I think
        if self.inside_aggr == "sum":
            by_hop_aggregates = torch.zeros(
                size=(self.max_distance, nb_nodes, self.in_channels), dtype=torch.float
            ).to(
                self.device
            )  # A [K, N, I] tensor
            for d in range(1, self.max_distance + 1):
                edges = edge_index.T[edge_weights == d].T  # Fetch the edges
                if edges.numel() != 0:
                    values = torch.ones(edges.shape[1], dtype=torch.float).to(
                        self.device
                    )
                    sparse_adjacency_d = torch.sparse_coo_tensor(
                        edges, values, (nb_nodes, nb_nodes)
                    )  # [N,N] SpTensor
                    by_hop_aggregates[d - 1, :, :] = torch.sparse.mm(
                        sparse_adjacency_d, node_embeddings
                    )
        elif (
            self.inside_aggr == "edgesum"
        ):  # Summing while accounting for edge attributes (OGBG datasets)
            if direct_edge_embs is not None:
                by_hop_aggregates = torch.zeros(
                    size=(self.max_distance, nb_nodes, self.in_channels),
                    dtype=torch.float,
                ).to(
                    self.device
                )  # A [K, N, I] tensor
                edges_direct = edge_index.T[
                    edge_weights == 1
                ].T  # Fetch the direct edges

                # K=1: Like OGB, sum node and edge attr, then apply a ReLU
                if edges_direct.numel() != 0:
                    # Link nodes to edges
                    nb_edges = edges_direct.shape[1]
                    edge_links = torch.cat(
                        (
                            edges_direct[0:1, :],
                            torch.arange(nb_edges).unsqueeze(0).to(self.device),
                        ),
                        dim=0,
                    )
                    values = torch.ones(edges_direct.shape[1], dtype=torch.float).to(
                        self.device
                    )
                    sparse_edge_adjacency = torch.sparse_coo_tensor(
                        edge_links, values, (nb_nodes, nb_edges)
                    )
                    destination_node_embeddings = node_embeddings[
                        edges_direct[1, :]
                    ]  # [nb_edges, d]

                    messages = destination_node_embeddings + direct_edge_embs
                    if self.edgesum_relu:
                        messages = torch.relu(messages)

                    by_hop_aggregates[0, :, :] = torch.sparse.mm(
                        sparse_edge_adjacency, messages
                    )

                # Now K=2 and above as standard
                for d in range(2, self.max_distance + 1):
                    edges = edge_index.T[edge_weights == d].T  # Fetch the edges
                    if edges.numel() != 0:
                        values = torch.ones(edges.shape[1], dtype=torch.float).to(
                            self.device
                        )
                        sparse_adjacency_d = torch.sparse_coo_tensor(
                            edges, values, (nb_nodes, nb_nodes)
                        )  # [N,N] SpTensor
                        by_hop_aggregates[d - 1, :, :] = torch.sparse.mm(
                            sparse_adjacency_d, node_embeddings
                        )
            else:
                raise AttributeError("Edge Embeddings not provided")

        elif self.inside_aggr == "rsum": # ************************* R-SPN on QM9 *************************
            assert edge_attr is not None
            by_hop_aggregates = torch.zeros(
                size=(t+1, nb_nodes, self.in_channels), dtype=torch.float
            ).to(
                self.device
            )
            if self.nb_edge_types > 1: # if there are multiple edge types given
                for t in range(self.nb_edge_types):
                    edges_direct_t = edge_index.T[ # EDGE_WEIGHTS: num hops (0 for self-loop), EDGE_ATTR: edge type (0 is both an edge type and the default for k!=1 edges)
                        torch.logical_and(edge_weights == 1, edge_attr == t) # extracts the *1-hop* edges of type t (is ~98% of the edges)
                    ].T 
                    if edges_direct_t.numel() != 0: # if there are 1-hop edges of the specified type
                        values = torch.ones(edges_direct_t.shape[1], dtype=torch.float).to(
                            self.device
                        )
                        transformed_node_emb = self.rel_mlps[t](node_embedding_t) # applies Rel- MLP
                        sparse_adjacency_t = torch.sparse_coo_tensor( # looks like a matrix of all 1s but .dense() shows it is just the adj matrix made from edges_direct_t
                            edges_direct_t, values, (nb_nodes, nb_nodes)
                        )
                        by_hop_aggregates[0, :, :] += torch.sparse.mm( # kth hop aggregation is in by_hop_aggregates[k-1]. 0-hop (self loop) not in by_hop_aggregates 
                            sparse_adjacency_t, transformed_node_emb # SUM{h_j}
                        )  # Add
            else: # if we don't want to use R-GIN
                edges_direct_t = edge_index.T[edge_weights == 1].T # using all edge types
                if edges_direct_t.numel() != 0: # if there are 1-hop edges of the specified type
                    values = torch.ones(edges_direct_t.shape[1], dtype=torch.float).to(
                        self.device
                    )
                    transformed_node_emb = self.rel_mlps[0](node_embedding_t) # applies Rel- MLP
                    sparse_adjacency_t = torch.sparse_coo_tensor( # looks like a matrix of all 1s but .dense() shows it is just the adj matrix made from edges_direct_t
                        edges_direct_t, values, (nb_nodes, nb_nodes)
                    )
                    by_hop_aggregates[0, :, :] += torch.sparse.mm( # kth hop aggregation is in by_hop_aggregates[k-1]. 0-hop (self loop) not in by_hop_aggregates 
                        sparse_adjacency_t, transformed_node_emb # SUM{h_j}
                    )  # Add            # Second step: k>=2, just like before
            higher_hop_mlp = lambda k: self.higher_hop_mlps[k-2] # k=2 is the 1st MLP in higher_hop_mlp
            for k in range(2, t + 2):
                edges = edge_index.T[edge_weights == k].T  # Fetch the edges
                if edges.numel() != 0:
                    values = torch.ones(edges.shape[1], dtype=torch.float).to(
                        self.device
                    )
                    sparse_adjacency_k = torch.sparse_coo_tensor(
                        edges, values, (nb_nodes, nb_nodes)
                    )  # [N,N] SpTensor
                    delay = int(max(0, k - self.nu))
                    by_hop_aggregates[k - 1, :, :] = torch.sparse.mm(
                        sparse_adjacency_k, 
                        higher_hop_mlp(k)(node_embeddings[t-delay])
                    )
        else:
            hops__K_N_N = torch.zeros(
                size=(self.max_distance, nb_nodes, nb_nodes), dtype=torch.float
            ).to(self.device)
            for d in range(1, self.max_distance + 1):
                edges = edge_index.T[edge_weights == d].T
                if edges.numel() != 0:
                    hops__K_N_N[d - 1] = to_dense_adj(edges, max_num_nodes=nb_nodes)[0]

        if self.inside_aggr == "attn_nh":
            by_hop_aggregates = torch.zeros(
                size=(self.max_distance, nb_nodes, self.in_channels), dtype=torch.float
            ).to(self.device)
            for d, attn_layer in enumerate(self.hop_level_attn):
                # Torch standard attention returns nan, when there are no neighbours.
                # As we use attention as a generalisation of sum, the value of the embedding should be 0 in this case.
                nan_inverse_node_mask = hops__K_N_N[d].sum(axis=1) != 0
                if nan_inverse_node_mask.sum() == 0:
                    continue  # Skip if the attn mask is empty

                nodes_for_attn = unsq_node_embeddings[:, nan_inverse_node_mask, :]
                attn_mask = (
                    hops__K_N_N[d, nan_inverse_node_mask, :][:, nan_inverse_node_mask]
                    < 1
                )
                if self.inside_aggr == "attn_nh":
                    query = nodes_for_attn
                elif self.inside_aggr == "global_attn_nh":
                    pooled = scatter_mean(node_embeddings, batch, dim=0).to(self.device)
                    mean_emb__N_I = pooled[batch]
                    query = mean_emb__N_I[nan_inverse_node_mask].unsqueeze(0)

                after_attn__1_N_I, _ = attn_layer(
                    query, nodes_for_attn, nodes_for_attn, attn_mask=attn_mask
                )
                by_hop_aggregates[d, nan_inverse_node_mask, :] = after_attn__1_N_I[0]

        if self.outside_aggr in ["eps_weight", "weight"]:
            overall_hop_aggr = (
                (by_hop_aggregates.T * F.softmax(self.hop_coef, dim=0)) # *** performs the alpha weighted convex combination of the k-hop aggregations ***
                .T.sum(axis=0)
                .to(self.device)
            )
        elif self.outside_aggr == "sum":
            overall_hop_aggr = by_hop_aggregates.sum(axis=0).to(
                self.device
            )  # overall_hop_aggr is [N, In]

        if self.inside_aggr != "rsum": 
            out_embeddings = self.gin_mlp(
                (self.eps + 1) * node_embedding_t.to(self.device) + overall_hop_aggr # last bit of layer: MLP((1+eps)*[self_loops] + [all-hop-aggs])
            )
        else:  
            out_embeddings = (self.eps + 1) * self.loop_mlp(node_embedding_t)#.to(self.device) # MLP here over self loops only, not sum of self and k-hop aggs
            out_embeddings += + overall_hop_aggr

        return out_embeddings

    def reset_parameters(self):
        for (name, module) in self._modules.items():
            if hasattr(module, "reset_parameters"):
                module.reset_parameters()
        if self.inside_aggr != "rsum":
            for x in self.gin_mlp:
                if hasattr(x, "reset_parameters"):
                    x.reset_parameters()
        if self.inside_aggr[0] == "r":  # Relational model
            for mlp in self.rel_mlps:
                for x in mlp:
                    if hasattr(x, "reset_parameters"):
                        x.reset_parameters()
            for x in self.loop_mlp:
                if hasattr(x, "reset_parameters"):
                    x.reset_parameters()

        if self.outside_aggr in ["weight", "eps_weight"]:
            torch.nn.init.normal_(self.hop_coef.data)
            if self.outside_aggr == "eps_weight":
                torch.nn.init.normal_(self.eps.data, mean=self.eps_val)

        if self.inside_aggr == "attn_nh":
            for module in self.hop_level_attn:
                for child in module.children():
                    child.reset_parameters()
