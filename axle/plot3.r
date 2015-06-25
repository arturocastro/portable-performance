library("Rmisc")
library("ggplot2")

mean_for_max <- function(data, datac)
{
    for (n in 1 : nrow(datac))
    {
        #print("a")
        #print(datac[n, 4])
        #print(max(data[(1 + 10 * (n - 1)) : (n * 10), 4]))
        datac[n, 4] <- max(data[(1 + 10 * (n - 1)) : (n * 10), 4])
    }
}

positions_file <- commandArgs(T)[1]
y_upper_bound <- commandArgs(T)[2]

raw_cols <- c("size", "config", "time")
sizes <- c("31", "63", "127", "255", "511", "1023")
#sizes <- c("511")

#positions <- c("16x4", "16x8", "16x16", "32x2", "32x4", "32x8", "32x16", "32x32", "64x1", "64x2", "64x4", "64x8", "64x16", "128x1", "128x2", "128x4", "128x8", "256x1", "256x2", "256x4", "512x1", "512x2", "1024x1", "16x32", "default")
#positions <- c("16x4", "16x8", "16x16", "32x2", "32x4", "32x8", "32x16", "32x32", "64x1", "64x2", "64x4", "64x8", "64x16", "128x1", "128x2", "128x4", "128x8", "256x1", "256x2", "256x4", "512x1", "512x2", "1024x1", "16x32", "default")
positions <- readLines(positions_file)

datacpu <- read.table("cpu/ocl4/timings/all", col.names=raw_cols)
datagpu <- read.table("gpu/ocl4/timings/all", col.names=raw_cols)
dataphi <- read.table("phi/ocl4/timings/all", col.names=raw_cols)

datacpu$performance <- 1 /datacpu$time
datagpu$performance <- 1 /datagpu$time
dataphi$performance <- 1 /dataphi$time

datacpu_sum <- summarySE(datacpu, measurevar="performance", groupvars=c("size", "config"))
datagpu_sum <- summarySE(datagpu, measurevar="performance", groupvars=c("size", "config"))
dataphi_sum <- summarySE(dataphi, measurevar="performance", groupvars=c("size", "config"))

mean_for_max(datacpu, datacpu_sum)
mean_for_max(datagpu, datagpu_sum)
mean_for_max(dataphi, dataphi_sum)

datagpu_sum$dev <- "gpu"
datacpu_sum$dev <- "cpu"
dataphi_sum$dev <- "phi"

data <- rbind(datacpu_sum, datagpu_sum, dataphi_sum)

data$config = factor(data$config)

for (size in sizes)
{
    d <- data[data$size == size, ]

ggplot(d, aes(x=config, y=performance, fill=as.factor(dev))) + 
    geom_bar(position=position_dodge(), stat="identity",
             colour="black", # Use black outlines,
             size=.3) +      # Thinner lines
    geom_errorbar(aes(ymin=performance-ci, ymax=performance),
                  size=.3,    # Thinner lines
                  width=.2,
                  position=position_dodge(.9)) +
    xlab("Local work size") +
    ylab("Performance (1 / T)") +
    scale_fill_grey(name="Device", # Legend label, use darker colors
                   breaks=c("cpu", "gpu", "phi"),
                   labels=c("Sandy Bridge CPU", "Nvidia GPU", "Xeon Phi"), start=1, end=0.4) +
    ggtitle(paste0("Performance for OpenCL version, problem size of ", size)) +
    theme_bw() + scale_x_discrete(limits = positions) + ylim(0.0, y_upper_bound)
    
    ggsave(filename=paste0("plots/", size, ".png"), width=17, limitsize=F)

ggplot(d, aes(x=config, y=performance, fill=as.factor(dev))) + 
    geom_bar(position=position_dodge(), stat="identity",
             colour="black", # Use black outlines,
             size=.3) +      # Thinner lines
    geom_errorbar(aes(ymin=performance-ci, ymax=performance),
                  size=.3,    # Thinner lines
                  width=.2,
                  position=position_dodge(.9)) +
    xlab("Local work size") +
    ylab("Performance (1 / T)") +
    scale_fill_grey(name="Device", # Legend label, use darker colors
                   breaks=c("cpu", "gpu", "phi"),
                   labels=c("Sandy Bridge CPU", "Nvidia GPU", "Xeon Phi"), start=1, end=0.4) +
    ggtitle(paste0("Performance for OpenCL version, problem size of ", size, " (zoom)")) +
    theme_bw() + scale_x_discrete(limits = positions) + ylim(0.0, 0.1)
    
    ggsave(filename=paste0("plots/", size, " (zoom)", ".png"), width=17, limitsize=F)
}



