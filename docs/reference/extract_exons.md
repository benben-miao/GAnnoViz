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
# Example GFF3 file in GAnnoViz
gff_file <- system.file(
  "extdata",
  "example.gff3.gz",
  package = "GAnnoViz")

# Extract Exons
exons <- extract_exons(
  gff_file = gff_file,
  format = "auto",
  exon_info = "all")
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
exons
#> GRanges object with 382572 ranges and 1 metadata column:
#>            seqnames          ranges strand |   exon_id
#>               <Rle>       <IRanges>  <Rle> | <integer>
#>        [1]     chr1 4878011-4878205      + |         1
#>        [2]     chr1 4878046-4878205      + |         2
#>        [3]     chr1 4878053-4878205      + |         3
#>        [4]     chr1 4878115-4878205      + |         4
#>        [5]     chr1 4878119-4878205      + |         5
#>        ...      ...             ...    ... .       ...
#>   [382568]     chrM      9877-10173      + |    382568
#>   [382569]     chrM     10167-11544      + |    382569
#>   [382570]     chrM     11742-13565      + |    382570
#>   [382571]     chrM     14145-15288      + |    382571
#>   [382572]     chrM     13552-14070      - |    382572
#>   -------
#>   seqinfo: 22 sequences (1 circular) from an unspecified genome; no seqlengths

# Exon info: exon_range
exon_range <- extract_exons(
  gff_file = gff_file,
  format = "auto",
  exon_info = "exon_range")
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
head(exon_range)
#> IRanges object with 6 ranges and 0 metadata columns:
#>           start       end     width
#>       <integer> <integer> <integer>
#>   [1]   4878011   4878205       195
#>   [2]   4878046   4878205       160
#>   [3]   4878053   4878205       153
#>   [4]   4878115   4878205        91
#>   [5]   4878119   4878205        87
#>   [6]   4878121   4878205        85
```
