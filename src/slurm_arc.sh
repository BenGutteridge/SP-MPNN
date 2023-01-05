#! /bin/bash
#SBATCH --job-name=spn
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=12:00:00
#SBATCH --partition=short
# must be on htc, only one w/ GPUs
#SBATCH --clusters=htc
# set number of GPUs
#SBATCH --gres=gpu:1
cd $DATA/repos/SP-MPNN/src
module load Anaconda3
module load CUDA
source activate $DATA/spn
python -c "import torch; print(torch.__version__); print(torch.cuda.is_available())"
bash run_main.sh