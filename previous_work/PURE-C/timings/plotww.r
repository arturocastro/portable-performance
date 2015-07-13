library("Rmisc")
library("ggplot2")

data <- read.table("time")

data$V3 <- 1 / data$V3

datac <- summarySE(data, measurevar="V3", groupvars=c("V1", "V2"))

datac$V2 = factor(datac$V2)

datac[1,4] <- min(data[1:10, 3])
datac[2,4] <- min(data[11:20, 3])
datac[3,4] <- min(data[21:30, 3])
datac[4,4] <- min(data[31:40, 3])
datac[5,4] <- min(data[41:50, 3])
datac[6,4] <- min(data[51:60, 3])
datac[7,4] <- min(data[61:70, 3])
datac[8,4] <- min(data[71:80, 3])
datac[9,4] <- min(data[81:90, 3])
datac[10,4] <- min(data[91:100, 3])

print(ggplot(datac, aes(x=V2, y=V3, fill=V1)) + 
    geom_bar(position=position_dodge(), stat="identity",
             colour="black", # Use black outlines,
             size=.3) +      # Thinner lines
    geom_errorbar(aes(ymin=V3-ci),
                  size=.3,    # Thinner lines
                  width=.2,
                  position=position_dodge(.9)) +
    xlab("Problem size") +
    ylab("Performance (1 / T)") +
    scale_fill_grey(name="Machine/Device", # Legend label, use darker colors
                   breaks=c("axleman", "mcore48"),
                   labels=c("axleman/Sandy Bridge CPU", "mcore48/Opteron CPU"), start=0.8, end=0.4) +
    ggtitle("Performance for serial C version") +
    scale_y_continuous(breaks=0:20*4) +
    theme_bw())