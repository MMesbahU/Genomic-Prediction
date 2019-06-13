#!/bin/bash
#SBATCH -p workq
#SBATCH --mem=30G
#SBATCH -J dataPrep
#SBATCH -n 6

# Use Case: 
# sbatch Step1.prepDELnGWASmarkers.sh ~/mesbah/predictGEBVs ~/mesbah/GWAS RDC 1e-7 ~/mesbah/phenotypes 6 


# Load Plink
module load bioinfo/plink-v1.90b5.3

# in put RDC | ${breed} | JER
workDir=${1}

gwasRootDir=${2}

breed=${3}

p_value=${4}

phenoDir=${5}

Nodes=${6}

Fertility_index=${phenoDir}/${breed}_FI

mkdir -p ${workDir}/${breed}_predict

outDir=${workDir}/${breed}_predict

gwasDir=${gwasRootDir}/Geno_${breed}/result_gwas

if [ "HOL" = $breed ]; then NumAnim=5596; echo $NumAnim
else if [ "RDC" = $breed ]; then NumAnim=4507; echo $NumAnim
else NumAnim=1215; echo $NumAnim; fi
fi



# Seletct GWAS variants with P-value threshol
while read file
do 
	zcat ${gwasDir}/Chr1_29.SMgwas.GWAS.grm_pca10_maf01_Rsq0.1.${file}.mlma.gz | \
		awk -v p_value=${p_value} '$NF<p_value {print $2}' \
		> ${outDir}/${file}_GWAS${p_value}.list
 
done < <(head -6 ${phenoDir}/${breed}_Fertility_traits)

# Non-redundent list for each subtraits 
# following NAV's Fertility index calculation: 
# HOL: 0.73*IFLc+0.62* ICF1-3+2.35* IFL1-3+10.17*AIS0+35.55* AIS1-3
# RDC: 0.61*IFL0+0.56* ICF1-3+1.78* IFL1-3+10.14*AIS0+27.24* AIS1-3
# JER: 0.93*IFL0+0.28* ICF1-3+1.61* IFL1-3+9.27*AIS0+27.14* AIS1-3 
# Preference: FI > AISc > AISh > IFLc > IFLh > ICF ;

grep -vf ${outDir}/${breed}_FI_GWAS${p_value}.list ${outDir}/${breed}_AISc_GWAS${p_value}.list \
	> ${outDir}/${breed}_AISc_GWAS${p_value}_nonredund.list

grep -vf ${outDir}/${breed}_FI_GWAS${p_value}.list ${outDir}/${breed}_AISh_GWAS${p_value}.list | \
	grep -vf ${outDir}/${breed}_AISc_GWAS${p_value}_nonredund.list \
	> ${outDir}/${breed}_AISh_GWAS${p_value}_nonredund.list

grep -vf ${outDir}/${breed}_FI_GWAS${p_value}.list ${outDir}/${breed}_IFLc_GWAS${p_value}.list | \
	grep -vf ${outDir}/${breed}_AISc_GWAS${p_value}_nonredund.list | \
	grep -vf ${outDir}/${breed}_AISh_GWAS${p_value}_nonredund.list \
	> ${outDir}/${breed}_IFLc_GWAS${p_value}_nonredund.list

grep -vf ${outDir}/${breed}_FI_GWAS${p_value}.list ${outDir}/${breed}_IFLh_GWAS${p_value}.list | \
	grep -vf ${outDir}/${breed}_AISc_GWAS${p_value}_nonredund.list | \
	grep -vf ${outDir}/${breed}_AISh_GWAS${p_value}_nonredund.list | \
	grep -vf ${outDir}/${breed}_IFLc_GWAS${p_value}_nonredund.list \
	> ${outDir}/${breed}_IFLh_GWAS${p_value}_nonredund.list

grep -vf ${outDir}/${breed}_FI_GWAS${p_value}.list ${outDir}/${breed}_ICF_GWAS${p_value}.list | \
	grep -vf ${outDir}/${breed}_AISc_GWAS${p_value}_nonredund.list | \
	grep -vf ${outDir}/${breed}_AISh_GWAS${p_value}_nonredund.list | \
	grep -vf ${outDir}/${breed}_IFLc_GWAS${p_value}_nonredund.list | \
	grep -vf ${outDir}/${breed}_IFLh_GWAS${p_value}_nonredund.list \
	> ${outDir}/${breed}_ICF_GWAS${p_value}_nonredund.list

# Deletions not in GWAS peak
while read line 

do 
	
	zcat ${gwasDir}/Chr1_29.SMgwas.GWAS.grm_pca10_maf01_Rsq0.1.${line}.mlma.gz | \
		awk -v p_value=${p_value} '$NF>p_value && ($4=="<DEL>" || $5=="<DEL>") {print $2}' \
		>> ${outDir}/${breed}.Chr1_29.list_of_deletions_redundent 

