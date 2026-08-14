#!/bin/bash
#SBATCH -J RSEM
#SBATCH -p debug
#SBATCH --exclude=node123
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=10
#SBATCH --mem=48G
#SBATCH -t 12:00:00
#SBATCH --array=1-70  # 根据你的样本数量调整
#SBATCH -D /mpathd/users/jiaying/Project/endometriosis_public_datasets/
#SBATCH -o /data120/home/users/jiaying/slurm_log/RSEM_%A_%a.out
#SBATCH -e /data120/home/users/jiaying/slurm_log/RSEM_%A_%a.err

#####################################################################
## Load required modules
module purge
module load rsem/1.3.3

# ===== path =====
#projectID=GSE153739
projectID=$1
WORKING_DIR=/mpathd/users/jiaying/Project/endometriosis_public_datasets/$projectID
STAR_DIR=$WORKING_DIR/STAR
RSEM_DIR=$WORKING_DIR/RSEM

RSEMIndex=/mpathd/users/jiaying/Project/endometriosis_public_datasets/ref/RSEM_GRCh38_GENCODE43

mkdir -p $RSEM_DIR

# ===== sample list =====
sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $WORKING_DIR/samples.txt)

echo "Running RSEM for sample: $sample"
date

# ===== 检查输入文件是否存在 =====
if [ ! -f "${STAR_DIR}/${sample}.Aligned.toTranscriptome.out.bam" ] ; then
	echo "ERROR: STAR fastq files not found for ${sample}."
	exit 1
fi

# ===== 跳过已完成的样本 =====
if [ -f "${RSEM_DIR}/${sample}.genes.results" ]; then
	echo "RSEM files already exist for ${sample}, skipping..."
	exit 0
fi

# ===== 运行STAR =====
echo "Starting RSEM for sample: $sample"
echo "WORKING_PATH: $WORKING_DIR"

date

rsem-calculate-expression \
	--estimate-rspd \
	--paired-end \
	--no-bam-output \
	--alignments \
	--num-threads ${SLURM_CPUS_PER_TASK} \
	--append-names \
	--quiet \
	$STAR_DIR/${sample}.Aligned.toTranscriptome.out.bam \
	$RSEMIndex/RSEM \
	$RSEM_DIR/${sample}

if [ $? -ne 0 ]; then
	echo "RSEM failed for sample: $sample"
	exit 1
fi

echo "RSEM completed for sample: $sample"
date
