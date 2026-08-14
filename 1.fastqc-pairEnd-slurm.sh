#!/bin/bash
#SBATCH -J fastqc
#SBATCH -p debug
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=5
#SBATCH --mem=10G
#SBATCH -t 12:00:00
#SBATCH --array=1-50  # 根据你的样本数量调整
#SBATCH -D /data120/home/users/jiaying/slurm_log
#SBATCH -o /data120/home/users/jiaying/slurm_log/fastqc_%A_%a.out
#SBATCH -e /data120/home/users/jiaying/slurm_log/fastqc_%A_%a.err

#####################################################################
## Load required modules
module purge
module load fastqc/0.12.1

# ===== path =====
#projectID=GSE153739
projectID=$1
WORKING_DIR=/mpathd/users/jiaying/Project/endometriosis_public_datasets/$projectID
FASTQ_DIR=$WORKING_DIR/fastq
#TOOLS_ROOT=

# record the modules
echo "Loaded modules:" >> $WORKING_DIR/$projectID-toolsAndRef.log
module list >> $WORKING_DIR/$projectID-toolsAndRef.log 2>&1

# ===== sample list =====
sample=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $WORKING_DIR/samples.txt)

echo "Running fastqc for sample: $sample"
date

# ===== 检查输入文件是否存在 =====
if [ ! -f "${FASTQ_DIR}/${sample}_1.fastq.gz" ] || [ ! -f "${FASTQ_DIR}/${sample}_2.fastq.gz" ]; then
	echo "ERROR: Fastq files not found for ${sample}."
	exit 1
fi

# ===== 跳过已完成的样本 =====
if [ -f "${FASTQ_DIR}/${sample}_1_fastqc.html" ] && [ -f "${FASTQ_DIR}/${sample}_2_fastqc.html" ]; then
	echo "FASTQC files already exist for ${sample}, skipping..."
	exit 0
	continue
fi

# ===== 运行fastqc =====
echo "Starting fastqc for sample: $sample"
echo "WORKING_PATH: $WORKING_DIR"

date

fastqc \
	--threads ${SLURM_CPUS_PER_TASK} \
	$FASTQ_DIR/${sample}_1.fastq.gz \
	$FASTQ_DIR/${sample}_2.fastq.gz

if [ $? -ne 0 ]; then
	echo "fastqc failed for sample: $sample"
	exit 1
fi

echo "Fastqc completed for sample: $sample"
date
