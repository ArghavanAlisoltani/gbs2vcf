# Sample and Barcode Configuration for gbs2vcf

The `gbs2vcf` pipeline uses two configuration files to map raw reads to specific samples before downstream analyses:

1. **samples.txt** – a plain-text list of sample identifiers, one per line, used throughout the pipeline to track each specimen in subsequent processing stages.
   ```text
   sample1
   sample2
   sample3
   ```

2. **barcodes.txt** – a tab-separated table associating barcode sequences with the matching sample identifiers. During demultiplexing, the `process_radtags` step reads this file to split raw reads into per-sample FASTQ files named by the sample identifier.
   ```text
   ACTGTA	sample1
   CTTGAA	sample2
   GACTAG	sample3
   ```

It is crucial that each sample listed in `samples.txt` has a corresponding barcode entry in `barcodes.txt`, ensuring that `process_radtags` can correctly demultiplex the reads and the pipeline can iterate through each sample for trimming, alignment, and variant calling stages.
