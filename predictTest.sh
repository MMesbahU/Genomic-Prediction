#!/bin/bash
# #SBATCH -p workq
# #SBATCH --mem=30G
# #SBATCH -J predictTest
# #SBATCH -n 6

# Example Run: 
# bash predictTest.sh /path2dir/gebvsPredict/predictGEBVs JER ~/path2dir/Chr1_29.Bovine50K.combined_Ref772_imp12970 ~/path2dir/gebvsPredict/predictGEBVs/JER_predict/JER_test_FI B50k ~/path2dir/GWAS_tools/GCTA_current/gcta_1.92.1beta6/gcta64
# while read line; do bash predictTest.sh /path2dir/gebvsPredict/predictGEBVs JER ~/path2dir/gebvsPredict/predictGEBVs/JER_predict/BTA1_29.b50k_FI_5subFI_Del.1211_JER ~/path2dir/gebvsPredict/predictGEBVs/JER_predict/JER_test_FI $line ~/path2dir/GWAS_tools/GCTA_current/gcta_1.92.1beta6/gcta64; done < <(echo -e "DEL\nFI\nFI_5subFI\nb50k_Del\nb50k_FI\nb50k_FI_5subFI\nb50k_FI_5subFI_Del\nb50k_FI_Del")

# bash predictTest.sh /path2dir/gebvsPredict/predictGEBVs RDC ~/path2dir/Chr1_29.Bovine50K.combined_Ref772_imp12970 ~/path2dir/gebvsPredict/predictGEBVs/RDC_predict/RDC_test_FI B50k ~/path2dir/GWAS_tools/GCTA_current/gcta_1.92.1beta6/gcta64
# while read line; do bash predictTest.sh /path2dir/gebvsPredict/predictGEBVs RDC ~/path2dir/gebvsPredict/predictGEBVs/RDC_predict/BTA1_29.b50k_FI_5subFI_Del. ~/path2dir/gebvsPredict/predictGEBVs/RDC_predict/RDC_test_FI $line ~/path2dir/GWAS_tools/GCTA_current/gcta_1.92.1beta6/gcta64; done < <(echo -e "DEL\nFI\nFI_5subFI\nb50k_Del\nb50k_FI\nb50k_FI_5subFI\nb50k_FI_5subFI_Del\nb50k_FI_Del")

# while read line; do bash predictTest.sh /path2dir/gebvsPredict/predictGEBVs HOL ~/path2dir/gebvsPredict/predictGEBVs/HOL_predict/BTA1_29.b50k_FI_5subFI_Del.5577_HOL ~/path2dir/gebvsPredict/predictGEBVs/HOL_predict/HOL_test_FI $line ~/path2dir/GWAS_tools/GCTA_current/gcta_1.92.1beta6/gcta64; done < <(echo -e "DEL\nFI\nFI_5subFI\nb50k_Del\nb50k_FI\nb50k_FI_5subFI\nb50k_FI_5subFI_Del\nb50k_FI_Del")
# bash predictTest.sh /path2dir/gebvsPredict/predictGEBVs HOL ~/path2dir/Chr1_29.Bovine50K.combined_Ref772_imp12970 ~/path2dir/gebvsPredict/predictGEBVs/HOL_predict/HOL_test_FI B50k ~/path2dir/GWAS_tools/GCTA_current/gcta_1.92.1beta6/gcta64



## Input Files
workDir=${1}
breed=${2}
genotypeFile=${3}
TestPhenoType=${4}
# BLUP SNP effects; i.e. file with ".snp.blp" extension 
# echo -e "B50k\nDEL\nFI\nFI_5subFI\nb50k_Del\nb50k_FI\nb50k_FI_5subFI\nb50k_FI_5subFI_Del\nb50k_FI_Del"
Trained_Model=${5}

## Software
GCTA=${6}

# Directories
	# Train
mkdir -p ${workDir}/${breed}_predict/train_${breed}
TRAIN=${workDir}/${breed}_predict/train_${breed}
snp_effect=${TRAIN}/Train_SNP_effect.${Trained_Model}.*_${breed}.snp.blp
	# Test 
mkdir -p ${workDir}/${breed}_predict/test_${breed}
TEST=${workDir}/${breed}_predict/test_${breed}

# Genotype Matrix for Prediction:
${GCTA} \
	--bfile ${genotypeFile} \
	--keep <(awk '{print $1,$2}' ${TestPhenoType} ) \
	--extract <(awk '{print $1}' ${snp_effect} ) \
	--recode \
	--out ${TEST}/${Trained_Model}.GT_matrix.Test_$(wc -l  ${TestPhenoType} | awk '{print $1}')_${breed}

# Transpose 
zcat ${TEST}/${Trained_Model}.GT_matrix.Test_$(wc -l  ${TestPhenoType} | awk '{print $1}')_${breed}.xmat.gz  | \
	awk -v OFS='\t' '{ 
	for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str"\t"a[i,j];
        }
        print str
    }
}' | sed '1d' > ${TEST}/${Trained_Model}.Transposed_GT_matrix.Test_$(wc -l  ${TestPhenoType} | awk '{print $1}')_${breed}.xmat 
# Join SNP effect and Genotype file 
join \
	-1 1 <( cat ${snp_effect} | sort -V ) \
	-2 1 <(awk 'NR>1' ${TEST}/${Trained_Model}.Transposed_GT_matrix.Test_$(wc -l  ${TestPhenoType} | awk '{print $1}')_${breed}.xmat | sort -V) \
	> ${TEST}/${Trained_Model}.SNPeff_GT_matrix.Test_$(wc -l  ${TestPhenoType} | awk '{print $1}')_${breed}.txt

# # calculate GEBVs for test animals
# for anim in {6..185}; 
# do 
	# awk -v var=${anim} '$2==$5 {print $3*$var}' | awk '{sum+=$1}END{print sum}'
# done

