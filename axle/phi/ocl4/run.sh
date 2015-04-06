#!/bin/sh

COUNTER=0

DATE=`date | sed 's/ /_/g'`

sizes=(31 63 127 255 511 1023)

for s in "${sizes[@]}"
do
    echo $s

    make clean -s
    make SIZE=$s -f Makefile-intel -s

    mkdir timings/$DATE

    let COUNTER=0

    while [ $COUNTER -lt $1 ]
    do
        # Get only diagonal information for scientific method correctness
        ./shallow | grep "computer time" >> timings/$DATE/time$s
	let COUNTER+=1
    done
done