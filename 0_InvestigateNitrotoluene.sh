#! /bin/bash

# Investigate nitrotoluene result from 2018 Phyllosphere GWAS

# Allow calling conda
. $(conda info --root)/etc/profile.d/conda.sh 


# # Correlation between Day and Night, split by sampling date (do both raw and log transformed, since mapped with log)
# #    Also figures out which varieties had most/least amounts
# Rscript 1a_CheckCorrelationDayNight.r --countfile PhyllosphereGwasData/4j_predicted_metagenome.ko.l3.biom.txt \
#   --keyfile PhyllosphereGwasData/2a_qiime_sample_key.tsv_corrected.txt -o 1a_nitrotoluene_correlations


# ## PCA of maize genotypes and nitrotoluene signal (bit of a sanity check)
# conda activate tassel-5.2.89  # Tassel v5.2.89
# run_pipeline.pl -h PhyllosphereGwasData/0h_samples_sorted_filtered.hmp.txt.gz -distanceMatrix -MultiDimensionalScalingPlugin -endPlugin -export 1b_maize_pca.txt,1b_maize_pca.eigenvalues.txt 

# # Okay, PCAs made, next is to merge with data and plot
# Rscript 1c_ConnectNitrotolueneToPca.r - NEVER FINISHED


# # Determine the ultimate source of the nitrotoluene signal (=which organisms contributing to it)
# conda activate biom-format-2.1.7
# biom convert -i PhyllosphereGwasData/4i_closed_reference_otus.fix_copy_number.biom -o PhyllosphereGwasData/4i_closed_reference_otus.fix_copy_number.tsv --to-tsv

Rscript 2a_CorrelateNitrotolueteToMicrobes.r --biomfile PhyllosphereGwasData/4i_closed_reference_otus.fix_copy_number.tsv \
                         --kofile PhyllosphereGwasData/4j_predicted_metagenome.ko.l3.biom.txt \
                         --taxafile PhyllosphereGwasData/2f_otu_table.sample_filtered.no_mitochondria_chloroplast.taxonomy.txt \
                         -o 2a_taxa_correlations




# TODO
