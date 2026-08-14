#!/bin/bash
#SBATCH -J STAR
#SBATCH -p debug
#SBATCH --exclude=node121,node123
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=8
#SBATCH --mem=36G
#SBATCH -t 12:00:00
#SBATCH --array=1-70  # 根据你的样本数量调整
#SBATCH -D /mpathd/users/jiaying/Project/endometriosis_public_datasets/
#SBATCH -o /data120/home/users/jiaying/slurm_log/STAR_%A_%a.out
#SBATCH -e /data120/home/users/jiaying/slurm_log/STAR_%A_%a.err

#####################################################################
## Load required modules
module purge
module load STAR/2.7.11a

# ===== path =====
#projectID=GSE153739
projectID=$1
WORKING_DIR=/mpathd/users/jiaying/Project/endometriosis_public_datasets/$projectID
TRIMMED_DIR=$WORKING_DIR/trim
STAR_DIR=$WORKING_DIR/STAR

STARIndex=/mpathd/users/jiaying/Project/endometriosis_public_datasets/ref/STAR_GRCh38_GENCODE43

mkdir -p $STAR_DIR

# ===== sample list =====
sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $WORKING_DIR/samples.txt)

echo "Running STAR for sample: $sample"
date

# ===== 检查输入文件是否存在 =====
if [ ! -f "${TRIMMED_DIR}/${sample}_R1_trimmed.fastq.gz" ] || [ ! -f "${TRIMMED_DIR}/${sample}_R2_trimmed.fastq.gz" ]; then
	echo "ERROR: Timmed fastq files not found for ${sample}."
	exit 1
fi

# ===== 跳过已完成的样本 =====
if [ -f "${STAR_DIR}/${sample}.Log.final.out" ]; then
	echo "STAR files already exist for ${sample}, skipping..."
	exit 0
fi

# ===== 运行STAR =====
echo "Starting STAR for sample: $sample"
echo "WORKING_PATH: $WORKING_DIR"

date

STAR \
	--runThreadN ${SLURM_CPUS_PER_TASK} \
	--genomeDir $STARIndex \
	--readFilesCommand zcat \
	--readFilesIn \
	$TRIMMED_DIR/${sample}_R1_trimmed.fastq.gz \
	$TRIMMED_DIR/${sample}_R2_trimmed.fastq.gz \
	--outFileNamePrefix $STAR_DIR/${sample}. \
	--outSAMtype BAM SortedByCoordinate \
	--outBAMsortingThreadN 4 \
	--quantMode TranscriptomeSAM GeneCounts \
	--outFilterMultimapNmax 10 \
	--outFilterMismatchNoverLmax 0.04 \
	--alignSJoverhangMin 5 \
	--alignSJDBoverhangMin 1

if [ $? -ne 0 ]; then
	echo "STAR failed for sample: $sample"
	exit 1
fi

echo "STAR completed for sample: $sample"
date
