library("Rmisc")
library("ggplot2")

data <- read.table("initial/lime")

data$V2 <- 1 / data$V2

datac <- summarySE(data, measurevar="V2", groupvars="V1")

datac$V1 = factor(datac$V1)

datac[1,3] <- min(data[1:10, 2])
datac[2,3] <- min(data[11:20, 2])
datac[3,3] <- min(data[21:30, 2])
datac[4,3] <- min(data[31:40, 2])
datac[5,3] <- min(data[41:50, 2])

print(ggplot(datac, aes(x=V1, y=V2, fill="#FFBBBB")) + 
    geom_bar(position=position_dodge(), stat="identity",
             colour="black", # Use black outlines,
             size=.3) +      # Thinner lines
    geom_errorbar(aes(ymin=V2-se),
                  size=.3,    # Thinner lines
                  width=.2,
                  position=position_dodge(.9)) +
    xlab("Problem size") +
    ylab("Performance (1 / T)") +
    scale_fill_hue(name="Supplement type", # Legend label, use darker colors
                   breaks="V1",
                   labels="Orange juice") +
    ggtitle("Timings for serial version") +
    scale_y_continuous(breaks=0:20*4) +
    theme_bw())