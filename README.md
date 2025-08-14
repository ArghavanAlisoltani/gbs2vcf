# gbs2vcf
End-to-end GBS variant-calling for plants: QC → trimming → alignment → joint genotyping → filtered VCFs.

## Usage

The repository provides `convert_gbs_2_vcf.sh`, a bash pipeline that runs quality assessment, demultiplexing, trimming, alignment, joint genotyping and variant filtering. Edit the `REF`, `SAMPLE_LIST`, and `BARCODES` variables at the top of the script to match your data, then execute:

```bash
./convert_gbs_2_vcf.sh
```

The final filtered VCF is written to `vcf/filtered_variants.vcf.gz`.
