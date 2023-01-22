#! /bin/bash
#SBATCH --job-name=r4L8s
#SBATCH --nodes=1
# # SBATCH --ntasks-per-node=24
#SBATCH --time=24:00:00
#SBATCH --partition=big
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

python3.9 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --rbar -1 --num_layers 8 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 95 --batch_size 128 --epochs 300 --nb_reruns 1 --scatter mean --dropout 0.0 --layer_norm False --seed 2 --pool_gc True --run_id time_0118_0918
# # sbatch --array=0-12 slurm_jade_big.sh