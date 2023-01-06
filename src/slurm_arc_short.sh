#! /bin/bash
#SBATCH --job-name=repro64
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
python main.py -d QM9 -m SP_RSUM_WEIGHT --max_distance 10 --num_layers 8 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 64 --batch_size 128 --epochs 500 --nb_reruns 5

# # sbatch --array=0-6 slurm_arc.sh