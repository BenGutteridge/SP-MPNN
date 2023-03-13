#!/bin/bash
model=SP_RSUM_WEIGHT
L=8
d=128
nu=1
k=10
task=-1
repeat=3
bs=128
epochs=300
use_neptune=False
neptune_name=JADE
python3.9 main.py -d QM9 -m "$model" --emb_dim "$d" --nb_reruns "$repeat" --mode gr --max_distance "$k" --num_layers "$L" --specific_task "$task" --nu "$nu" --batch_size "$bs" --epochs "$epochs" --use_neptune "$use_neptune" --neptune_name "$neptune_name"

python3.9 main.py -d QM9 -m SP_RSUM_WEIGHT --emb_dim 64 --nb_reruns 1 --mode gr --max_distance 10 --num_layers 8 --specific_task 0 --nu 1 --batch_size 128 --epochs 10 --use_neptune False --neptune_name JADE