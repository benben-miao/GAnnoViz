# Extract 5'UTR ranges from GFF or GTF

Extract ***5'UTR*** ranges from GFF or GTF.

## Usage

``` r
extract_utr5(gff_file, format = "auto", utr5_info = "all")
```

## Arguments

- gff_file:

  Genomic structural annotation **`GFF3/GTF`** file path.

- format:

  Format of GFF3/GTF file. (***"auto"***, "gff3", "gtf").

- utr5_info:

  mRNA information. (***"all"***, "chrom_id", "utr5_id", "utr5_range").

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

# Extract 5'UTR
utr5 <- extract_utr5(
  gff_file = gff_file,
  format = "auto",
  utr5_info = "all")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
utr5
#> Error: object 'utr5' not found

# 5'UTR info: utr5_id
utr5_id <- extract_utr5(
  gff_file = gff_file,
  format = "auto",
  utr5_info = "utr5_id")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
head(utr5_id)
#> Error: object 'utr5_id' not found

# 5'UTR info: utr5_range
utr5_range <- extract_utr5(
  gff_file = gff_file,
  format = "auto",
  utr5_info = "utr5_range")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
head(utr5_range)
#> Error: object 'utr5_range' not found
```
