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
conda activate lrgb2
module load cuda/10.2
conda info --
echo $CONDA_DEFAULT_ENV
conda list
module load cuda/10.2
bash run_main.sh --model DeLite-SP_RSUM_WEIGHT --repeat 3 --L 8 --rbar 1 --task 0 --bs 128 --d 64 --epochs 300 --use_neptune True --neptune_name DeLite-SP_RSUM_WEIGHT_L=8_rbar=1_task=0


