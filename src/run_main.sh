#!/bin/bash

# Set default values for arguments
model="SP_RSUM_WEIGHT" # other options Delay-SP_RSUM_WEIGHT, DeLite-SP_RSUM_WEIGHT
L=8
k=10
d=128 # hidden dim, default in paper
rbar=1
task="-1"
repeat=3
bs=32
epochs=500
use_neptune="False"
neptune_name="Untitled"

# Parse command line arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --model)
    model="$2"
    shift # past argument
    shift # past value
    ;;
    --repeat)
    repeat="$2"
    shift # past argument
    shift # past value
    ;;
    --d)
    d="$2"
    shift # past argument
    shift # past value
    ;;
    --L)
    L="$2"
    shift # past argument
    shift # past value
    ;;
    --k)
    k="$2"
    shift # past argument
    shift # past value
    ;;
    --rbar)
    rbar="$2"
    shift # past argument
    shift # past value
    ;;
    --task)
    task="$2"
    shift # past argument
    shift # past value
    ;;
    --bs)
    bs="$2"
    shift # past argument
    shift # past value
    ;;
    --epochs)
    epochs="$2"
    shift # past argument
    shift # past value
    ;;
    --use_neptune)
    use_neptune="$2"
    shift # past argument
    shift # past value
    ;;
    --neptune_name)
    neptune_name="$2"
    shift # past argument
    shift # past value
    ;;
esac
done

echo "model: $model, repeat: $repeat, L: $L, k: $k, rbar: $rbar, task: $task, bs: $bs, epochs: $epochs, use_neptune: $use_neptune, neptune_name: $neptune_name" 

# Pass arguments to another script
python main.py -d QM9 -m "$model" --emb_dim "$d" --nb_reruns "$repeat" --mode gr --max_distance "$k" --num_layers "$L" --specific_task "$task" --rbar "$rbar" --batch_size "$bs" --epochs "$epochs" --use_neptune "$use_neptune" --neptune_name "$neptune_name"