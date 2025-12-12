# Plot gene stats for chromosomes

***Plot*** gene stats for chromosomes.

## Usage

``` r
plot_gene_stats(
  gff_file,
  format = "auto",
  bar_width = 0.7,
  bar_color = "#0055ff55",
  lable_size = 3
)
```

## Arguments

- gff_file:

  Path to **`GFF3/GTF`** file as input.

- format:

  Format of GFF3/GTF file. (***"auto"***, "gff3", "gtf").

- bar_width:

  Bar width percent. (***0.7***).

- bar_color:

  Bar color with name or hex code. (***"#0055ff55"***).

- lable_size:

  Lable text size. (***3***).

## Value

A plot object of gene stats for chromosomes.

## Author

benben-miao

## Examples

``` r
# Example GFF3 file in SlideAnno
gff_file <- system.file(
    "extdata",
    "example.gff",
    package = "SlideAnno")

# Plot gene stats
plot_gene_stats(
    gff_file = gff_file,
    format = "auto",
    bar_width = 0.7,
    bar_color = "#0055ff55",
    lable_size = 3)
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
```
