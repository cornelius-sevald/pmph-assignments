#!/bin/bash
set -euo pipefail

# Find the sweet-point array size where the CPU is about as fast as the GPU

# Make sure the project is compiled
make wa1-task3

# Lower and upper bounds to search through
# Assumes that sweet-point lies between these
lower=1
upper=1000000

while [ $lower -le $upper ]
do
    # Get the middle of the upper and lower bound
    mid=$(((lower+upper)/2))
    # Capture the runtime from the program
    { read -r cpu_time ; read -r gpu_time ; } < <(./wa1-task3 $mid | tail -n2 | awk -F' ' '{ print $3 }')
    # Use binary search to find the sweet-spot
    # Slightly biased to the higher end using `-le` instead of `-lt`
    if [ "$cpu_time" -le "$gpu_time" ]
    then
        lower=$((mid+1))
    else
        upper=$((mid-1))
    fi
done

printf "sweet-spot found at N=%d\n" $mid
