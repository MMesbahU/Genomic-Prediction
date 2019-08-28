#!/bin/bash

outDir=${1}

	# B50k
B50k=${outDir}/B50k.SNPeff_GT_matrix.Test_845_RDC.txt
echo -e "calculate ebvs from ${B50k} \n"
for anim in {6..850}
do 
	awk -v var=${anim} '{print $3*$var}' ${B50k} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${B50k} .txt)
done
	# DEL
DEL=${outDir}/DEL.SNPeff_GT_matrix.Test_845_RDC.txt
echo -e "calculate ebvs from ${DEL} \n"
for anim in {6..850}
do 
	awk -v var=${anim} '{print $3*$var}' ${DEL} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${DEL} .txt)
done
	# FI
FI=${outDir}/FI.SNPeff_GT_matrix.Test_845_RDC.txt
echo -e "calculate ebvs from ${FI} \n"
for anim in {6..850}
do 
	awk -v var=${anim} '{print $3*$var}' ${FI} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${FI} .txt)
done
##### 2 GRM
b50k_Del=${outDir}/b50k_Del.SNPeff_GT_matrix.Test_845_RDC.txt
b50k_FI=${outDir}/b50k_FI.SNPeff_GT_matrix.Test_845_RDC.txt
	# b50k_Del
echo -e "calculate ebvs from ${b50k_Del} \n"
for anim in {7..851}
do 
	awk -v var=${anim} '{print ($3*$var + $4*$var)}' ${b50k_Del} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${b50k_Del} .txt)
done
	# b50k_FI
echo -e "calculate ebvs from ${b50k_FI} \n"
for anim in {7..851}
do 
	awk -v var=${anim} '{print ($3*$var + $4*$var)}' ${b50k_FI} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${b50k_FI} .txt)
done
## 3 GRMs
# b50k_FI_Del
b50k_FI_Del=${outDir}/b50k_FI_Del.SNPeff_GT_matrix.Test_845_RDC.txt
echo -e "calculate ebvs from ${b50k_FI_Del} \n"
for anim in {8..852}
do 
	awk -v var=${anim} '{print ($3*$var + $4*$var + $5*$var)}' ${b50k_FI_Del} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${b50k_FI_Del} .txt)
done
## 6 GRMs
### FI_5subFI
FI_5subFI=${outDir}/FI_5subFI.SNPeff_GT_matrix.Test_845_RDC.txt
echo -e "calculate ebvs from ${FI_5subFI} \n"
for anim in {11..855}
do 
	awk -v var=${anim} '{print ($3*$var + $4*$var + $5*$var + $6*$var + $7*$var + $8*$var)}' ${FI_5subFI} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${FI_5subFI} .txt)
done

## 7 GRMs
b50k_FI_5subFI=${outDir}/b50k_FI_5subFI.SNPeff_GT_matrix.Test_845_RDC.txt
echo -e "calculate ebvs from ${b50k_FI_5subFI} \n"
for anim in {12..856}
do 
	awk -v var=${anim} '{print ($3*$var + $4*$var + $5*$var + $6*$var + $7*$var + $8*$var + $9*$var)}' ${b50k_FI_5subFI} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${b50k_FI_5subFI} .txt)
done
## 8 GRMs
b50k_FI_5subFI_Del=${outDir}/b50k_FI_5subFI_Del.SNPeff_GT_matrix.Test_845_RDC.txt
echo -e "calculate ebvs from ${b50k_FI_5subFI_Del} \n"
for anim in {13..857}
do 
	awk -v var=${anim} '{print ($3*$var + $4*$var + $5*$var + $6*$var + $7*$var + $8*$var + $9*$var + $10*$var)}' ${b50k_FI_5subFI_Del} | \
		awk '{sum+=$1}END{print sum}' \
		>> ${outDir}/Test_gebvs.$(basename ${b50k_FI_5subFI_Del} .txt)
done

