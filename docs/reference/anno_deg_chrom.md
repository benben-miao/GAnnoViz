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
# Example DEGs and GFF in SlideAnno
deg_file <- system.file(
  "extdata",
  "example.deg",
  package = "SlideAnno")

gff_file <- system.file(
  "extdata",
  "example.gff",
  package = "SlideAnno")

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
#> Warning: file("") only supports open = "w+" and open = "w+b": using the former
#> Error in utils::read.table(deg_file, header = TRUE, sep = "\t", fill = TRUE,     na.strings = "NA", stringsAsFactors = FALSE, check.names = FALSE): no lines available in input
head(res)
#> Error: object 'res' not found
```
