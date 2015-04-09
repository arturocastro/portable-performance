#!/usr/bin/python

import sys
import numpy as np

arr = np.loadtxt(sys.stdin)

print("Mean = {0}\nMin = {1}\nMax = {2}\nStd = {3}".format(arr.mean(), arr.min(), arr.max(), arr.std()))
