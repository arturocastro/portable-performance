#!/bin/sh

sizes=(31 63 127 255 511 1023)

for s in "${sizes[@]}"
do
    echo $s
    if ! cmp -s out$s ../../../../previous_work/ocl4/results/out$s
    then
	./compare.py $s > abs_diff_$s
    fi
done
