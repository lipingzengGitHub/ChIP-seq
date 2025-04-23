#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.input_dir     = "data"
params.ref_index     = "assets/genome"         // Bowtie2 index basename
params.genome_size   = "2.7e9"                 // MACS2 genome size (e.g. hg38)
params.tss_bed       = "BEDfile/TSS.bed"
params.outdir        = "results"

workflow {
  Channel
    .fromPath("${params.input_dir}/*")
    .map { sample_dir ->
      def sample = sample_dir.getName()
      def chip_fq = sample_dir.resolve("chip_R1.fastq.gz")
      def input_fq = sample_dir.resolve("input_R1.fastq.gz")
      tuple(sample, chip_fq, input_fq)
    }
    | set { samples }

  samples | fastqc
  samples | align_bowtie2 | sort_bam | mark_duplicates | call_peaks | annotate_peaks
  samples | align_bowtie2 | sort_bam | mark_duplicates | bam_qc | multiqc_summary
  samples | align_bowtie2 | sort_bam | mark_duplicates | generate_heatmap
}

process fastqc {
  tag "$sample"
  input:
    tuple val(sample), path(chip_fq), path(input_fq)
  output:
    path("*_fastqc.html")
  script:
    """
    fastqc $chip_fq $input_fq
    """
}

process align_bowtie2 {
  tag "$sample"
  input:
    tuple val(sample), path(chip_fq), path(input_fq)
  output:
    tuple val(sample), path("chip.sam"), path("input.sam")
  script:
    """
    bowtie2 -x ${params.ref_index} -U $chip_fq -S chip.sam
    bowtie2 -x ${params.ref_index} -U $input_fq -S input.sam
    """
}

process sort_bam {
  tag "$sample"
  input:
    tuple val(sample), path(chip_sam), path(input_sam)
  output:
    tuple val(sample), path("chip.sorted.bam"), path("input.sorted.bam")
  script:
    """
    samtools view -Sb chip.sam | samtools sort -o chip.sorted.bam
    samtools view -Sb input.sam | samtools sort -o input.sorted.bam
    """
}

process mark_duplicates {
  tag "$sample"
  input:
    tuple val(sample), path(chip_bam), path(input_bam)
  output:
    tuple val(sample), path("chip.dedup.bam"), path("input.dedup.bam")
  script:
    """
    gatk MarkDuplicates -I chip.sorted.bam -O chip.dedup.bam -M chip.metrics.txt
    samtools index chip.dedup.bam
    gatk MarkDuplicates -I input.sorted.bam -O input.dedup.bam -M input.metrics.txt
    samtools index input.dedup.bam
    """
}

process call_peaks {
  tag "$sample"
  input:
    tuple val(sample), path(chip_bam), path(input_bam)
  output:
    path("${sample}_peaks.narrowPeak")
  script:
    """
    macs2 callpeak -t chip.dedup.bam -c input.dedup.bam -f BAM -n ${sample} -g ${params.genome_size} --outdir .
    """
}

process annotate_peaks {
  tag "$peak_file"
  input:
    path peak_file
  output:
    path("${peak_file.simpleName}_annotated.txt")
  script:
    """
    Rscript -e "
    library(ChIPseeker);
    library(TxDb.Hsapiens.UCSC.hg38.knownGene);
    peak <- readPeakFile('${peak_file}');
    txdb <- TxDb.Hsapiens.UCSC.hg38.knownGene;
    ann <- annotatePeak(peak, TxDb=txdb, tssRegion=c(-3000, 3000));
    write.table(as.data.frame(ann), file='${peak_file.simpleName}_annotated.txt', sep='\\t', quote=FALSE, row.names=FALSE)
    "
    """
}

process bam_qc {
  tag "$sample"
  input:
    tuple val(sample), path(chip_bam), path(input_bam)
  output:
    path("chip_flagstat.txt"), path("input_flagstat.txt")
  script:
    """
    samtools flagstat chip.dedup.bam > chip_flagstat.txt
    samtools flagstat input.dedup.bam > input_flagstat.txt
    """
}

process multiqc_summary {
  tag "multiqc"
  input:
    path("*_flagstat.txt")
  output:
    path("multiqc_report.html")
  script:
    """
    multiqc . -o .
    """
}

process generate_heatmap {
  tag "$sample"
  input:
    tuple val(sample), path(chip_bam)
  output:
    path("${sample}_heatmap.png")
  script:
    """
    bamCoverage -b $chip_bam -o ${sample}.bw --normalizeUsing RPKM

    computeMatrix reference-point \\
      -S ${sample}.bw \\
      -R ${params.tss_bed} \\
      --referencePoint TSS -a 3000 -b 3000 \\
      -out ${sample}_matrix.gz

    plotHeatmap -m ${sample}_matrix.gz -out ${sample}_heatmap.png
    """
}


