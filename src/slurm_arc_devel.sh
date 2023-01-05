#! /bin/bash
#SBATCH --job-name=test_lrgb
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:30:00
#SBATCH --partition=devel
# must be on htc, only one w/ GPUs
#SBATCH --clusters=htc
# set number of GPUs
#SBATCH --gres=gpu:1
cd $DATA/repos/SP-MPNN/src
module load Anaconda3
module load CUDA/11.3
source activate $DATA/spn
python -c "import torch; print(torch.__version__); print(torch.cuda.is_available())"
bash run_main.sh