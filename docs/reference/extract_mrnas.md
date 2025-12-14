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
# Example GFF3 file in GAnnoViz
gff_file <- system.file(
  "extdata",
  "example.gff3.gz",
  package = "GAnnoViz")

# Extract mRNAs
mrnas <- extract_mrnas(
  gff_file = gff_file,
  format = "auto",
  mrna_info = "all")
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
mrnas
#> GRanges object with 80871 ranges and 2 metadata columns:
#>           seqnames          ranges strand |     tx_id     tx_name
#>              <Rle>       <IRanges>  <Rle> | <integer> <character>
#>       [1]     chr1 4878011-4918633      + |         1  Lypla1-205
#>       [2]     chr1 4878046-4916962      + |         2  Lypla1-201
#>       [3]     chr1 4878053-4911509      + |         3  Lypla1-208
#>       [4]     chr1 4878115-4956993      + |         4 Gm37988-201
#>       [5]     chr1 4878119-4915397      + |         5  Lypla1-203
#>       ...      ...             ...    ... .       ...         ...
#>   [80867]     chrM      9877-10173      + |     80867 mt-Nd4l-201
#>   [80868]     chrM     10167-11544      + |     80868  mt-Nd4-201
#>   [80869]     chrM     11742-13565      + |     80869  mt-Nd5-201
#>   [80870]     chrM     14145-15288      + |     80870 mt-Cytb-201
#>   [80871]     chrM     13552-14070      - |     80871  mt-Nd6-201
#>   -------
#>   seqinfo: 22 sequences (1 circular) from an unspecified genome; no seqlengths

# mRNA info: mrna_range
mrna_range <- extract_mrnas(
  gff_file = gff_file,
  format = "auto",
  mrna_info = "mrna_range")
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
head(mrna_range)
#> IRanges object with 6 ranges and 0 metadata columns:
#>           start       end     width
#>       <integer> <integer> <integer>
#>   [1]   4878011   4918633     40623
#>   [2]   4878046   4916962     38917
#>   [3]   4878053   4911509     33457
#>   [4]   4878115   4956993     78879
#>   [5]   4878119   4915397     37279
#>   [6]   4878121   4911192     33072
```
