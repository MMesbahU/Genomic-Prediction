#!/bin/bash
#SBATCH -p workq
#SBATCH --mem=30G
#SBATCH -J trainPredict
#SBATCH -n 6

# Example Run: 
# sbatch predictGEBVs.sh /path2dir/gebvsPredict/predictGEBVs JER ~/path2dir/Chr1_29.Bovine50K.combined_Ref772_imp12970 ~/path2dir/gebvsPredict/predictGEBVs/JER_predict/JER_train_FI ~/path2dir/gebvsPredict/predictGEBVs/JER_predict/BTA1_29.b50k_FI_5subFI_Del.1211_JER 6 5e-5 ~/path2dir/GWAS_tools/GCTA_current/gcta_1.92.1beta6/gcta64
# sbatch predictGEBVs.sh /path2dir/gebvsPredict/predictGEBVs RDC ~/path2dir/Chr1_29.Bovine50K.combined_Ref772_imp12970 ~/path2dir/gebvsPredict/predictGEBVs/RDC_predict/RDC_train_FI ~/path2dir/gebvsPredict/predictGEBVs/RDC_predict/BTA1_29.b50k_FI_5subFI_Del.4471_RDC 6 1e-7 ~/path2dir/GWAS_tools/GCTA_current/gcta_1.92.1beta6/gcta64
# sbatch predictGEBVs.sh /path2dir/gebvsPredict/predictGEBVs HOL ~/path2dir/Chr1_29.Bovine50K.combined_Ref772_imp12970 ~/path2dir/gebvsPredict/predictGEBVs/HOL_predict/HOL_train_FI ~/path2dir/gebvsPredict/predictGEBVs/HOL_predict/BTA1_29.b50k_FI_5subFI_Del.5577_HOL 6 1e-7 ~/path2dir/GWAS_tools/GCTA_current/gcta_1.92.1beta6/gcta64

## Input Files
workDir=${1}
breed=${2}
B50K=${3}
TrainPhenoType=${4}
combinedPlinkGT=${5}
Threads=${6}
# JER=5e-5 | RDC&HOL:1e-7
p_value=${7}
## Software
GCTA=${8}
# Directories
mkdir -p ${workDir}/${breed}_predict/train_${breed}

TRAIN=${workDir}/${breed}_predict/train_${breed}

gwasDir=${workDir}/${breed}_predict

deletions=${gwasDir}/Chr1_29.deletions_not_in_GWAS.${breed}_FI

# Using GCTA-GREML: Single vs multiple GRMs

################################ Step 1: Make GRM  #############################################

###### Bovine 50k
${GCTA} \
	--bfile ${B50K} \
	--maf 0.01 \
	--keep <(awk '{print $1,$2}' ${TrainPhenoType} ) \
	--autosome-num 29 \
	--make-grm \
	--thread-num ${Threads} \
	--out ${TRAIN}/Train_GRM_B50k.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}

###### Deletions not in GWAS Peak  
${GCTA} \
	--bfile ${deletions} \
	--maf 0.01 \
	--keep <(awk '{print $1,$2}' ${TrainPhenoType} ) \
	--autosome-num 29 \
	--make-grm \
	--thread-num ${Threads} \
	--out ${TRAIN}/Train_GRM_DEL.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}

###### GWAS Markers: Chr1_29.RDC_AISc_GWAS1e-7.plinkGT
while read line 
do 
	${GCTA} \
		--bfile ${gwasDir}/Chr1_29.${breed}_${line}_GWAS${p_value}.plinkGT \
		--maf 0.01 \
		--autosome-num 29 \
		--keep <(awk '{print $1,$2}' ${TrainPhenoType} ) \
		--make-grm \
		--thread-num ${Threads} \
		--out ${TRAIN}/Train_GRM_${line}.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed} 
		
done < <(echo -e "AISh\nAISc\nIFLh\nIFLc\nICF\nFI")

## List of GRMs 
echo -e "${TRAIN}/Train_GRM_B50k.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_FI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}" \
	>> ${TRAIN}/b50k_FI.2grms
echo -e "${TRAIN}/Train_GRM_B50k.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_DEL.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}" \
	>> ${TRAIN}/b50k_Del.2grms
echo -e "${TRAIN}/Train_GRM_B50k.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_FI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_DEL.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}" \
	>> ${TRAIN}/b50k_FI_Del.3grms
echo -e "${TRAIN}/Train_GRM_B50k.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_FI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_AISc.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_AISh.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_IFLc.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_IFLh.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_ICF.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}" \
	>> ${TRAIN}/b50k_FI_5subFI.7grms
