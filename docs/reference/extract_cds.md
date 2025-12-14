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
# Example GFF3 file in GAnnoViz
gff_file <- system.file(
  "extdata",
  "example.gff3.gz",
  package = "GAnnoViz")

# Extract CDS
cds <- extract_cds(
  gff_file = gff_file,
  format = "auto",
  cds_info = "all")
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
cds
#> GRanges object with 0 ranges and 1 metadata column:
#>    seqnames    ranges strand |    cds_id
#>       <Rle> <IRanges>  <Rle> | <integer>
#>   -------
#>   seqinfo: 22 sequences (1 circular) from an unspecified genome; no seqlengths

# CDS info: cds_range
cds_range <- extract_cds(
  gff_file = gff_file,
  format = "auto",
  cds_info = "cds_range")
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
head(cds_range)
#> IRanges object with 0 ranges and 0 metadata columns:
#>        start       end     width
#>    <integer> <integer> <integer>
```
