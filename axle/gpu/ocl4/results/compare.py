#!/usr/bin/python

import sys
import re

p = re.compile('[-+]?\d+')

list1 = []
list2 = []

with open('out' + sys.argv[1]) as f: 
    for line in f:
        if p.match(line):
            list1.append(line.split())

with open('../../../../previous_work/ocl4/results/out' + sys.argv[1]) as f: 
    for line in f:
        if p.match(line):
            list2.append(line.split())

for i in range(3):
    print [abs(float(x) - float(y)) for x,y in zip(list1[i], list2[i])]
