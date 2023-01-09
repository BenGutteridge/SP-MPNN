#! /bin/bash
#SBATCH --job-name=spn_repro
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
python3.9 main.py -d QM9 -m SP_RSUM_WEIGHT --max_distance 10 --num_layers 8 --specific_task $SLURM_ARRAY_TASK_ID --mode gr --emb_dim 128 --batch_size 128 --epochs 300 --nb_reruns 3 --scatter mean --dropout 0.0 --layer_norm False --seed 0 --pool_gc True

# # sbatch --array=0-12 slurm_jade_big.sh