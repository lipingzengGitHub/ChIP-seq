FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system tools and core packages
RUN apt-get update && apt-get install -y \
    bowtie2 \
    samtools \
    fastqc \
    python3-pip \
    wget \
    default-jre \
    r-base \
    unzip \
    git \
    curl \
    libcurl4-openssl-dev \
    libxml2-dev \
    libssl-dev \
    && apt-get clean

# Install Python tools
RUN pip3 install --no-cache-dir multiqc macs2 deeptools

# Install GATK
RUN wget https://github.com/broadinstitute/gatk/releases/download/4.4.0.0/gatk-4.4.0.0.zip && \
    unzip gatk-4.4.0.0.zip && \
    mv gatk-4.4.0.0 /opt/gatk && \
    ln -s /opt/g



