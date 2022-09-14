#!/bin/bash
set -euo pipefail

# Calculare the speedup of the parallel function over input size

# Make sure the project is compiled
make wa1-task3

# As far as we'll go
upper=8388608
# Initial size
N=512

printf "%s\t%s\n" "N" "speedup"

while [ $N -le $upper ]
do
    # Capture the runtime from the program
    { read -r cpu_time ; read -r gpu_time ; } < <(./wa1-task3 $N | tail -n2 | awk -F' ' '{ print $3 }')
    # Calculate the speedup
    speedup=$((cpu_time/gpu_time))
    printf "%d\t%d\n" "$N" "$speedup"
    # Double N
    N=$((N*2))
done
