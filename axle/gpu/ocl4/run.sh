#!/bin/sh

COUNTER=0
i=0

DATE=`date | sed 's/ /_/g'`

sizes=(31 63 127 255 511) #1023)

len=13

m_block_lens=(16 16 16 32 32 32 64 64 64 128 128 256 16)
n_block_lens=(4  8  16 2  4  8  1  2  4  1   2   1   32)

mkdir timings/$DATE

for s in "${sizes[@]}"
do
    echo $s

    let i=0

    while ((i<len))
    do
	make clean -s
	make SIZE=$s M_BLOCK_LEN=${m_block_lens[i]} N_BLOCK_LEN=${n_block_lens[i]} -f Makefile-intel -s
	
	let COUNTER=0

	#mkdir timings/$DATE/${m_block_lens[i]}_${n_block_lens[i]} &> /dev/null
	
	while [ $COUNTER -lt $1 ]
	do
            # Get only diagonal information for scientific method correctness
            #./shallow | grep "computer time" | awk '{print $7}' >> timings/$DATE/${m_block_lens[i]}_${n_block_lens[i]}/time${s}_raw
            ./shallow | grep "computer time" | awk -v s="$s" -v a="${m_block_lens[i]}x${n_block_lens[i]}" '{ print s,a,$7 }' >> timings/$DATE/time
	    let COUNTER+=1
	done
	
	#< timings/$DATE/${m_block_lens[i]}_${n_block_lens[i]}/time${s}_raw timings/stats.py > timings/$DATE/${m_block_lens[i]}_${n_block_lens[i]}/time$s
	
	let i++
    done
done
