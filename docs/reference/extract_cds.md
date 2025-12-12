# Extract CDS ranges from GFF or GTF

Extract ***CDS*** ranges from GFF or GTF.

## Usage

``` r
extract_cds(gff_file, format = "auto", cds_info = "all")
```

## Arguments

- gff_file:

  Genomic structural annotation **`GFF3/GTF`** file path.

- format:

  Format of GFF3/GTF file. (***"auto"***, "gff3", "gtf").

- cds_info:

  CDS information. (***"all"***, "chrom_id", "cds_range").

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

# Extract CDS
cds <- extract_cds(
  gff_file = gff_file,
  format = "auto",
  cds_info = "all")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
cds
#> Error: object 'cds' not found

# CDS info: cds_range
cds_range <- extract_cds(
  gff_file = gff_file,
  format = "auto",
  cds_info = "cds_range")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
head(cds_range)
#> Error: object 'cds_range' not found
```
