# Extract promoter ranges from GFF or GTF

Extract ***promoter*** ranges from GFF or GTF.

## Usage

``` r
extract_promoters(
  gff_file,
  format = "auto",
  upstream = 2000,
  downstream = 200,
  promoter_info = "all"
)
```

## Arguments

- gff_file:

  Genomic structural annotation **`GFF3/GTF`** file path.

- format:

  Format of GFF3/GTF file. (***"auto"***, "gff3", "gtf").

- upstream:

  Promoter upstream (bp). (***2000***).

- downstream:

  Promoter downstream (bp). (***200***).

- promoter_info:

  Promoter information. (***"all"***, "chrom_id", "promoter_id",
  "promoter_range").

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

# Extract Promoters
promoters <- extract_promoters(
  gff_file = gff_file,
  format = "auto",
  upstream = 2000,
  downstream = 200,
  promoter_info = "all")
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
promoters
#> GRanges object with 80871 ranges and 2 metadata columns:
#>               seqnames          ranges strand |     tx_id     tx_name
#>                  <Rle>       <IRanges>  <Rle> | <integer> <character>
#>    Lypla1-205     chr1 4876011-4878210      + |         1  Lypla1-205
#>    Lypla1-201     chr1 4876046-4878245      + |         2  Lypla1-201
#>    Lypla1-208     chr1 4876053-4878252      + |         3  Lypla1-208
#>   Gm37988-201     chr1 4876115-4878314      + |         4 Gm37988-201
#>    Lypla1-203     chr1 4876119-4878318      + |         5  Lypla1-203
#>           ...      ...             ...    ... .       ...         ...
#>   mt-Nd4l-201     chrM      7877-10076      + |     80867 mt-Nd4l-201
#>    mt-Nd4-201     chrM      8167-10366      + |     80868  mt-Nd4-201
#>    mt-Nd5-201     chrM      9742-11941      + |     80869  mt-Nd5-201
#>   mt-Cytb-201     chrM     12145-14344      + |     80870 mt-Cytb-201
#>    mt-Nd6-201     chrM     13871-16070      - |     80871  mt-Nd6-201
#>   -------
#>   seqinfo: 22 sequences (1 circular) from an unspecified genome; no seqlengths

# Promoter info: promoter_range
promoter_range <- extract_promoters(
  gff_file = gff_file,
  format = "auto",
  upstream = 2000,
  downstream = 200,
  promoter_info = "promoter_range")
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
head(promoter_range)
#> IRanges object with 6 ranges and 0 metadata columns:
#>                   start       end     width
#>               <integer> <integer> <integer>
#>    Lypla1-205   4876011   4878210      2200
#>    Lypla1-201   4876046   4878245      2200
#>    Lypla1-208   4876053   4878252      2200
#>   Gm37988-201   4876115   4878314      2200
#>    Lypla1-203   4876119   4878318      2200
#>    Lypla1-206   4876121   4878320      2200
```
