#!/usr/bin/env Rscript

#library(Rmisc)
library(ggplot2)

#data <- file("stdin")
#open(f)

data <- read.table("stdin")

datac <- summarySE(data, measurevar = "V2", groupvars = "V1")

datac
