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
# Example GFF3 file in GAnnoViz
gff_file <- system.file(
  "extdata",
  "example.gff3.gz",
  package = "GAnnoViz")

# Extract 5'UTR
utr5 <- extract_utr5(
  gff_file = gff_file,
  format = "auto",
  utr5_info = "all")
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
utr5
#> GRanges object with 0 ranges and 3 metadata columns:
#>    seqnames    ranges strand |   exon_id   exon_name exon_rank
#>       <Rle> <IRanges>  <Rle> | <integer> <character> <integer>
#>   -------
#>   seqinfo: 22 sequences (1 circular) from an unspecified genome; no seqlengths

# 5'UTR info: utr5_range
utr5_range <- extract_utr5(
  gff_file = gff_file,
  format = "auto",
  utr5_info = "utr5_range")
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
head(utr5_range)
#> IRanges object with 0 ranges and 0 metadata columns:
#>        start       end     width
#>    <integer> <integer> <integer>
```
