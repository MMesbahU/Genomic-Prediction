#!/bin/bash

# bash calcJER_testGEBVs.sh path2dir/JER_predict/test_JER 1>>jerPred.log 2>>jerPred.err &
# while read line; do awk 'NR==1{print NF}' $line; done < <(ls -v JER_predict/test_JER/*.txt)

# breed=JER;awk -v var1=$(awk -v var2=`wc -l ${breed}_predict/${breed}_train_FI | awk '{print $1}'` '{sum+=$3}END{print sum/var2}' ${breed}_predict/${breed}_train_FI ) '{print $0, $3-var1}' ${breed}_predict/${breed}_test_FI


outDir=${1}

B50k=${outDir}/B50k.SNPeff_GT_matrix.Test_180_JER.txt
DEL=${outDir}/DEL.SNPeff_GT_matrix.Test_180_JER.txt
FI=${outDir}/FI.SNPeff_GT_matrix.Test_180_JER.txt
	# B50k
for anim in {6..185}
do 
	awk -v var=${anim} '{print $3*$var}' ${B50k} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${B50k} .txt)
done
	# DEL
for anim in {6..185}
do 
	awk -v var=${anim} '{print $3*$var}' ${DEL} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${DEL} .txt)
done
	# FI
for anim in {6..185}
do 
	awk -v var=${anim} '{print $3*$var}' ${FI} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${FI} .txt)
done
##### 2 GRM
b50k_Del=${outDir}/b50k_Del.SNPeff_GT_matrix.Test_180_JER.txt
b50k_FI=${outDir}/b50k_FI.SNPeff_GT_matrix.Test_180_JER.txt
	# b50k_Del
for anim in {7..186}
do 
	awk -v var=${anim} '{print ($3*$var + $4*$var)}' ${b50k_Del} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${b50k_Del} .txt)
done
	# b50k_FI
for anim in {7..186}
do 
	awk -v var=${anim} '{print ($3*$var + $4*$var)}' ${b50k_FI} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${b50k_FI} .txt)
done
## 3 GRMs
# b50k_FI_Del
b50k_FI_Del=${outDir}/b50k_FI_Del.SNPeff_GT_matrix.Test_180_JER.txt
for anim in {8..187}
do 
	awk -v var=${anim} '{print ($3*$var + $4*$var + $5*$var)}' ${b50k_FI_Del} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${b50k_FI_Del} .txt)
done
## 6 GRMs
### FI_5subFI
FI_5subFI=${outDir}/FI_5subFI.SNPeff_GT_matrix.Test_180_JER.txt
for anim in {11..190}
do 
	awk -v var=${anim} '{print ($3*$var + $4*$var + $5*$var + $6*$var + $7*$var + $8*$var)}' ${FI_5subFI} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${FI_5subFI} .txt)
done

## 7 GRMs
b50k_FI_5subFI=${outDir}/b50k_FI_5subFI.SNPeff_GT_matrix.Test_180_JER.txt
for anim in {12..191}
do 
	awk -v var=${anim} '{print ($3*$var + $4*$var + $5*$var + $6*$var + $7*$var + $8*$var + $9*$var)}' ${b50k_FI_5subFI} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${b50k_FI_5subFI} .txt)
done
## 8 GRMs
b50k_FI_5subFI_Del=${outDir}/b50k_FI_5subFI_Del.SNPeff_GT_matrix.Test_180_JER.txt
for anim in {13..192}
do 
	awk -v var=${anim} '{print ($3*$var + $4*$var + $5*$var + $6*$var + $7*$var + $8*$var + $9*$var + $10*$var)}' ${b50k_FI_5subFI_Del} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${b50k_FI_5subFI_Del} .txt)
done

