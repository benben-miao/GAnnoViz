# Extract mRNA transcripts from GFF or GTF

Extract ***mRNA*** transcripts from GFF or GTF.

## Usage

``` r
extract_mrnas(gff_file, format = "auto", mrna_info = "all")
```

## Arguments

- gff_file:

  Genomic structural annotation **`GFF3/GTF`** file path.

- format:

  Format of GFF3/GTF file. (***"auto"***, "gff3", "gtf").

- mrna_info:

  mRNA information. (***"all"***, "chrom_id", "mrna_id", "mrna_range").

## Value

A ***GRanges*** object.

## Author

benben-miao

## Examples

``` r
# Example GFF3 file in SlideAnno
gff_file <- system.file(
  "extdata",
  "example.gff",
  package = "SlideAnno")

# Extract mRNAs
mrnas <- extract_mrnas(
  gff_file = gff_file,
  format = "auto",
  mrna_info = "all")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
mrnas
#> Error: object 'mrnas' not found

# mRNA info: mrna_id
mrna_id <- extract_mrnas(
  gff_file = gff_file,
  format = "auto",
  mrna_info = "mrna_id")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
head(mrna_id)
#> Error: object 'mrna_id' not found

# mRNA info: mrna_range
mrna_range <- extract_mrnas(
  gff_file = gff_file,
  format = "auto",
  mrna_info = "mrna_range")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
head(mrna_range)
#> Error: object 'mrna_range' not found
```
