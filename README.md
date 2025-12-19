# gbs2vcf

#End-to-end GBS variant-calling for plants: QC → trimming → alignment → joint genotyping → filtered VCFs.

## Usage

The repository provides `convert_gbs_2_vcf.sh`, a bash pipeline that runs quality assessment, demultiplexing, trimming, alignment, joint genotyping and variant filtering. Edit the `REF`, `SAMPLE_LIST`, and `BARCODES` variables at the top of the script to match your data, then execute:

```bash
./convert_gbs_2_vcf.sh
```

Example `samples.txt`:

```text
sample1
sample2
sample3
```

Example `barcodes.txt` (tab-separated barcode definitions):

```text
ACTGTA	sample1
CTTGAA	sample2
GACTAG	sample3
```

During demultiplexing, the pipeline calls `process_radtags`, which reads `barcodes.txt` to split raw reads by barcode into per-sample FASTQs named for the sample identifiers. Those identifiers must also appear in `samples.txt`, which the script uses to iterate through subsequent steps.

The final filtered VCF is written to `vcf/filtered_variants.vcf.gz`.
