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
# Example GFF3 file in SlideAnno
gff_file <- system.file(
  "extdata",
  "example.gff",
  package = "SlideAnno")

# Extract Genes
genes <- extract_genes(
  gff_file = gff_file,
  format = "auto",
  gene_info = "all")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
genes
#> Error: object 'genes' not found

# Gene info: gene_id
gene_id <- extract_genes(
  gff_file = gff_file,
  format = "auto",
  gene_info = "gene_id")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
head(gene_id)
#> Error: object 'gene_id' not found

# Gene info: gene_range
gene_range <- extract_genes(
  gff_file = gff_file,
  format = "auto",
  gene_info = "gene_range")
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
head(gene_range)
#> Error: object 'gene_range' not found
```