echo -e "${TRAIN}/Train_GRM_B50k.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_FI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_AISc.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_AISh.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_IFLc.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_IFLh.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_ICF.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_DEL.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}" \
	>> ${TRAIN}/b50k_FI_5subFI_Del.8grms
echo -e "${TRAIN}/Train_GRM_FI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_AISc.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_AISh.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_IFLc.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_IFLh.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}\n${TRAIN}/Train_GRM_ICF.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}" \
	>> ${TRAIN}/FI_5subFI.6grms

##############################################################################################
	
################################ Step 2 ###################################################### 
################################ BLUP: Estimation of total genetic values of each individual  
	# Bovine50k 
${GCTA} \
	--reml \
	--grm ${TRAIN}/Train_GRM_B50k.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed} \
	--pheno ${TrainPhenoType} \
	--thread-num ${Threads} \
	--reml-pred-rand \
	--out ${TRAIN}/Train_blup_indv.B50k.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}
	#  SNP effect
${GCTA} \
	--bfile ${B50K} \
	--maf 0.01 \
	--keep <(awk '{print $1,$2}' ${TrainPhenoType} ) \
	--autosome-num 29 \
	--blup-snp ${TRAIN}/Train_blup_indv.B50k.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}.indi.blp \
	--thread-num ${Threads} \
	--out ${TRAIN}/Train_SNP_effect.B50k.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}

	# Deletions: 
${GCTA} \
	--reml \
	--grm ${TRAIN}/Train_GRM_DEL.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed} \
	--pheno ${TrainPhenoType} \
	--thread-num ${Threads} \
	--reml-pred-rand \
	--out ${TRAIN}/Train_blup_indv.DEL.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}
	# DEL effect
${GCTA} \
	--bfile ${deletions} \
	--maf 0.01 \
	--keep <(awk '{print $1,$2}' ${TrainPhenoType} ) \
	--autosome-num 29 \
	--blup-snp ${TRAIN}/Train_blup_indv.DEL.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}.indi.blp \
	--thread-num ${Threads} \
	--out ${TRAIN}/Train_SNP_effect.DEL.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}
	
	# FI
${GCTA} \
	--reml \
	--grm ${TRAIN}/Train_GRM_FI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed} \
	--pheno ${TrainPhenoType} \
	--thread-num ${Threads} \
	--reml-pred-rand \
	--out ${TRAIN}/Train_blup_indv.FI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}
${GCTA} \
	--bfile ${gwasDir}/Chr1_29.${breed}_FI_GWAS${p_value}.plinkGT \
	--maf 0.01 \
	--keep <(awk '{print $1,$2}' ${TrainPhenoType} ) \
	--autosome-num 29 \
	--blup-snp ${TRAIN}/Train_blup_indv.FI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}.indi.blp \
	--thread-num ${Threads} \
	--out ${TRAIN}/Train_SNP_effect.FI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}
	
### Multi-GRM	
	# B50K + FI
${GCTA} \
	--reml \
	--mgrm ${TRAIN}/b50k_FI.2grms \
	--pheno ${TrainPhenoType} \
	--thread-num ${Threads} \
	--reml-pred-rand \
	--out ${TRAIN}/Train_blup_indv.b50k_FI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}
${GCTA} \
	--bfile ${combinedPlinkGT} \
	--maf 0.01 \
	--keep <(awk '{print $1,$2}' ${TrainPhenoType} ) \
	--extract <(cat <(awk '{print $2}' ${gwasDir}/B50K.Chr1_29.FI_*_${breed}.plinkGT.bim) <(awk '{print $2}' ${gwasDir}/Chr1_29.${breed}_FI_GWAS${p_value}.plinkGT.bim) | sort -V )\
	--autosome-num 29 \
	--blup-snp ${TRAIN}/Train_blup_indv.b50k_FI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}.indi.blp \
	--thread-num ${Threads} \
	--out ${TRAIN}/Train_SNP_effect.b50k_FI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}

	# B50K + DEL
${GCTA} \
	--reml \
	--mgrm ${TRAIN}/b50k_Del.2grms \
	--pheno ${TrainPhenoType} \
	--thread-num ${Threads} \
	--reml-pred-rand \
	--out ${TRAIN}/Train_blup_indv.b50k_Del.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}
