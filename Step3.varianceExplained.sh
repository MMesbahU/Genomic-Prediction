#!/bin/bash
#SBATCH -p workq
#SBATCH --mem=30G
#SBATCH -J phenoVarExplained
#SBATCH -n 6

# Example Run: 
# sbatch Step3.varianceExplained.sh ~/mesbah/predictGEBVs JER ~/mesbah/Chr1_29.Bovine50K ~/mesbah/JER_predict/Chr1_29.deletions_not_in_GWAS_peak ~/mesbah/Phenotypes/Fertility_index 6 5e-5 ~/mesbah/GCTA_current/gcta_1.92.1beta6/gcta64

## Input Files

workDir=${1}

breed=${2}

mkdir -p ${workDir}/${breed}_predict/GRMs_${breed}
outGRMs=${workDir}/${breed}_predict/GRMs_${breed}

mkdir -p ${workDir}/${breed}_predict/phenoVarExp_${breed}
outVARdir=${workDir}/${breed}_predict/phenoVarExp_${breed}


B50K=${3}

deletions=${4}

phenoType=${5}

Threads=${6}

# JER=5e-5 | RDC&HOL:1e-7
p_value=${7}

## Software
GCTA=${8}

# Using GCTA-GREML: Single vs multiple GRMs

###### 

############### Bovine 50k
# Bovine50K only 
	# Make GRM
${GCTA} \
	--bfile ${B50K} \
	--maf 0.01 \
	--keep <(awk '{print $1,$2}' ${phenoType} ) \
	--autosome-num 29 \
	--make-grm \
	--thread-num ${Threads} \
	--out ${outGRMs}/GRM_B50k_${breed}

	# Estimate Variance Explained
${GCTA} \
	--reml \
	--grm ${outGRMs}/GRM_B50k_${breed} \
	--pheno ${phenoType} \
	--thread-num ${Threads} \
	--out ${outVARdir}/${breed}.VarExp_B50K

############### GWAS Peaks
# Selected Fertility Index GWAS Peak only 
	# Make GRM
while read line 
do 
	${GCTA} \
		--bfile ${workDir}/${breed}_predict/$(basename ${line} .bed) \
		--autosome-num 29 \
		--make-grm \
		--thread-num ${Threads} \
		--out ${outGRMs}/GRM.$(basename ${line} .plinkGT.bed)
		
done < <(ls -v ${workDir}/${breed}_predict/Chr1_29.${breed}_*_GWAS${p_value}.plinkGT.bed)

	# Fertility Index: Estimate Variance Explained
${GCTA} --reml \
	--grm ${outGRMs}/GRM.Chr1_29.${breed}_FI_GWAS${p_value} \
	--pheno ${phenoType} \
	--thread-num ${Threads} \
	--out ${outVARdir}/${breed}.VarExp_GWAS_FI_${p_value}

############ Deletions not in GWAS Peak
	# Deletions not in GWAS Peak only  
${GCTA} --bfile ${deletions} \
	--autosome-num 29 \
	--make-grm \
	--thread-num ${Threads} \
	--out ${outGRMs}/GRM.$(basename ${deletions} )
	
	# Estimate Variance Explained
${GCTA} --reml \
	--grm ${outGRMs}/GRM.$(basename ${deletions} ) \
	--pheno ${phenoType} \
	--thread-num ${Threads} \
	--out ${outVARdir}/${breed}.VarExp_deletions_not_in_FI_GWAS_peak

########## Multi-GRM
# List of GRMs
## B50K + GWAS_FI 
echo -e "${outGRMs}/GRM_B50k_${breed}\n${outGRMs}/GRM.Chr1_29.${breed}_FI_GWAS${p_value}" \
	>> ${outGRMs}/GRM.B50k_FI.txt
${GCTA} --reml \
	--mgrm ${outGRMs}/GRM.B50k_FI.txt \
	--pheno ${phenoType} \
	--thread-num ${Threads} \
	--out ${outVARdir}/${breed}.VarExp_B50k_FI

## B50K + Deletions 
echo -e "${outGRMs}/GRM_B50k_${breed}\n${outGRMs}/GRM.$(basename ${deletions} )" \
	>> ${outGRMs}/GRM.B50k_Del.txt
