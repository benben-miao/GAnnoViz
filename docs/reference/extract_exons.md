# Extract Exons ranges from GFF or GTF

Extract ***Exons*** ranges from GFF or GTF.

## Usage

``` r
extract_exons(gff_file, format = "auto", exon_info = "all")
```

## Arguments

- gff_file:

  Genomic structural annotation **`GFF3/GTF`** file path.

- format:

  Format of GFF3/GTF file. (***"auto"***, "gff3", "gtf").

- exon_info:

  Exon information. (***"all"***, "chrom_id", "exon_range").

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

# Extract Exons
exons <- extract_exons(
  gff_file = gff_file,
  format = "auto",
  exon_info = "all")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
exons
#> Error: object 'exons' not found

# Exon info: exon_range
exon_range <- extract_exons(
  gff_file = gff_file,
  format = "auto",
  exon_info = "exon_range")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
head(exon_range)
#> Error: object 'exon_range' not found
```
