# Annotate differentially expressed genes (DEGs) with chromosome positions

Annotate ***differentially expressed genes (DEGs)*** with chromosome
positions.

## Usage

``` r
anno_deg_chrom(
  deg_file,
  gff_file,
  format = "auto",
  id_col = "GeneID",
  fc_col = "log2FoldChange",
  use_strand = FALSE,
  drop_unmapped = TRUE
)
```

## Arguments

- deg_file:

  DEG table from ***DESeq2*** analysis.

- gff_file:

  Genomic structural annotation **`GFF3/GTF`** file path.

- format:

  Format of GFF3/GTF file. (***"auto"***, "gff3", "gtf").

- id_col:

  Gene IDs column name. (***"GeneID"***).

- fc_col:

  Log2(fold change) column name. (***"log2FoldChange"***).

- use_strand:

  Whether to resput actual strand instead of `"*"`. (***FALSE***).

- drop_unmapped:

  Whether to drop DEG entries not found in annotation. (***TRUE***).

## Value

A data.frame with columns: (***chrom, start, end, GeneID,
log2FoldChange, strand***).

## Examples

``` r
# Example DEGs and GFF in GAnnoViz
deg_file <- system.file(
  "extdata",
  "example.deg",
  package = "GAnnoViz")

gff_file <- system.file(
  "extdata",
  "example.gff3.gz",
  package = "GAnnoViz")

# Annotate DEGs with chromosome positions
res <- anno_deg_chrom(
  deg_file = deg_file,
  gff_file = gff_file,
  format = "auto",
  id_col = "GeneID",
  fc_col = "log2FoldChange",
  use_strand = FALSE,
  drop_unmapped = TRUE
)
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
head(res)
#>   chrom     start       end            gene_id     score strand
#> 1  chr3 116306719 116343630 ENSMUSG00000000340  1.456567      *
#> 2 chr17   6869070   6877078 ENSMUSG00000000579  2.696704      *
#> 3 chr11  54988941  55003855 ENSMUSG00000000594  1.488543      *
#> 4 chr10  77877781  77899456 ENSMUSG00000000730  1.592217      *
#> 5  chr8  71261093  71274068 ENSMUSG00000000791  1.344079      *
#> 6 chr11  83538670  83540181 ENSMUSG00000000982 -2.094984      *
```
