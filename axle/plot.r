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

results_path <- "cpu/ocl4/timings/all"
plot_name <- "Sandy Bridge CPU"
positions_path <- "positions2.txt"
y_upper_bound <- 14.5

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