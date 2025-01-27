#! /bin/bash
#SBATCH --job-name=spn_L=10,12
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
python main.py -d QM9 -m SP_RSUM_WEIGHT --max_distance 10 --num_layers 10 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 114 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 0 --pool_gc True --run_id kermit
python main.py -d QM9 -m SP_RSUM_WEIGHT --max_distance 10 --num_layers 12 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 104 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 0 --pool_gc True --run_id kermit
python main.py -d QM9 -m SP_RSUM_WEIGHT --max_distance 10 --num_layers 10 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 114 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 1 --pool_gc True --run_id kermit
python main.py -d QM9 -m SP_RSUM_WEIGHT --max_distance 10 --num_layers 12 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 104 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 1 --pool_gc True --run_id kermit
# # sbatch --array=0-12 slurm_arc_medium.sh