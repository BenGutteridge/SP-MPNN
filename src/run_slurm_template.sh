#!/bin/bash

# set the number of nodes
#SBATCH --nodes=1

# set max wallclock time
#SBATCH --time=36:00:00

# set name of job
#SBATCH --job-name=spntry

# set number of GPUs
#SBATCH --gres=gpu:1

# mail alert at start, end and abortion of execution
#SBATCH --mail-type=ALL

# send mail to this address
#SBATCH --mail-user=gutterboyben@gmail.com

# run the application
module load cuda/10.2
module load python/anaconda3
source $condaDotFile
conda activate spn
conda info --
echo "python3.9"
python3.9 -c "import torch; print(torch.__version__)"
# python3.9 run_main.py
# echo $CONDA_DEFAULT_ENV
# conda list
# bash slurm_bash.sh
python3.9 main.py -d QM9 -m SP_RSUM_WEIGHT --emb_dim 64 --nb_reruns 1 --mode gr --max_distance 10 --num_layers 8 --specific_task -1 --rbar 1 --batch_size 128 --epochs 300 --use_neptune False --neptune_name JADE
