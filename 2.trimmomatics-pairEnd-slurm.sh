#!/bin/bash
#SBATCH -J trimmomatics
#SBATCH -p debug
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH -t 12:00:00
#SBATCH --array=1-50  # 根据你的样本数量调整
#SBATCH -D /mpathd/users/jiaying/Project/endometriosis_public_datasets/
#SBATCH -o /data120/home/users/jiaying/slurm_log/trimmomatics_%A_%a.out
#SBATCH -e /data120/home/users/jiaying/slurm_log/trimmomatics_%A_%a.err

#####################################################################
## Load required modules
module purge
module load trimmomatic/0.39

# ===== path =====
#projectID=GSE153739
projectID=$1
WORKING_DIR=/mpathd/users/jiaying/Project/endometriosis_public_datasets/$projectID
FASTQ_DIR=$WORKING_DIR/fastq
TRIMMED_DIR=$WORKING_DIR/trim
trimmomaticAdaptorPath=/data120/home/users/vincent/software/trimmomatic/0.39/trimmomatic/adapters

mkdir -p $TRIMMED_DIR

# ===== sample list =====
sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $WORKING_DIR/samples.txt)

echo "Running timmomatics for sample: $sample"
date

# ===== 检查输入文件是否存在 =====
if [ ! -f "${FASTQ_DIR}/${sample}_1.fastq.gz" ] || [ ! -f "${FASTQ_DIR}/${sample}_2.fastq.gz" ]; then
	echo "ERROR: Fastq files not found for ${sample}."
	exit 1
fi

# ===== 跳过已完成的样本 =====
if [ -f "${TRIMMED_DIR}/${sample}_R1_trimmed.fastq.gz" ] && [ -f "${TRIMMED_DIR}/${sample}_R2_trimmed.fastq.gz" ]; then
	echo "Trimmomatics files already exist for ${sample}, skipping..."
	exit 0
fi

# ===== 运行fastqc =====
echo "Starting trimmomatics for sample: $sample"
echo "WORKING_PATH: $WORKING_DIR"

date

time trimmomatic PE \
	-threads ${SLURM_CPUS_PER_TASK} \
	-phred33 \
	$FASTQ_DIR/${sample}_1.fastq.gz \
	$FASTQ_DIR/${sample}_2.fastq.gz \
	$TRIMMED_DIR/${sample}_R1_trimmed.fastq.gz \
	/dev/null \
	$TRIMMED_DIR/${sample}_R2_trimmed.fastq.gz \
	/dev/null \
	ILLUMINACLIP:$trimmomaticAdaptorPath/TruSeq3-PE.fa:2:30:10:1:true \
	LEADING:3 \
	TRAILING:3 \
	SLIDINGWINDOW:4:15 \
	MINLEN:36 \
	> $TRIMMED_DIR/${sample}.trimmomatic.txt 2>&1

if [ $? -ne 0 ]; then
	echo "trimmomatics failed for sample: $sample"
	exit 1
fi

echo "Trimmomatics completed for sample: $sample"
date
