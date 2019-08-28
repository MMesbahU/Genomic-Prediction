#!/bin/bash

# Example: 
# bash acc_Prediction.sh /path2dir/gebvsPredict/predictGEBVs JER

workDir=${1}
breed=${2}
testDir=${workDir}/${breed}_predict/test_${breed}
# True Breeding Values
trainAnim=$(wc -l ${workDir}/${breed}_predict/${breed}_train_FI | awk '{print $1}')
testAnim=$(wc -l ${workDir}/${breed}_predict/${breed}_test_FI_DOB | awk '{print $1}' )
awk -v var1=$(awk -v var2=${trainAnim} '{sum+=$3}END{print sum/var2}' ${workDir}/${breed}_predict/${breed}_train_FI ) '{print $1,$3,$4, $3-var1}' ${workDir}/${breed}_predict/${breed}_test_FI_DOB \
	> ${testDir}/${breed}_${testAnim}.test_FI_DOB_rank

# Predicted Breeding values
while read line
do
	paste -d " " \
		<(zcat ${testDir}/${line}.GT_matrix.Test_${testAnim}_${breed}.xmat.gz | sed '1,2d' | cut -f1 -d" " ) \
		<(cat ${testDir}/Test_gebvs.${line}.SNPeff_GT_matrix.Test_${testAnim}_${breed} ) \
		> ${testDir}/predictedEBVs.${line}_${testAnim}_${breed}.txt
done < <(echo -e "B50k\nDEL\nFI\nFI_5subFI\nb50k_Del\nb50k_FI\nb50k_FI_5subFI\nb50k_FI_5subFI_Del\nb50k_FI_Del" )

## Combine files 
# join -1 1 <(join -1 1 <(join -1 1 <(join -1 1 <(join -1 1 <(join -1 1 <(sort -V path2dir/RDC_predict/test_RDC/RDC_845.test_FI_DOB_rank) -2 1 <(sort -V path2dir/RDC_predict/test_RDC/predictedEBVs.B50k_845_RDC.txt) ) -2 1 <(sort -V path2dir/RDC_predict/test_RDC/predictedEBVs.FI_845_RDC.txt ) ) -2 1 <(sort -V path2dir/RDC_predict/test_RDC/predictedEBVs.DEL_845_RDC.txt ) ) -2 1 <(sort -V path2dir/RDC_predict/test_RDC/predictedEBVs.b50k_FI_845_RDC.txt ) ) -2 1 <(sort -V path2dir/RDC_predict/test_RDC/predictedEBVs.b50k_Del_845_RDC.txt ) ) -2 1 <(sort -V path2dir/RDC_predict/test_RDC/predictedEBVs.b50k_FI_Del_845_RDC.txt)
echo -e "AnimID ebvs DOB Rank B50K FI DEL B50K_FI B50K_DEL B50K_FI_Del B50K_FI_5subFI_Del B50K_FI_5subFI FI_5subFI" > ${testDir}/${breed}_${testAnim}.Final_FI_pred
join -1 1 <(join -1 1 <(join -1 1 <(join -1 1 <(join -1 1 <(join -1 1 <(join -1 1 <(join -1 1 <(join -1 1 <(sort -V ${testDir}/${breed}_${testAnim}.test_FI_DOB_rank ) -2 1 <(sort -V ${testDir}/predictedEBVs.B50k_${testAnim}_${breed}.txt) ) -2 1 <(sort -V ${testDir}/predictedEBVs.FI_${testAnim}_${breed}.txt ) ) -2 1 <(sort -V ${testDir}/predictedEBVs.DEL_${testAnim}_${breed}.txt ) ) -2 1 <(sort -V ${testDir}/predictedEBVs.b50k_FI_${testAnim}_${breed}.txt ) ) -2 1 <(sort -V ${testDir}/predictedEBVs.b50k_Del_${testAnim}_${breed}.txt ) ) -2 1 <(sort -V ${testDir}/predictedEBVs.b50k_FI_Del_${testAnim}_${breed}.txt ) ) -2 1 <(sort -V ${testDir}/predictedEBVs.b50k_FI_5subFI_Del_${testAnim}_${breed}.txt ) ) -2 1 <(sort -V ${testDir}/predictedEBVs.b50k_FI_5subFI_${testAnim}_${breed}.txt ) ) -2 1 <(sort -V ${testDir}/predictedEBVs.FI_5subFI_${testAnim}_${breed}.txt) >> ${testDir}/${breed}_${testAnim}.Final_FI_pred
 
# d = read.table("RDC_predict/test_RDC/RDC_845.Final_FI_pred", header=T,stringsAsFactors=F)
# for (i in 5:ncol(d)) {print(round(cor(d[[4]], d[[i]]),3))}

