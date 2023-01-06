#! /bin/bash
#SBATCH --job-name=spn_smol
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=06:00:00
#SBATCH --partition=short
#SBATCH --clusters=htc
#SBATCH --gres=gpu:1
#SBATCH --verbose

cd $DATA/repos/my_SP-MPNN/src
module load Anaconda3
module load CUDA
source activate $DATA/spn2
nvcc --version
python -c "import torch; print(torch.__version__); print(torch.cuda.is_available())"
# python main.py -d QM9 -m SP_RSUM_WEIGHT --max_distance 3 --num_layers 5 --specific_task -1 --mode gr
# python main.py -d QM9 -m SP_RSUM_WEIGHT --max_distance 10 --num_layers 8 --specific_task -1 --mode gr --emb_dim 128 --batch_size 128
python main.py -d QM9 -m SP_RSUM_WEIGHT --max_distance 1 --num_layers 2 --specific_task 0 --mode gr --emb_dim 16 --batch_size 128