#!/bin/bash

# set the number of nodes
#SBATCH --nodes=1

# set max wallclock time
#SBATCH --time=36:00:00

# set name of job
#SBATCH --job-name=jade_qm9_rbars

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
echo $CONDA_DEFAULT_ENV
# conda list
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 0 &
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 1 &
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 2 &
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 3 &
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 4 &
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 5 &
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 6 &
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 7 &
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 8 &
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 9 &
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 10 &
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 11 &
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 12 &
python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 13


