#module purge
#module load multiqc/1.14

BASE=/mpathd/users/jiaying/Project/endometriosis_public_datasets

batches=(GSE153739 GSE134056 E-MTAB-15117 PRJNA559080_GSE135485 PRJNA714537_GSE168902 PRJNA769152 PRJNA962939_GSE230956 GSE282532)

for batch in ${batches[@]}
do
	echo $batch
	working_path=$BASE/$batch
	cd $working_path
	multiqc ./ --interactive
done
