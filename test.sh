#!/bin/sh

REF_OUT_DIR=`pwd`

# Argument specific for computer: axle, mcore, arndale, etc...
cd $1

for D in `find . -type d -links 2`
do
    pushd $D

    make clean
    make &> /dev/null

    # Get only diagonal information for scientific method correctness
    ./shallow | grep -A1 diagonal > out

    cmp out $REF_OUT_DIR/ref_out

    popd
done