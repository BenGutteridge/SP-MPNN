#! /bin/bash
#SBATCH --job-name=pray
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=12:00:00
#SBATCH --partition=short
# must be on htc, only one w/ GPUs
#SBATCH --clusters=htc
# set number of GPUs
#SBATCH --gres=gpu:1
cd $DATA/repos/my_SP-MPNN/src
module load Anaconda3
module load CUDA
source activate $DATA/spn2
nvcc --version
python -c "import torch; print(torch.__version__); print(torch.cuda.is_available())"
python main.py -d QM9 -m SP_RSUM_WEIGHT --max_distance 1 --num_layers 2 --specific_task -1 --mode gr --emb_dim 16 --batch_size 128 --epochs 2