import time
import configparser
import torch
import argparse
import os.path as osp
from utils import get_dataset, get_model
from experiments.run_gc import run_model_gc
from experiments.run_gc_ogb import run_model_gc_ogb
from experiments.run_gr import run_model_gr
import neptune.new as neptune

torch.autograd.set_detect_anomaly(True)

def str2bool(v):
    if v.lower() in ("yes", "true", "t", "y", "1"):
        return True
    elif v.lower() in ("no", "false", "f", "n", "0"):
        return False
    else:
        raise argparse.ArgumentTypeError("Boolean value expected.")


# Neptune configuration

# # doesn't work
# config = configparser.ConfigParser()
# config.read("config.ini")
# if config["DEFAULT"]["neptune_token"] and config["DEFAULT"]["neptune_token"] != "...":
#     neptune_client = neptune.init(
#         project=config["DEFAULT"]["neptune_project"],
#         api_token=config["DEFAULT"]["neptune_token"],
#     )
# else: # added - error
#     neptune_client = None

# CLI configuration
parser = argparse.ArgumentParser()
parser.add_argument(
    "-d", "--dataset", help="Dataset to test the model on.", required=True
)
parser.add_argument("-b", "--batch_size", help="Batch size.", default=32, type=int)
parser.add_argument("-m", "--model", help="The model we will use.", default="HSP-GIN")

# Training arguments
parser.add_argument("--lr", help="Learning rate.", default=0.001, type=float)

# Model specific arguments
parser.add_argument(
    "--max_distance", help="Maximal distance in HSP model (K)", default=5, type=int
)
parser.add_argument(
    "--num_layers", help="Number of HSP layers in the model.", default=1, type=int
)
parser.add_argument(
    "--emb_dim", help="Size of the emb dimension.", default=64, type=int
)
parser.add_argument("--scatter", help="Max or Mean pooling.", default="max")
parser.add_argument("--dropout", help="Dropout probability.", default=0.5, type=float)
parser.add_argument("--eps", help="Epsilon in GIN.", default=0.0, type=float)
parser.add_argument("--epochs", help="Number of epochs.", default=300, type=int)
parser.add_argument("--mode", help="Model mode - gc/gr.", default="gc")
parser.add_argument(
    "--pool_gc",
    help="Choose the mode-specific pool (default) or use GC pooling",
    type=str2bool,
    default=False,
)
parser.add_argument(
    "--batch_norm",
    help="Use batch norm within layer MLPs (default True)",
    type=str2bool,
    default=True,
)
parser.add_argument(
    "--layer_norm",
    help="Use layer norm after every message passing iteration (default False)",
    type=str2bool,
    default=True,
)
parser.add_argument(
    "--learnable_emb",
    help="(For synthetic experiments). Whether to set feature embeddings to be "
    "learnable (Default False)",
    type=str2bool,
    default=False,
)
parser.add_argument(
    "--specific_task",
    help="(For QM9) Run all tasks (-1, default) or a specific task by index",
    type=int,
    default=-1,
)
parser.add_argument(
    "--nb_reruns", help="(For QM9) Repeats per task (default 5)", type=int, default=5
)
parser.add_argument(
    "--res_freq",
    help="The layer interval for residual connections (default: -1, i.e., no residual)",
    type=int,
    default=-1,
)
parser.add_argument(
    "--use_feat",
    help="(OGBG). Whether to use all features (Default False)",
    type=str2bool,
    default=False,
)

parser.add_argument(
    "--use_neptune",
    help="(OGBG). Whether to use neptune logging (Default False)",
    type=str2bool,
    default=False,
)

parser.add_argument(
    "--neptune_name",
    help="Name of run on neptune",
    type=str,
    default="Untitled",
)

parser.add_argument(
    "--rbar",
    help="rbar",
    type=int,
    default=1,
)

