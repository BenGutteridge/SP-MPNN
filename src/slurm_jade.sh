#! /bin/bash
#SBATCH --job-name=spn
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24
#SBATCH --time=00:20:00
#SBATCH --partition=devel
# must be on htc, only one w/ GPUs
#SBATCH --gres=gpu:1
#SBATCH --ntasks-per-gpu=2
cd /jmain02/home/J2AD008/wga29/bxg10-wga29/SP-MPNN/src
module load cuda/10.2
module load python/anaconda3
source $condaDotFile
source activate spn
# nvcc --version
# python3.9 -c "import torch; print(torch.__version__); print(torch.cuda.is_available())"
python3.9 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --max_distance 1 --num_layers 2 --specific_task -1 --mode gr --emb_dim 16 --batch_size 128 --epochs 2 --nb_reruns 1 &
  python3.9 main.py -d QM9 -m SP_RSUM_WEIGHT --max_distance 1 --num_layers 2 --specific_task -1 --mode gr --emb_dim 16 --batch_size 128 --epochs 2 --nb_reruns 1