${GCTA} \
	--bfile ${combinedPlinkGT} \
	--maf 0.01 \
	--keep <(awk '{print $1,$2}' ${TrainPhenoType} ) \
	--extract <(cat <(awk '{print $2}' ${gwasDir}/B50K.Chr1_29.FI_*_${breed}.plinkGT.bim) <(awk '{print $2}' ${gwasDir}/Chr1_29.deletions_not_in_GWAS.${breed}_FI.bim) | sort -V )\
	--autosome-num 29 \
	--blup-snp ${TRAIN}/Train_blup_indv.b50k_Del.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}.indi.blp \
	--thread-num ${Threads} \
	--out ${TRAIN}/Train_SNP_effect.b50k_Del.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}
		
	# B50K + FI + DEL
${GCTA} \
	--reml \
	--mgrm ${TRAIN}/b50k_FI_Del.3grms \
	--pheno ${TrainPhenoType} \
	--thread-num ${Threads} \
	--reml-pred-rand \
	--out ${TRAIN}/Train_blup_indv.b50k_FI_Del.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}
${GCTA} \
	--bfile ${combinedPlinkGT} \
	--maf 0.01 \
	--keep <(awk '{print $1,$2}' ${TrainPhenoType} ) \
	--extract <(cat <(awk '{print $2}' ${gwasDir}/B50K.Chr1_29.FI_*_${breed}.plinkGT.bim) <(awk '{print $2}' ${gwasDir}/Chr1_29.${breed}_FI_GWAS${p_value}.plinkGT.bim) <(awk '{print $2}' ${gwasDir}/Chr1_29.deletions_not_in_GWAS.${breed}_FI.bim) | sort -V )\
	--autosome-num 29 \
	--blup-snp ${TRAIN}/Train_blup_indv.b50k_FI_Del.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}.indi.blp \
	--thread-num ${Threads} \
	--out ${TRAIN}/Train_SNP_effect.b50k_FI_Del.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}
		
	# B50K + FI + 5-sub_FI
${GCTA} \
	--reml \
	--mgrm ${TRAIN}/b50k_FI_5subFI.7grms \
	--pheno ${TrainPhenoType} \
	--thread-num ${Threads} \
	--reml-pred-rand \
	--out ${TRAIN}/Train_blup_indv.b50k_FI_5subFI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}
${GCTA} \
	--bfile ${combinedPlinkGT} \
	--maf 0.01 \
	--keep <(awk '{print $1,$2}' ${TrainPhenoType} ) \
	--exclude <(awk '{print $2}' ${gwasDir}/Chr1_29.deletions_not_in_GWAS.${breed}_FI.bim) \
	--autosome-num 29 \
	--blup-snp ${TRAIN}/Train_blup_indv.b50k_FI_5subFI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}.indi.blp \
	--thread-num ${Threads} \
	--out ${TRAIN}/Train_SNP_effect.b50k_FI_5subFI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}

	# B50K + FI + 5-sub_FI + DEL
${GCTA} \
	--reml \
	--mgrm ${TRAIN}/b50k_FI_5subFI_Del.8grms \
	--pheno ${TrainPhenoType} \
	--thread-num ${Threads} \
	--reml-pred-rand \
	--out ${TRAIN}/Train_blup_indv.b50k_FI_5subFI_Del.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}
${GCTA} \
	--bfile ${combinedPlinkGT} \
	--maf 0.01 \
	--keep <(awk '{print $1,$2}' ${TrainPhenoType} ) \
	--autosome-num 29 \
	--blup-snp ${TRAIN}/Train_blup_indv.b50k_FI_5subFI_Del.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}.indi.blp \
	--thread-num ${Threads} \
	--out ${TRAIN}/Train_SNP_effect.b50k_FI_5subFI_Del.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}

	# FI + 5-sub_FI
${GCTA} \
	--reml \
	--mgrm ${TRAIN}/FI_5subFI.6grms \
	--pheno ${TrainPhenoType} \
	--thread-num ${Threads} \
	--reml-pred-rand \
	--out ${TRAIN}/Train_blup_indv.FI_5subFI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}
${GCTA} \
	--bfile ${combinedPlinkGT} \
	--maf 0.01 \
	--keep <(awk '{print $1,$2}' ${TrainPhenoType} ) \
	--exclude <(cat <(awk '{print $2}' ${gwasDir}/B50K.Chr1_29.FI_*_${breed}.plinkGT.bim) <(awk '{print $2}' ${gwasDir}/Chr1_29.deletions_not_in_GWAS.${breed}_FI.bim) | sort -V )\
	--autosome-num 29 \
	--blup-snp ${TRAIN}/Train_blup_indv.FI_5subFI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}.indi.blp \
	--thread-num ${Threads} \
	--out ${TRAIN}/Train_SNP_effect.FI_5subFI.$(wc -l  ${TrainPhenoType} | awk '{print $1}')_${breed}
		
###############################################################################################################
