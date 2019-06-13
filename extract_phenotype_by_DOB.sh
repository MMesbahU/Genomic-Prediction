#!/bin/bash

# Example: bash extract_phenotype_by_DOB.sh ~/mesbah/predictGEBVs ~/mesbah/phenotypes BREED_CODE [e.g. RDC | HOL | JER] ~/mesbah/AnimalPedigree/pedigree.xz

outDirRoot=${1}
pheno_dir=${2}
breed=${3}
phenoFile=${pheno_dir}/${breed}_FI

# Columns of DOB/ped file: The fifth column is DOB (YYYYMMDD)
DOB_file=${4}

#################### HOL:Holsteins | RDC: Nordic Red | JER: Jersey
join \
	-1 1 <(sort -V ${phenoFile} )  \
	-2 1 <( grep -f <( awk '{print $1}' ${phenoFile} ) \
		<( awk '{if(FILENAME==ARGV[1]){id[$1]=$1} {if(FILENAME==ARGV[2] && id[$1]){print $1, $2}}}' \
		<(awk '{print $1}' ${phenoFile} ) <(xzcat ${DOB_file} | awk '{print $6,$5}')) | sort -V) \
		> ${outDirRoot}/${breed}_predict/DOB_${breed}_FI_all

# Animals without DOB info in the PED files were considered old animals and put in training dataset
grep -vf <(awk '{if(FILENAME==ARGV[1]){id[$1]=$1} {if(FILENAME==ARGV[2] && id[$1]){print $1}}}' \
	<(awk '{print $1}' ${phenoFile} )  \
	<(xzcat ${DOB_file} | awk '{print $6}')) ${phenoFile} | awk '{print $0,0}' \
	>> ${outDirRoot}/${breed}_predict/DOB_${breed}_FI_all
#### Split Train and Test data
# train: DOB < 2005
# test: DOB >=2005

awk '$4<20050000 {print $1,$2,$3}' ${outDirRoot}/${breed}_predict/DOB_${breed}_FI_all > ${outDirRoot}/${breed}_predict/${breed}_train_FI

awk '$4>=20050000 {print $1,$2,"NA"}' ${outDirRoot}/${breed}_predict/DOB_${breed}_FI_all > ${outDirRoot}/${breed}_predict/${breed}_test_FI

##################### 

