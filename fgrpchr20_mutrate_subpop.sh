#!/bin/sh

POP=$1
PATH_TO_RELATE=~/BoquirenARS/filipino-genomes-research-program/relate-master
chr=20

${PATH_TO_RELATE}/scripts/EstimatePopulationSize/EstimatePopulationSize.sh \
	-i FGRP_Relate_wcoal_chr20 \
	-o Trial_$1_chr${chr} \
	--pop_of_interest $1 \
	--poplabels Fgrp439.poplabels \
	--years_per_gen 28 \
	-m 1.25e-8 \
	--threads 10

${PATH_TO_RELATE}/bin/RelateMutationRate \
	--mode WithContextForChromosome \
	--mask StrictMask_chr${chr}.fa.gz \
	--ancestor homo_sapiens_ancestor_${chr}.fa \
	-i Trial_$1_chr${chr} \
	-o Trial_$1_mutrate_chr${chr} \

${PATH_TO_RELATE}/bin/RelateMutationRate \
	--mode Finalize \
	-i Trial_$1_mutrate_chr${chr} \
	-o Trial_$1_mutratefin_chr${chr}

awk '{$1=$1; OFS="\t"; print}' Trial_$1_mutratefin_chr${chr}.rate > Trial_$1_mutratefin_chr${chr}.rate.tsv
	

