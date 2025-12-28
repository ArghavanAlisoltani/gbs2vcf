# convert_gbs_2_vcf.sh

## Overview
This pipeline processes Genotyping-by-Sequencing (GBS) paired-end reads to produce a filtered VCF. It sets strict Bash options (`set -euo pipefail`) to fail fast on errors and defines configurable variables for thread count, reference genome path, sample list, and barcode file locations. The workflow creates dedicated directories for intermediate and final outputs.

## Step-by-step description
1. **Quality assessment**: Runs `fastqc` on each sample's R1/R2 FASTQ files in `raw/`, using GNU Parallel to process multiple samples concurrently. Results are written to `qc/` with two threads per job.
2. **Demultiplexing (optional)**: Uses Stacks `process_radtags` to split multiplexed reads by barcodes defined in the `BARCODES` file. Outputs cleaned FASTQs to `demultiplexed/` while trimming low-quality reads and rescuing barcodes.
3. **Adapter/quality trimming**: Executes `fastp` per sample to trim adapters and low-quality bases from demultiplexed reads. Generates trimmed FASTQs in `trimmed/` and per-sample reports (`.html` and `.json`) in `qc/`.
4. **Alignment**: Aligns trimmed reads to the reference genome with `bwa mem` (4 threads per job). Pipes directly to `samtools sort` to create coordinate-sorted BAMs in `align/`.
5. **Duplicate removal**: Calls `samtools markdup` to remove PCR duplicates from each BAM, replaces the original file with the deduplicated version, and builds BAM indexes.
6. **Variant calling (gVCF mode)**: Runs GATK `HaplotypeCaller` per sample to emit gVCFs into `gvcf/`, allocating 4 GB heap per job.
7. **Joint genotyping**: Combines all sample gVCFs with `gatk CombineGVCFs`, then jointly genotypes them using `gatk GenotypeGVCFs` to produce `vcf/raw_variants.vcf.gz`.
8. **Variant filtering**: Applies basic hard filters (`QD`, `FS`, `MQ`) via `gatk VariantFiltration`, writing `vcf/filtered_variants.vcf.gz`. The script finishes by printing the final VCF path.

## Usage
1. **Prepare inputs**
   - Create `samples.txt` with one sample name per line (matching FASTQ prefixes).
   - Provide `barcodes.txt` if demultiplexing is required.
   - Set `REF` to the reference FASTA path and ensure index files for BWA and GATK are present.
2. **Arrange files**
   - Place paired FASTQs as `raw/<sample>_R1.fastq.gz` and `raw/<sample>_R2.fastq.gz`.
3. **Run**
   ```bash
   chmod +x convert_gbs_2_vcf.sh
   ./convert_gbs_2_vcf.sh
   ```
   Adjust `THREADS`, `REF`, `SAMPLE_LIST`, and `BARCODES` at the top of the script as needed. Ensure required tools (`fastqc`, `process_radtags`, `fastp`, `bwa`, `samtools`, `gatk`, `parallel`) are installed and accessible.
