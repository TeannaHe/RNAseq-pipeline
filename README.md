# RNAseq-pipeline
Fastq=fastqc-trimmomatic-fastqc-STAR-RSEM=Gene_expression

In this pipeline, I have shared scripts from fastq to gene expression. 
Each step is in one sh file, and the command can be sbatch in a Slurm environment.

After downloading the scripts, you can run the pipeline from step1 to step6 to get the gene expression values from fastq.
Each step contains two kinds of scripts: one is for pair-end, and the other is for single-end. You can choose which is more suitable for your data.
First of all, you need to have the tools below installed on your system. And the system needs to be Linux/MacOS.

fastqc
trimmomatic
STAR
RSEM
