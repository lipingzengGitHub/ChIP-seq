# ChIP-seq Analysis Pipeline (Nextflow + Docker)

This pipeline performs full ChIP-seq analysis on multiple samples, including quality control, alignment, peak calling, peak annotation, and signal visualization near TSS.

Each sample should have its own folder containing ChIP and Input FASTQ files. The pipeline is powered by [Nextflow](https://www.nextflow.io/) and [Docker](https://www.docker.com/) for portability and reproducibility.

ChIP-seq-project/
├── BEDfile/
│   └── TSS.bed
├── chipseq-pipeline/
│   └── test_data/... (optional)
├── scripts/
│   └── generate_tss_bed.py
├── ChIP-seq.nf
├── Dockerfile
├── nextflow.config
├── README.md
├── .gitignore


--------

## Features

-  Quality control with FastQC
-  Alignment using Bowtie2
-  Mark duplicates with GATK
-  Peak calling with MACS2
-  Peak annotation with ChIPseeker (R/Bioconductor)
-  BAM QC with samtools flagstat
-  MultiQC reporting
-  Heatmap visualization using deepTools and TSS regions

---

##  Input Structure

Place your FASTQ files like this:

data/ ├── Sample1/ │ ├── chip_R1.fastq.gz │ └── input_R1.fastq.gz ├── Sample2/ │ ├── chip_R1.fastq.gz │ └── input_R1.fastq.gz ...


---

##  Output Includes

- `*_fastqc.html`: QC reports
- `*.bam`: sorted and deduplicated BAM files
- `*_peaks.narrowPeak`: MACS2 peaks
- `*_annotated.txt`: annotated peaks
- `chip_flagstat.txt`: samtools stats
- `multiqc_report.html`: aggregated QC
- `*_heatmap.png`: ChIP signal heatmap around TSS

---

##  Docker Setup

### 1. Clone the repository:

```bash
git clone https://github.com/<your_username>/chipseq-pipeline.git
cd chipseq-pipeline


2. Build the Docker image:
docker build -t chipseq-pipeline .

# Run the Pipeline
nextflow run ChIP-seq.nf -profile docker

# Requirements
Docker installed: https://docs.docker.com/get-docker/

Nextflow installed: https://www.nextflow.io/docs/latest/getstarted.html

Input data in data/

Bowtie2 index in assets/genome.*

TSS BED file at BEDfile/TSS.bed


# Citation
If you use this pipeline in your research, please consider citing the relevant tools:

Nextflow

Bowtie2

MACS2

GATK

ChIPseeker

deepTools

MultiQC




