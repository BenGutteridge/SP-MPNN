#! /bin/bash
#SBATCH --job-name=rinf
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=48:00:00
#SBATCH --partition=medium
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
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --rbar -1 --num_layers 10 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 64 --batch_size 256 --epochs 500 --nb_reruns 5

# # sbatch --array=0-6 slurm_arc.sh