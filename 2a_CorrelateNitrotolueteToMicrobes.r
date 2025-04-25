#! /usr/bin/Rscript

# This is a basic template to use for making R scripts
library(argparse)
library(ggpubr)
library(tidyverse)
library(phyloseq)

# Arguments
parser=ArgumentParser()
parser$add_argument("-b", "--biomfile", help="Biom file export (in TSV format) of OTU counts used to predict metagenome")
parser$add_argument("-k", "--kofile", help="File of KO term counts")
parser$add_argument("-t", "--taxafile", help="File of OTU taxonomy")
parser$add_argument("-o", "--outprefix", help="Output file prefix")
args=parser$parse_args()
# setwd('/home/jgwall/Projects/Maize/Nitrotoluene/')  # Debug working directory
# args=parser$parse_args(c("-b","PhyllosphereGwasData/4i_closed_reference_otus.fix_copy_number.tsv",
#                          "-k","PhyllosphereGwasData/4j_predicted_metagenome.ko.l3.biom.txt",
#                          "-t","PhyllosphereGwasData/2f_otu_table.sample_filtered.no_mitochondria_chloroplast.taxonomy.txt",
#                          "-o",'99_tmp'))  # Debug test files

taxa_levels = c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")

# Load data
biom = read.delim(args$biomfile, skip=1, row.names=1)
ko = read.delim(args$kofile, skip=1, row.names=1)
nitro = subset(ko, grepl("nitrotoluene", rownames(ko), ignore.case=TRUE))
taxa=read.delim(args$taxafile, header=FALSE)
names(taxa) = c("id", "tax_string", "conf", "unknown")

# Format taxa table
taxa_table = strsplit(taxa$tax_string, split="; ")
maxlength = max(sapply(taxa_table, length))
for(i in 1:length(taxa_table)){
  if(length(taxa_table[[i]]) < maxlength){
    mylength = length(taxa_table[[i]])
    taxa_table[[i]][(mylength+1):maxlength] = "unknown"
  }
}
taxa_table = do.call(rbind, taxa_table)
colnames(taxa_table) = taxa_levels

# Make a phyloseq object for easier collapsing at different levels
mytaxa = tax_table(taxa_table)
taxa_names(mytaxa) = taxa$id
phylo = phyloseq(otu_table(biom, taxa_are_rows = TRUE),
                 mytaxa)

# Collapse at different taxonomic levels
collapsed = list()
for(level in taxa_levels){
  cat("\tCollapsing at", level, "\n")
  collapsed[[level]] = tax_glom(phylo, taxrank=level)
}

# Format and arrange for finding correlations
nitro.compare = t(nitro)
correlations = list()
for(level in taxa_levels){
  cat("\tCorrelating at", level, "\n")
  counts = t(otu_table(collapsed[[level]]))
  
  # Subset to same ones
  shared_samples = intersect(rownames(counts), rownames(nitro.compare))
  mycounts = counts[shared_samples,]
  mynitro = nitro.compare[shared_samples,] # Results in a vector
  if(!identical(rownames(mycounts), names(mynitro))){
    cat("\t\tERROR: Sample names do not match!\n")
  }
  
  # Calculate correlations
  mycors = as.numeric(cor(mynitro, mycounts))
  
  # Make data frame of results
  taxonomy = tax_table(collapsed[[level]])
  results = data.frame(cor=mycors, n=length(shared_samples), 
                       id = colnames(mycounts))
  results = cbind(results, taxonomy[results$id,])
  correlations[[level]] = results
}

big_results = bind_rows(correlations)
write.csv(big_results, file=paste(args$outprefix, ".raw.csv", sep=""), row.names=FALSE)
