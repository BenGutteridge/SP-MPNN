#!/bin/bash
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