done < <(head -6 ${phenoDir}/${breed}_Fertility_traits ) 
# Uniq deletion list
cat ${outDir}/${breed}.Chr1_29.list_of_deletions_redundent | sort -V | uniq \
	> ${outDir}/${breed}.Chr1_29.list_of_deletions

# clear files
mv ${outDir}/${breed}_FI_GWAS${p_value}.list ${outDir}/${breed}_FI_GWAS${p_value}_nonredund.list
rm ${outDir}/${breed}_*_GWAS${p_value}.list
rm ${outDir}/${breed}.Chr1_29.list_of_deletions_redundent 

# Plink to extract variants
######################################
################## Deletions
######################################
while read numbers 
do
	plinkGT=${gwasRootDir}/Geno_${breed}/Chr${numbers}.${breed}_${NumAnim}.plink
	plink \
		--bfile ${plinkGT} \
		--keep <(awk '{print $1,$2}' ${Fertility_index}) \
		--cow \
		--threads ${Nodes} \
		--extract ${outDir}/${breed}.Chr1_29.list_of_deletions \
		--make-bed \
		--out ${outDir}/${breed}.Chr${numbers}.not_in_gwas_deletion

done < <(awk -F":" '{print $1}' ${outDir}/${breed}.Chr1_29.list_of_deletions | sort -V | uniq | sed 's:Chr::g' )	

#
paste -d " " \
	<( ls -v ${outDir}/${breed}.Chr*.not_in_gwas_deletion.bed ) \
	<( ls -v ${outDir}/${breed}.Chr*.not_in_gwas_deletion.bim ) \
	<( ls -v ${outDir}/${breed}.Chr*.not_in_gwas_deletion.fam ) | \
	awk 'NR>1' \
	> ${outDir}/${breed}.Del_file_list.txt

# Merge bfiles
# plink --file fA --merge-list allfiles.txt --make-bed --out mynewdata [http://zzz.bwh.harvard.edu/plink/dataman.shtml#mergelist]
plink \
	--bfile ${outDir}/${breed}.Chr1.not_in_gwas_deletion \
	--merge-list ${outDir}/${breed}.Del_file_list.txt \
	--cow \
	--threads ${Nodes} \
	--make-bed \
	--out ${outDir}/Chr1_29.deletions_not_in_GWAS.${breed}_FI
# Remove intermediate files
for chr in {1..29} 
do 
	rm ${outDir}/${breed}.Chr${chr}.not_in_gwas_deletion.* 
done 

#######################################
############## GWAS Variants
#######################################
# 
while read filename 
do 
	while read numbers 
	do
		plinkGT=${gwasRootDir}/Geno_${breed}/Chr${numbers}.${breed}_${NumAnim}.plink
		plink \
			--bfile ${plinkGT} \
			--keep <(awk '{print $1,$2}' ${Fertility_index}) \
			--cow \
			--threads ${Nodes} \
			--extract ${filename} \
			--make-bed \
			--out ${outDir}/Chr${numbers}.$(basename ${filename} _nonredund.list ).plinkGT
				
	done < <(awk -F":" '{print $1}' ${filename} | sort -V | uniq | sed 's:Chr::g' )	
	# File list 
	paste -d " " \
		<( ls -v ${outDir}/Chr*.$(basename ${filename} _nonredund.list ).plinkGT.bed ) \
		<( ls -v ${outDir}/Chr*.$(basename ${filename} _nonredund.list ).plinkGT.bim ) \
		<( ls -v ${outDir}/Chr*.$(basename ${filename} _nonredund.list ).plinkGT.fam ) | \
		awk 'NR>1' \
		> ${outDir}/$(basename ${filename} _nonredund.list )_file_list.txt
		
	# Merge plink files
	firstInput=${outDir}/$( basename $( ls -v ${outDir}/Chr*.$(basename ${filename} _nonredund.list ).plinkGT.bed | head -1) .bed )
	plink \
		--bfile ${firstInput} \
		--merge-list ${outDir}/$(basename ${filename} _nonredund.list )_file_list.txt \
		--cow \
		--threads ${Nodes} \
		--make-bed \
		--out ${outDir}/Chr1_29.$(basename ${filename} _nonredund.list ).plinkGT
	# Remove intermediate files
	for chr in {1..29} 
	do 
		rm ${outDir}/Chr${chr}.$(basename ${filename} _nonredund.list ).plinkGT.* 
	done 
 
done < <( ls -v ${outDir}/${breed}_*_GWAS${p_value}_nonredund.list )

#

# ------------------------------------------------------ END -----------------------------------------------

