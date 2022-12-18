#!/bin/bash

python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 0 --use_neptune True &
  python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 1 --use_neptune True &
  python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 2 --use_neptune True &
  python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 3 --use_neptune True &
  python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 4 --use_neptune True &
  python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 5 --use_neptune True &
  python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 6 --use_neptune True &
  python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 7 --use_neptune True &
  python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 8 --use_neptune True &
  python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 9 --use_neptune True &
  python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 10 --use_neptune True &
  python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 11 --use_neptune True &
  python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 12 --use_neptune True &
  python main.py -d QM9 -m Delay-SP_RSUM_WEIGHT --num_layers 8  --mode gr --nb_reruns 1 --specific_task 13 --use_neptune True

