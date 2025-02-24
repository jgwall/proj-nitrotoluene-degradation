#! /usr/bin/Rscript

# This is a basic template to use for making R scripts
library(argparse)
library(ggpubr)
library(tidyverse)

# Arguments
parser=ArgumentParser()
parser$add_argument("-k", "--keyfile", help="QIIME Key file")
parser$add_argument("-c", "--countfile", help="File of counts")
parser$add_argument("-o", "--outprefix", help="Output file prefix")
args=parser$parse_args()
# setwd('/home/jgwall/Projects/Maize/Nitrotoluene/')  # Debug working directory
# args=parser$parse_args(c("-k","PhyllosphereGwasData/2a_qiime_sample_key.tsv_corrected.txt",
#                          "-c","PhyllosphereGwasData/4j_predicted_metagenome.ko.l3.biom.txt",
#                          "-o",'99_tmp'))  # Debug test files

# Load data
key=read.delim(args$keyfile) %>%
  rename(sample = X.SampleID)
counts = read.delim(args$countfile, skip=1) %>%
  rename(trait=X.OTU.ID) %>%
  filter(trait=="Nitrotoluene degradation") %>%
  column_to_rownames("trait") %>%
  t() %>%
  as.data.frame() %>%
  rownames_to_column("sample")

# Check for shared samples
all_samples = union(key$sample, counts$sample)
in_key = sum(key$sample %in% all_samples)/length(all_samples)
in_count = sum(counts$sample %in% all_samples)/length(all_samples)
cat("Key has", in_key, "fraction of total; counts have",in_count,"fraction of total\n")

# Bind together and put day and night next to each other
combined = left_join(key, counts, by="sample") %>%
  mutate(plot=sub(sample, pattern=".+(14A[0-9]+)", repl="\\1")) %>%
  rename(nitrotoluene=`Nitrotoluene degradation`) %>%
  pivot_wider(id_cols = c("plot", "date", "Description"), names_from=time, values_from=nitrotoluene) %>%
  mutate(set="raw")

# Do log transform too
logvalues = combined %>%
  mutate(day=log(day), night=log(night), set="log_trans")

# Format for plotting
toplot = bind_rows(combined, logvalues)
toplot$date[toplot$date=="8082014"] = "08 Aug"
toplot$date[toplot$date=="8262014"] = "26 Aug"

# Plot
myplot = ggplot(toplot) +
  aes(x=day, y=night, color=set) +
  geom_point() +
  stat_cor(color="black") +
  geom_smooth(method="lm") +
  facet_wrap(set ~ date, scales="free")+
  theme(legend.position = "none") +
  labs(title="Compare day & night Nitrotoluene",
       subtitle="Also raw vs log-transformed (mapping was log)")
ggsave(myplot, file=paste(args$outprefix, "png", sep="."))


# Get high/low lines, just of log-transformed
logvalues$mean = rowMeans(logvalues[,c("day", "night")], na.rm=TRUE)
logvalues = logvalues %>%
  select(set, plot, Description, date, mean, day, night) %>%
  arrange(date, desc(mean)) %>%
  filter(!is.na(mean))
write.csv(logvalues, file=paste(args$outprefix, ".log_values.csv", sep=""), row.names=FALSE)

# Plot - overview
logvalues = logvalues %>%
  mutate(datapoints = 2 - is.na(day) - is.na(night)) %>%
  mutate(datapoints = factor(datapoints)) %>% # Quality score; 
  arrange(date, desc(mean)) %>%
  mutate(xval = 1:n())
barplot = ggplot(logvalues) +
  aes(x=xval, y=mean, fill=datapoints) +
  geom_col() +
  facet_wrap(~date, ncol=1, scale="free_x")
ggsave(barplot, file=paste(args$outprefix, ".barplot.png", sep=""))

# Plot - Labeled
barplot2 = ggplot(logvalues) +
  aes(y=xval, x=mean, fill=datapoints, label=Description) +
  geom_col(orientation="y") +
  geom_text(size=1.5, hjust=0) +
  facet_wrap(~date, nrow=1, scale="free_y") +
  scale_y_reverse() +
  xlim(c(NA, max(logvalues$mean)*1.25))
ggsave(barplot2, file=paste(args$outprefix, ".barplot_labels.png", sep=""), width=4, height=8)

