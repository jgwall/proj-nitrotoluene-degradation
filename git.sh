#! /bin/bash

repo_name="proj-nitrotoluene-degradation"

# git init
# git commit -m "first commit"
# git branch -M main
# git remote add origin git@github.com:jgwall/proj-nitrotoluene-degradation.git
# git push -u origin main

# Add all script files
find ./ | grep -i -e "\.sh$" -e "\.py$" -e "\.r$" | xargs -d "\n" git add

# Add support files
git add */*.tsv */*.fa */*/*.fa *.yml

# Add key source & intermediate files
git add PhyllosphereGwasData/4j_predicted_metagenome.ko.l3.biom.txt
git add PhyllosphereGwasData/2a_qiime_sample_key.tsv_corrected.txt
git add 1b_maize_pca.txt

# Add notebook
git add NOTEBOOK.md
git add notebook_images/*

# Remove any deleted/untracked files
git add -u

# Commit
timestamp=`date`
git commit -m "$timestamp $1"  # '$1' Includes any extra message typed on command line
git push -u origin main

