#! /bin/bash
#SBATCH --job-name=lrgbspn
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:10:00
#SBATCH --partition=devel
# must be on htc, only one w/ GPUs
#SBATCH --clusters=htc
# set number of GPUs
#SBATCH --gres=gpu:1

# cd $DATA/repos/SP-MPNN/src
cd $DATA/repos/lrgb
module load Anaconda3
module load CUDA
source activate $DATA/spn2
nvcc --version
python -c "import torch; print(torch.__version__); print(torch.cuda.is_available())"
# bash run_main.sh
# python pyg_gpu_checker.py
# python main.py -d QM9 -m SP_RSUM_WEIGHT --max_distance 3 --num_layers 5 --specific_task -1 --mode gr
python main.py --cfg configs/rbar-GCN/peptides-struct-DelayGCN+LapPE.yaml device cuda dataset.dir datasets rbar -1 gnn.layers_mp 3 optim.max_epoch 5 gnn.dim_inner 16