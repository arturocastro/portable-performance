#!/bin/sh

REF_OUT_DIR=`pwd`

# Argument specific for computer: axle, mcore, arndale, etc...
cd $1

COUNTER=0

DATE=`date | sed 's/ /_/g'`

for D in `find . -type d -maxdepth 2 -mindepth 2`
do
    pushd $D

    make clean
    make &> /dev/null

    echo dir
    echo `pwd`

    mkdir results &> /dev/null

    let COUNTER=0

    while [ $COUNTER -lt $2 ]
    do
        # Get only diagonal information for scientific method correctness
        ./shallow | grep "computer time" >> results/$DATE
	let COUNTER+=1
    done

    popd
done