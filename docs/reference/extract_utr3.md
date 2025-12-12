# Extract 3'UTR ranges from GFF or GTF

Extract ***3'UTR*** ranges from GFF or GTF.

## Usage

``` r
extract_utr3(gff_file, format = "auto", utr3_info = "all")
```

## Arguments

- gff_file:

  Genomic structural annotation **`GFF3/GTF`** file path.

- format:

  Format of GFF3/GTF file. (***"auto"***, "gff3", "gtf").

- utr3_info:

  mRNA information. (***"all"***, "chrom_id", "utr3_id", "utr3_range").

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

# Extract 3'UTR
utr3 <- extract_utr3(
  gff_file = gff_file,
  format = "auto",
  utr3_info = "all")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
utr3
#> Error: object 'utr3' not found

# 3'UTR info: utr3_id
utr3_id <- extract_utr3(
  gff_file = gff_file,
  format = "auto",
  utr3_info = "utr3_id")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
head(utr3_id)
#> Error: object 'utr3_id' not found

# 3'UTR info: utr3_range
utr3_range <- extract_utr3(
  gff_file = gff_file,
  format = "auto",
  utr3_info = "utr3_range")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
head(utr3_range)
#> Error: object 'utr3_range' not found
```
