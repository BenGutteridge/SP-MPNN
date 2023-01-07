#! /bin/bash
#SBATCH --job-name=L13d62
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=12:00:00
#SBATCH --partition=short
# must be on htc, only one w/ GPUs
#SBATCH --clusters=htc
# set number of GPUs
#SBATCH --gres=gpu:1
#SBATCH --account=engs-oxnsg
cd $DATA/repos/my_SP-MPNN/src
module load Anaconda3
module load CUDA
source activate $DATA/spn2
nvcc --version
python -c "import torch; print(torch.__version__); print(torch.cuda.is_available())"
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --rbar 6 --num_layers 13 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 62 --batch_size 128 --epochs 500 --nb_reruns 5

# # sbatch --array=0-6 slurm_arc.sh