library("Rmisc")
library("ggplot2")

get_positions_labels <- function(positions)
{
    labels <- vector()
    
    for (pos in positions)
    {
        dims <- strsplit(pos, "x")[[1]]
        labels <- c(labels, paste0(pos, "\n", as.integer(dims[1]) * as.integer(dims[2])))
    }
    
    return(labels)
}

results_path <- commandArgs(T)[1]
plot_name <- commandArgs(T)[2]
positions_path <- commandArgs(T)[3]
y_upper_bound <- as.numeric(commandArgs(T)[4])

data <- read.table(results_path)
#data <- read.table("gpu/ocl4/timings/initial/time")

data$V3 <- 1 / data$V3

datac <- summarySE(data, measurevar="V3", groupvars=c("V1", "V2"))

datac$V2 = factor(datac$V2)

#print(nrow(datac))

for (n in 1 : nrow(datac))
{
	problem.size <- datac[n, "V1"]
    local.work.size <- datac[n, "V2"]
  
    maximum <- max(data[data$V1 == problem.size & data$V2 == local.work.size, "V3"])
  
    datac[datac$V1 == problem.size & datac$V2 == local.work.size, "V3"] <- maximum
}

datac$V1 <- factor(datac$V1, levels=unique(as.character(datac$V1)) )

#if (opt == 1) positions <- c("16x4", "16x8", "16x16", "32x2", "32x4", "32x8", "32x16", "32x32", "64x1", "64x2", "64x4", "64x8", "64x16", "128x1", "128x2", "128x4", "128x8", "256x1", "256x2", "256x4", "512x1", "512x2", "1024x1", "16x32", "default")
#if (opt == 2) positions <- c("32x2", "32x4", "64x1", "64x2", "64x4", "128x1", "128x2")
#if (opt == 3) positions <- c("2x32", "4x32", "1x64", "2x64", "4x64", "1x128", "2x128")
positions <- readLines(positions_path)
positions_labels <- get_positions_labels(positions)

print(ggplot(datac, aes(x=V2, y=V3, fill=as.factor(V1))) + 
    geom_bar(position=position_dodge(), stat="identity",
             colour="black", # Use black outlines,
             size=.3) +      # Thinner lines
    geom_errorbar(aes(ymin=V3-ci, ymax=V3),
                  size=.3,    # Thinner lines
                  width=.2,
                  position=position_dodge(.9)) +
    xlab("Local work size") +
    ylab("Performance (1 / T)") +
    scale_fill_grey(name="Problem size", # Legend label, use darker colors
                   breaks=c("31", "63", "127", "255", "511", "1023"),
                   labels=c("31", "63", "127", "255", "511", "1023"), start=1, end=0.2) +
    ggtitle(paste0("Performance for OpenCL version on ", plot_name)) +
    theme_bw() + scale_x_discrete(limits=positions, labels=positions_labels) + ylim(0.0, y_upper_bound))
    
 ggsave(filename=paste0("plots/", plot_name, ".png"), width=17, limitsize=F)