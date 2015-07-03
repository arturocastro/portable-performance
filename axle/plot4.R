library("Rmisc")
library("ggplot2")

mean_for_max <- function(data, datac)
{
  for (n in 1 : nrow(datac))
  {
    #print("a")
    #print(datac[n, 4])
    #print(max(data[(1 + 10 * (n - 1)) : (n * 10), 4]))
    #datac[n, 4] <- max(data[(1 + 10 * (n - 1)) : (n * 10), 4])
    
    problem.size <- datac[n, "size"]
    local.work.size <- datac[n, "config"]
    
    maximum <- max(data[data$V1 == problem.size & data$V2 == local.work.size, "time"])
    
    datac[datac$V1 == problem.size & datac$V2 == local.work.size, "time"] <- maximum
  }
}

add_local_work_size <- function(data)
{
  data$local <- NA
  
  for (i in 1 : nrow(data))
  {
    dims <- strsplit(as.character(data[i, "config"]), "x")[[1]]
    
    data[i, "local"] <- as.integer(dims[1]) * as.integer(dims[2])
  }
  
  return(data)
}

filter_locals <- function(data)
{
  newdata <- data.frame()
  
  locals <- levels(factor(data$local))
  sizes <- levels(factor(data$size))
  devs <- levels(factor(data$dev))
  
  for (d in devs)
  {
    for (s in sizes)
    {
      for (l in locals)
      {
        m <- max(data[data$local == l & data$size == s & data$dev == d, "performance"], na.rm=T)
        newdata <- rbind(newdata, (data[data$performance == m, ]))
      }
    }
  }
  return(newdata)
}

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

positions_path <- "positions2.txt"

raw_cols <- c("size", "config", "time")
sizes <- c("31", "63", "127", "255", "511", "1023")
#sizes <- c("511")

positions <- readLines(positions_path)

datacpu <- read.table("cpu/ocl4/timings/all", col.names=raw_cols)
datagpu <- read.table("gpu/ocl4/timings/all", col.names=raw_cols)
dataphi <- read.table("phi/ocl4/timings/all", col.names=raw_cols)

datacpu <- datacpu[datacpu$config %in% positions, ]
datagpu <- datagpu[datagpu$config %in% positions, ]
dataphi <- dataphi[dataphi$config %in% positions, ]

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

data <- add_local_work_size(data)

data <- filter_locals(data)

positions_labels <- get_positions_labels(positions)

data$config = factor(data$config)

for (size in sizes)
{
  d <- data[data$size == size, ]
  
  maxgpu <- max(d[d$dev == "gpu", "performance"], na.rm=T)
  maxcpu <- max(d[d$dev == "cpu", "performance"], na.rm=T)
  maxphi <- max(d[d$dev == "phi", "performance"], na.rm=T)
  
  d$choose = factor(d$performance == maxgpu | d$performance == maxcpu | d$performance == maxphi)
    
  yrange <- maxgpu + (maxgpu * 0.05)
  yrangez <- max((maxcpu + (maxcpu * 0.05)), (maxphi + (maxphi * 0.05)))
  
  ggplot(d, aes(x=config, y=performance, fill=as.factor(dev))) + 
    geom_bar(position=position_dodge(), stat="identity",
             colour="black", # Use black outlines,
             aes(x=config, fill=as.factor(dev), size=choose)) +      # Thinner lines
    geom_errorbar(aes(ymin=performance-ci, ymax=performance),
                  size=.3,    # Thinner lines
                  width=.2,
                  position=position_dodge(.9)) +
    xlab("Local work size") +
    ylab("Performance (1 / T)") +
    scale_fill_grey(name="Device", # Legend label, use darker colors
                    breaks=c("cpu", "gpu", "phi"),
                    labels=c("Sandy Bridge CPU", "Nvidia GPU", "Xeon Phi"), start=1, end=0.5) +
    ggtitle(paste0("Performance for OpenCL version, problem size of ", size)) +
    theme_bw() + scale_x_discrete(limits=positions, labels=positions_labels) + ylim(0.0, yrange) +
    geom_hline(yintercept=c(maxgpu, maxcpu, maxphi)) +
    scale_size_manual(values=c(0.5, 1), guide = "none")
    #facet_wrap(~ cut)
  
  
  ggsave(filename=paste0("plots/", size, ".png"), width=17, limitsize=F)# +
  #geom_hline(yintercept=)
  
  ggplot(d, aes(x=config, y=performance, fill=as.factor(dev))) + 
    geom_bar(position=position_dodge(), stat="identity",
             colour="black", # Use black outlines,
             aes(x=config, fill=as.factor(dev), size=choose)) +      # Thinner lines
    geom_errorbar(aes(ymin=performance-ci, ymax=performance),
                  size=.3,    # Thinner lines
                  width=.2,
                  position=position_dodge(.9)) +
    xlab("Local work size") +
    ylab("Performance (1 / T)") +
    scale_fill_grey(name="Device", # Legend label, use darker colors
                    breaks=c("cpu", "gpu", "phi"),
                    labels=c("Sandy Bridge CPU", "Nvidia GPU", "Xeon Phi"), start=1, end=0.5) +
    ggtitle(paste0("Performance for OpenCL version, problem size of ", size, " (zoom)")) +
    theme_bw() + scale_x_discrete(limits=positions, labels=positions_labels) + ylim(0.0, yrangez) +
    geom_hline(yintercept=c(maxgpu, maxcpu, maxphi)) +
    scale_size_manual(values=c(0.5, 1), guide = "none")
  
  ggsave(filename=paste0("plots/", size, " (zoom)", ".png"), width=17, limitsize=F)
}



