# Extract genes information from GFF or GTF

Extract ***genes*** information from GFF or GTF.

## Usage

``` r
extract_genes(gff_file, format = "auto", gene_info = "all")
```

## Arguments

- gff_file:

  Genomic structural annotation **`GFF3/GTF`** file path.

- format:

  Format of GFF3/GTF file. (***"auto"***, "gff3", "gtf").

- gene_info:

  Gene information. (***"all"***, "chrom_id", "gene_id", "gene_range").

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

# Extract Genes
genes <- extract_genes(
  gff_file = gff_file,
  format = "auto",
  gene_info = "all")
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
genes
#> GRanges object with 21760 ranges and 1 metadata column:
#>                      seqnames              ranges strand |            gene_id
#>                         <Rle>           <IRanges>  <Rle> |        <character>
#>   ENSMUSG00000000001     chr3 108014596-108053462      - | ENSMUSG00000000001
#>   ENSMUSG00000000003     chrX   76881507-76897229      - | ENSMUSG00000000003
#>   ENSMUSG00000000028    chr16   18599197-18630737      - | ENSMUSG00000000028
#>   ENSMUSG00000000037     chrX 159865521-160041209      + | ENSMUSG00000000037
#>   ENSMUSG00000000049    chr11 108234180-108305222      + | ENSMUSG00000000049
#>                  ...      ...                 ...    ... .                ...
#>   ENSMUSG00000144287    chr14   14378353-14389396      - | ENSMUSG00000144287
#>   ENSMUSG00000144290     chr8 123642755-123701476      - | ENSMUSG00000144290
#>   ENSMUSG00000144291     chr4 156390274-156410432      + | ENSMUSG00000144291
#>   ENSMUSG00001074846     chr9 106420585-106438830      - | ENSMUSG00001074846
#>   ENSMUSG00002076083     chr4 156313792-156319314      - | ENSMUSG00002076083
#>   -------
#>   seqinfo: 22 sequences (1 circular) from an unspecified genome; no seqlengths

# Gene info: gene_range
gene_range <- extract_genes(
  gff_file = gff_file,
  format = "auto",
  gene_info = "gene_range")
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
head(gene_range)
#> IRanges object with 6 ranges and 0 metadata columns:
#>                          start       end     width
#>                      <integer> <integer> <integer>
#>   ENSMUSG00000000001 108014596 108053462     38867
#>   ENSMUSG00000000003  76881507  76897229     15723
#>   ENSMUSG00000000028  18599197  18630737     31541
#>   ENSMUSG00000000037 159865521 160041209    175689
#>   ENSMUSG00000000049 108234180 108305222     71043
#>   ENSMUSG00000000056 121128079 121146682     18604
```
