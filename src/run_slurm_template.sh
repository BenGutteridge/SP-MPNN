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
echo $CONDA_DEFAULT_ENV
conda list
conda install pytorch==1.12.1 torchvision==0.13.1 torchaudio==0.12.1 cudatoolkit=10.2 -c pytorch
python3 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 0 --use_neptune True &
  python3 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 1 --use_neptune True &
  python3 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 2 --use_neptune True &
  python3 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 3 --use_neptune True &
  python3 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 4 --use_neptune True &
  python3 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 5 --use_neptune True &
  python3 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 6 --use_neptune True &
  python3 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 7 --use_neptune True &
  python3 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 8 --use_neptune True &
  python3 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 9 --use_neptune True &
  python3 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 10 --use_neptune True &
  python3 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 11 --use_neptune True &
  python3 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 12 --use_neptune True &
  python3 main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 13 --use_neptune True


