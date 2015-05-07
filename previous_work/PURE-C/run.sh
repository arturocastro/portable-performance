#!/bin/sh

COUNTER=0

#DATE=`date | sed 's/ /_/g'`
DATE='initial'

sizes=(31 63 127 255 511) #1023)

mkdir timings/$DATE

for s in "${sizes[@]}"
do
    echo $s

    make clean -s
    make SIZE=$s -s
    
    let COUNTER=0

    while [ $COUNTER -lt $1 ]
    do
        # Get only diagonal information for scientific method correctness
        #./shallow_base | grep "computer time" | awk '{print $7}' >> timings/$DATE/time${s}_raw
	let COUNTER+=1
    done
    
    < timings/$DATE/time${s}_raw timings/stats.py > timings/$DATE/time$s

    < timings/$DATE/time$s awk -v size=$s '/Min/ { printf("%s %s ", size, $NF)} /Std/ { print $NF }' >> timings/$DATE/timeall
done