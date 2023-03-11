#! /bin/bash
#SBATCH --job-name=r*infL12
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --partition=long
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
# python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --nu -1 --num_layers 8 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 95 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 1 --pool_gc True --run_id "time_0115_1000"
# python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --nu -1 --num_layers 8 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 95 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 2 --pool_gc True --run_id "time_0115_1000"
# python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --nu -1 --num_layers 10 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 78 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 0 --pool_gc True --run_id "time_0115_1000"
# python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --nu -1 --num_layers 10 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 78 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 1 --pool_gc True --run_id "time_0115_1000"
# python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --nu -1 --num_layers 10 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 78 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 2 --pool_gc True --run_id "time_0115_1000"
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --nu -1 --num_layers 12 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 66 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 0 --pool_gc True --run_id "time_0115_1000"
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --nu -1 --num_layers 12 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 66 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 2 --pool_gc True --run_id "time_0115_1000"
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --nu -1 --num_layers 12 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 66 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 1 --pool_gc True --run_id "time_0115_1000"

# # sbatch --array=0-12 slurm_arc_long.sh