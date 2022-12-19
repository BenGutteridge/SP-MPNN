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
conda info --
# echo $CONDA_DEFAULT_ENV
# conda list
# echo "Trying program"
# python3.9 check_torch.py
model=SP_RSUM_WEIGHT
L=8
d=128
rbar=1
k=10
task=-1
repeat=3
bs=128
epochs=300
use_neptune=False
neptune_name=JADE
python3.9 main.py -d QM9 -m "$model" --emb_dim "$d" --nb_reruns "$repeat" --mode gr --max_distance "$k" --num_layers "$L" --specific_task "$task" --rbar "$rbar" --batch_size "$bs" --epochs "$epochs" --use_neptune "$use_neptune" --neptune_name "$neptune_name"