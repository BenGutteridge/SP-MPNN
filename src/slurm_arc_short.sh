#! /bin/bash
#SBATCH --job-name=r*inf_L9
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
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --rbar -1 --num_layers 9 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 86 --batch_size 144 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 5 --pool_gc True --slurm_id $SLURM_JOB_ID
# # sbatch --array=0-6 slurm_arc.sh