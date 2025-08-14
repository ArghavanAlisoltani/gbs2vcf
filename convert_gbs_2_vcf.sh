#!/usr/bin/env bash
set -euo pipefail

THREADS=16                                 # total threads available
REF="path/to/pine_reference.fasta"         # reference genome
SAMPLE_LIST="samples.txt"                  # one sample name per line
BARCODES="barcodes.txt"                    # barcode definitions for demultiplexing

mkdir -p raw demultiplexed qc trimmed align gvcf vcf

######################################################################
# 1. Quality assessment of raw FASTQ files
######################################################################
cat "$SAMPLE_LIST" | \
  parallel -j "$THREADS" \
    'fastqc -t 2 -o qc raw/{}_R1.fastq.gz raw/{}_R2.fastq.gz'

######################################################################
# 2. Demultiplexing (Stacks process_radtags) – optional
######################################################################
process_radtags \
  -p raw/ \
  -o demultiplexed/ \
  -e sbfI \
  -b "$BARCODES" \
  -i gzfastq \
  -y fastq \
  -c -q -r \
  --threads "$THREADS"

######################################################################
# 3. Adapter/quality trimming
######################################################################
cat "$SAMPLE_LIST" | \
  parallel -j "$THREADS" \
    'fastp \
        -w 2 \
        -i demultiplexed/{}_R1.fastq.gz \
        -I demultiplexed/{}_R2.fastq.gz \
        -o trimmed/{}_R1.fastq.gz \
        -O trimmed/{}_R2.fastq.gz \
        -h qc/{}_fastp.html \
        -j qc/{}_fastp.json'

######################################################################
# 4. Alignment to reference genome
######################################################################
cat "$SAMPLE_LIST" | \
  parallel -j "$THREADS" \
    'bwa mem -t 4 "$REF" \
        trimmed/{}_R1.fastq.gz \
        trimmed/{}_R2.fastq.gz | \
     samtools sort -@ 2 -o align/{}.bam'

cat "$SAMPLE_LIST" | \
  parallel -j "$THREADS" \
    'samtools index align/{}.bam'

######################################################################
# 5. Remove PCR duplicates
######################################################################
cat "$SAMPLE_LIST" | \
  parallel -j "$THREADS" \
    'samtools markdup -@ 2 -r \
        align/{}.bam align/{}_dedup.bam && \
     mv align/{}_dedup.bam align/{}.bam && \
     samtools index align/{}.bam'

######################################################################
# 6. Variant calling to gVCFs (GATK HaplotypeCaller)
######################################################################
cat "$SAMPLE_LIST" | \
  parallel -j "$THREADS" \
    'gatk --java-options "-Xmx4g" \
       HaplotypeCaller \
       -R "$REF" \
       -I align/{}.bam \
       -O gvcf/{}.g.vcf.gz \
       -ERC GVCF'

######################################################################
# 7. Joint genotyping
######################################################################
gatk CombineGVCFs \
  -R "$REF" \
  $(cat "$SAMPLE_LIST" | xargs -I {} echo "-V gvcf/{}.g.vcf.gz") \
  -O gvcf/combined.g.vcf.gz


gatk GenotypeGVCFs \
  -R "$REF" \
  -V gvcf/combined.g.vcf.gz \
  -O vcf/raw_variants.vcf.gz

######################################################################
# 8. Variant filtering (example criteria)
######################################################################
gatk VariantFiltration \
  -R "$REF" \
  -V vcf/raw_variants.vcf.gz \
  --filter-name "QD2" --filter-expression "QD < 2.0" \
  --filter-name "FS60" --filter-expression "FS > 60.0" \
  --filter-name "MQ40" --filter-expression "MQ < 40.0" \
  -O vcf/filtered_variants.vcf.gz

echo "Pipeline complete. Final VCF: vcf/filtered_variants.vcf.gz"
