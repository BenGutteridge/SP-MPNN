#! /bin/bash
#SBATCH --job-name=r*5s15
#SBATCH --nodes=1
# # SBATCH --ntasks-per-node=24
#SBATCH --time=72:00:00
#SBATCH --partition=small
# must be on htc, only one w/ GPUs
#SBATCH --gres=gpu:1
#SBATCH --ntasks-per-gpu=1
cd /jmain02/home/J2AD008/wga29/bxg10-wga29/SP-MPNN/src
module load cuda/10.2
module load python/anaconda3
source $condaDotFile
source activate spn
# nvcc --version
# python3.9 -c "import torch; print(torch.__version__); print(torch.cuda.is_available())"

# python3.9 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --rbar -1 --num_layers 10 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 78 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 15 --pool_gc True --run_id time_0116_1234
python3.9 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --rbar 5 --num_layers 10 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 78 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 15 --pool_gc True --run_id time_0116_1234
# python3.9 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --rbar 1 --num_layers 12 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 66 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 15 --pool_gc True --run_id time_0116_1234


# # sbatch --array=0-12 slurm_jade.sh