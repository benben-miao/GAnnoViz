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
# Example GFF3 file in GAnnoViz
gff_file <- system.file(
  "extdata",
  "example.gff3.gz",
  package = "GAnnoViz")

# Extract 3'UTR
utr3 <- extract_utr3(
  gff_file = gff_file,
  format = "auto",
  utr3_info = "all")
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
utr3
#> GRanges object with 0 ranges and 3 metadata columns:
#>    seqnames    ranges strand |   exon_id   exon_name exon_rank
#>       <Rle> <IRanges>  <Rle> | <integer> <character> <integer>
#>   -------
#>   seqinfo: 22 sequences (1 circular) from an unspecified genome; no seqlengths

# 3'UTR info: utr3_range
utr3_range <- extract_utr3(
  gff_file = gff_file,
  format = "auto",
  utr3_info = "utr3_range")
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
head(utr3_range)
#> IRanges object with 0 ranges and 0 metadata columns:
#>        start       end     width
#>    <integer> <integer> <integer>
```
