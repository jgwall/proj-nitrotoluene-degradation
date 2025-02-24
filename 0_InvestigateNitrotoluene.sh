#! /bin/bash

# Investigate nitrotoluene result from 2018 Phyllosphere GWAS


# Correlation between Day and Night, split by sampling date (do both raw and log transformed, since mapped with log)
# Rscript 1a_CheckCorrelationDayNight.r --countfile PhyllosphereGwasData/4j_predicted_metagenome.ko.l3.biom.txt \
#   --keyfile PhyllosphereGwasData/2a_qiime_sample_key.tsv_corrected.txt -o 1a_nitrotoluene_correlations

# Identify which lines had the most/least nitrotoluene and compare with flowering time to find best contrasts


# Determine the ultimate source of the nitrotoluene signal (=which organisms contributing to it)