####
my_args = [
    "-d QM9",
    "-m DeLite-SP_RSUM_WEIGHT", # outside and inside aggregations --  outside options are RSUM (R-SPN), ... [TODO: continue] if "[eps]_weight" uses alpha weightings convex comb of k-hops. If some form of sum, does (1+eps) followed by MLP I think
    # "-m Delay-SP_RSUM_WEIGHT",
    # "-m SP_RSUM_WEIGHT",
    "--max_distance 5",     # K, I think
    "--num_layers 8",
    "--specific_task 9",    # index for the regression target (0-12 for QM9) 
    "--mode gr",            # graph regression (QM9 only)
    "--epochs 300",
    "--batch_size 64",
    "--nb_reruns 3",        # number of times to repeat the experiment
    "--use_neptune False",
    "--neptune_name test_run",
    "--emb_dim 64",
]
my_args = ' '.join(my_args)
####
args = parser.parse_args(my_args.split())
if args.rbar == '-1':
    args.rbar = float('inf')

# works
neptune_client = None
if args.use_neptune:
    if torch.cuda.is_available():
        import neptune.new as neptune
        from config import neptune_token, neptune_project
        if neptune_token and neptune_token != "...":
            neptune_client = neptune.init_run(
                name=args.neptune_name,
                project=neptune_project,
                api_token=neptune_token)
        print("Using neptune_project '%s'" % neptune_project)
    else: print("Neptune not available on CPU")

# Add arguments to neptune
if neptune_client:
    neptune_client["parameters"] = vars(args)


BATCH = args.batch_size
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
root_dir = osp.join(osp.dirname(osp.realpath(__file__)), "..")

print('ARGS:\n', args)
print('Device: ', device)

if args.mode == "gc":  # Graph Classification
    dataset, second_return, ogb_metric = get_dataset(args, root_dir)
    if args.dataset in [
        "ogbg-molhiv",
        "ogbg-molpcba",
        "ogbg-moltox21",
        "ogbg-moltoxcast",
        "ogbg-molbbbp",
        "ogbg-molbace",
        "ogbg-molmuv",
        "ogbg-molclintox",
        "ogbg-molsider",
    ]:
        model = get_model(
            args,
            device,
            num_features=dataset.num_features,
            num_classes=dataset.num_tasks,
        )
        evaluator = second_return
        run_model_gc_ogb(
            model,
            dataset,
            dataset_name=args.dataset,
            evaluator=evaluator,
            device=device,
            lr=args.lr,
            batch_size=BATCH,
            epochs=args.epochs,
            neptune_client=neptune_client,
        )
    elif args.dataset == "ogbg-ppa":
        model = get_model(
            args,
            device,
            num_features=dataset.num_features,
            num_classes=dataset.num_classes,
        )
        evaluator = second_return
        run_model_gc_ogb(
            model,
            dataset,
            dataset_name=args.dataset,
            evaluator=evaluator,
            device=device,
            lr=args.lr,
            batch_size=BATCH,
            epochs=args.epochs,
            neptune_client=neptune_client,
        )
    else:
        model = get_model(
            args,
            device,
            num_features=dataset.num_features,
            num_classes=dataset.num_classes,
        )
        splits = second_return
        run_model_gc(
            model,
            dataset,
            splits,
            lr=args.lr,
            batch_size=BATCH,
            epochs=args.epochs,
            neptune_client=neptune_client,
        )
elif args.mode == "gr":  # Graph Regression, this is QM9
    dataset_tr, dataset_val, dataset_tst, num_feat, num_pred = get_dataset( # LOADS DATASET
        args, root_dir
    )  # Load the dataset (QM9)
    model = get_model( # LOADS MODEL
        args, device, num_features=num_feat, num_classes=1
    )  # You're only predicting one value per model
    nb_reruns = args.nb_reruns
    specific_task = args.specific_task
    num_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print('Number of parameters: ', num_params)
    if neptune_client:
        neptune_client["num_params"].log(num_params)
    run_model_gr(
        model=model,
        device=device,
        dataset_tr=dataset_tr,   # TRAINING DATASET
        dataset_val=dataset_val, # VALIDATION DATASET
        dataset_tst=dataset_tst,
        lr=args.lr,
        batch_size=BATCH,
        epochs=args.epochs,
        neptune_client=neptune_client,
        specific_task=specific_task,
        nb_reruns=nb_reruns,
    )

if neptune_client:
    neptune_client.stop()
    # Sleep for final neptune sync
    time.sleep(10)
