from models import NetHSP_GIN, NetHSP_Delay_GIN, NetGIN, NetGCN, NetGAT


def get_model(args, device="cpu", num_features=None, num_classes=None):
    if args.model == "GIN":
        emb_sizes = [args.emb_dim] * (args.num_layers + 1)
        if args.dataset.endswith("Prox"):
            emb_input = 10
        else:
            emb_input = -1
        model = NetGIN(
            num_features,
            num_classes,
            emb_sizes=emb_sizes,
            device=device,
            scatter=args.scatter,
            drpt_prob=args.dropout,
            eps=args.eps,
            train_eps=False,
            emb_input=emb_input,
        )
        return model
    elif args.model == "GIN-EPS":
        if args.dataset.endswith("Prox"):
            emb_input = 10  # The number of colors in the proximity dataset
        else:
            emb_input = -1
        emb_sizes = [args.emb_dim] * (args.num_layers + 1)
        model = NetGIN(
            num_features,
            num_classes,
            emb_sizes=emb_sizes,
            device=device,
            scatter=args.scatter,
            drpt_prob=args.dropout,
            eps=args.eps,
            train_eps=True,
            emb_input=emb_input,
        )
        return model
    elif args.model == "GCN":
        if args.dataset.endswith("Prox"):
            emb_input = 10
        else:
            emb_input = -1
        emb_sizes = [args.emb_dim] * (args.num_layers + 1)
        model = NetGCN(
            num_features,
            num_classes,
            emb_sizes=emb_sizes,
            device=device,
            scatter=args.scatter,
            drpt_prob=args.dropout,
            emb_input=emb_input,
        )
        return model

    elif args.model == "GAT":
        if args.dataset.endswith("Prox"):
            emb_input = 10
        else:
            emb_input = -1
        emb_sizes = [args.emb_dim] * (args.num_layers + 1)
        model = NetGAT(
            num_features,
            num_classes,
            emb_sizes=emb_sizes,
            device=device,
            scatter=args.scatter,
            drpt_prob=args.dropout,
            emb_input=emb_input,
        )
        return model

    model_type, inside, outside = args.model.lower().split("_")

    if not inside in ["attn_nh", "global_attn_nh", "sum", "rsum", "edgesum"]: # TODO what do these mean?
        raise ValueError("Invalid inside model aggregation.")

    if not outside in ["sum", "weight", "eps_weight"]: # TODO what do these mean?
        raise ValueError("Invalid outside model aggregation.")

    emb_sizes = [args.emb_dim] * (args.num_layers + 1)
    if args.dataset.startswith("ogbg"):
        ogb_gc = args.dataset
    else:
        ogb_gc = None

    # ******************************************************************************************
    # Delay-R-SPN
    if model_type == 'delay-sp' or model_type=='delite-sp':
        if model_type.startswith('delite'):
            print('Using Delite-R-SPN model')
            use_lite_model = True
        else:
            use_lite_model = False
            print('Using Delay-R-SPN model')

        model = NetHSP_Delay_GIN( # generic model with all of their own stuff implemented in it
            args.nu,
            num_features,
            num_classes,
            emb_sizes=emb_sizes, # list of length n_layers+1 with hidden dims I think
            device=device,
            max_distance=args.max_distance,
            scatter=args.scatter,
            drpt_prob=args.dropout,
            inside_aggr=inside,
            outside_aggr=outside,
            mode=args.mode,
            eps=args.eps,
            ogb_gc=ogb_gc,
            batch_norm=args.batch_norm,
            layer_norm=args.layer_norm,
            pool_gc=args.pool_gc,
            residual_frequency=args.res_freq,
            dataset=args.dataset,
            learnable_emb=args.learnable_emb,
            use_feat=args.use_feat,
            use_lite_model=use_lite_model,
        ).to(device)
    # ******************************************************************************************
    else:
        print("Model type is %s, defaulting to NetHSP_GIN" % args.model)
        model = NetHSP_GIN( # generic model with all of their own stuff implemented in it
            num_features,
            num_classes,
            emb_sizes=emb_sizes, # list of length n_layers+1 with hidden dims I think
            device=device,
            max_distance=args.max_distance,
            scatter=args.scatter,
            drpt_prob=args.dropout,
            inside_aggr=inside,
            outside_aggr=outside,
            mode=args.mode,
            eps=args.eps,
            ogb_gc=ogb_gc,
            batch_norm=args.batch_norm,
            layer_norm=args.layer_norm,
            pool_gc=args.pool_gc,
            residual_frequency=args.res_freq,
            dataset=args.dataset,
            learnable_emb=args.learnable_emb,
            use_feat=args.use_feat,
        ).to(device)
    return model
