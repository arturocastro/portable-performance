#!/bin/sh

sizes=(31 63 127 255 511 1023)

for s in "${sizes[@]}"
do
    echo $s
    cmp out$s ../../../../previous_work/ocl4/results/out$s
done