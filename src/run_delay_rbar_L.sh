# Run 'run_main.sh' script with 'task' flag set from 0 to 12


model="Delay-SP_RSUM_WEIGHT" # other options Delay-SP_RSUM_WEIGHT, DeLite-SP_RSUM_WEIGHT
use_neptune="True"
repeat=3

L=$2
bs=128 # 32 default, 128 in paper
epochs=300

rbar=$1

for task in {0..12}
do
  neptune_name="${model}_L=${L}_rbar=${rbar}_task=${task}"
  echo bash run_main.sh --model "$model" --repeat "$repeat" --L "$L" --rbar "$rbar" --task "$task" --bs "$bs" --epochs "$epochs" --use_neptune "$use_neptune" --neptune_name "$neptune_name"
done