${GCTA} --reml \
	--mgrm ${outGRMs}/GRM.B50k_Del.txt \
	--pheno ${phenoType} \
	--thread-num ${Threads} \
	--out ${outVARdir}/${breed}.VarExp_B50k_Del

## B50K + GWAS_FI + Deletions 
echo -e "${outGRMs}/GRM_B50k_${breed}\n${outGRMs}/GRM.Chr1_29.${breed}_FI_GWAS${p_value}\n${outGRMs}/GRM.$(basename ${deletions} )" \
	>> ${outGRMs}/GRM.B50k_FI_Del.txt
${GCTA} --reml \
	--mgrm ${outGRMs}/GRM.B50k_FI_Del.txt \
	--pheno ${phenoType} \
	--thread-num ${Threads} \
	--out ${outVARdir}/${breed}.VarExp_B50k_FI_Del

## B50K + GWAS_FI + 5-subtraits 
echo -e "${outGRMs}/GRM_B50k_${breed}\n${outGRMs}/GRM.Chr1_29.${breed}_FI_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_AISc_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_AISh_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_ICF_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_IFLh_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_IFLc_GWAS${p_value}" \
	>> ${outGRMs}/GRM.B50k_FI_AISch_IFLch_ICF.txt
${GCTA} --reml \
	--mgrm ${outGRMs}/GRM.B50k_FI_AISch_IFLch_ICF.txt \
	--pheno ${phenoType} \
	--thread-num ${Threads} \
	--out ${outVARdir}/${breed}.VarExp_B50k_FI_AISch_IFLch_ICF

## B50K + GWAS_FI + 5-subtraits + Deletions
echo -e "${outGRMs}/GRM_B50k_${breed}\n${outGRMs}/GRM.Chr1_29.${breed}_FI_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_AISc_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_AISh_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_ICF_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_IFLh_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_IFLc_GWAS${p_value}\n${outGRMs}/GRM.$(basename ${deletions} )" \
	>> ${outGRMs}/GRM.B50k_FI_AISch_IFLch_ICF_Del.txt
${GCTA} --reml \
	--mgrm ${outGRMs}/GRM.B50k_FI_AISch_IFLch_ICF_Del.txt \
	--pheno ${phenoType} \
	--thread-num ${Threads} \
	--out ${outVARdir}/${breed}.VarExp_B50k_FI_AISch_IFLch_ICF_Del

## GWAS_FI + 5-subtraits 
echo -e "${outGRMs}/GRM.Chr1_29.${breed}_FI_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_AISc_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_AISh_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_ICF_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_IFLh_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_IFLc_GWAS${p_value}" \
	>> ${outGRMs}/GRM.FI_AISch_IFLch_ICF.txt
${GCTA} --reml \
	--mgrm ${outGRMs}/GRM.FI_AISch_IFLch_ICF.txt \
	--pheno ${phenoType} \
	--thread-num ${Threads} \
	--out ${outVARdir}/${breed}.VarExp_FI_AISch_IFLch_ICF

## GWAS_FI + 5-subtraits + deletions
echo -e "${outGRMs}/GRM.Chr1_29.${breed}_FI_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_AISc_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_AISh_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_ICF_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_IFLh_GWAS${p_value}\n${outGRMs}/GRM.Chr1_29.${breed}_IFLc_GWAS${p_value}\n${outGRMs}/GRM.$(basename ${deletions} )" \
	>> ${outGRMs}/GRM.FI_AISch_IFLch_ICF_Del.txt
${GCTA} --reml \
	--mgrm ${outGRMs}/GRM.FI_AISch_IFLch_ICF_Del.txt \
	--pheno ${phenoType} \
	--thread-num ${Threads} \
	--out ${outVARdir}/${breed}.VarExp_FI_AISch_IFLch_ICF_Del

## GWAS_FI + Deletions 
echo -e "${outGRMs}/GRM.Chr1_29.${breed}_FI_GWAS${p_value}\n${outGRMs}/GRM.$(basename ${deletions} )" \
	>> ${outGRMs}/GRM.FI_Del.txt
${GCTA} --reml \
	--mgrm ${outGRMs}/GRM.FI_Del.txt \
	--pheno ${phenoType} \
	--thread-num ${Threads} \
	--out ${outVARdir}/${breed}.VarExp_FI_Del

