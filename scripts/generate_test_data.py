# Generate test FASTQ files and samplesheet for ChIP-seq Nextflow pipeline

import os

# Create test data directory
os.makedirs("chipseq-pipeline/test_data", exist_ok=True)

# Minimal FASTQ content
fastq_mock = "@SEQ_ID\nGATCTGGTCTTAAAGGGT\n+\nIIIIIIIIIIIIIIIIII\n".encode()

# Create test FASTQ files
with open("chipseq-pipeline/test_data/chip_R1.fastq.gz", "wb") as f:
    f.write(fastq_mock)

with open("chipseq-pipeline/test_data/input_R1.fastq.gz", "wb") as f:
    f.write(fastq_mock)

# Create samplesheet.csv
samplesheet = """\
sample,condition,fastq
chip,ChIP,test_data/chip_R1.fastq.gz
input,Input,test_data/input_R1.fastq.gz
"""

with open("chipseq-pipeline/samplesheet.csv", "w") as f:
    f.write(samplesheet)

"✅ Test FASTQ files and samplesheet.csv created for ChIP-seq pipeline."

