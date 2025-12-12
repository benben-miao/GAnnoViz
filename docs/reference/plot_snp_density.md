# Plot SNP density at chromosome level

Plot ***SNP density*** at chromosome level.

## Usage

``` r
plot_snp_density(
  fst_file,
  LOG10 = FALSE,
  bin_size = 1e+06,
  density_color = c("#0088ff", "#ff8800", "#ff0000")
)
```

## Arguments

- fst_file:

  FST slide window file (***tab-separated***).

- LOG10:

  Whether to transform values by log10 before plotting. (***FALSE***).

- bin_size:

  Window size (bp) for density calculation. (***1e6***).

- density_color:

  Color palette for chromosome density. (***c("#0088ff", "#ff8800",
  "#ff0000")***).

## Value

Plot SNP density at chromosome level.

## Examples

``` r
# Example data in SlideAnno
fst_file <- system.file(
  "extdata",
  "example.fst",
  package = "SlideAnno")

# Plot SNP density
plot_snp_density(
  fst_file = fst_file,
  LOG10 = FALSE,
  bin_size = 1e6,
  density_color = c("#0088ff", "#ff8800", "#ff0000")
)
#> Warning: file("") only supports open = "w+" and open = "w+b": using the former
#> Error in utils::read.table(fst_file, header = TRUE, sep = "\t", fill = TRUE,     na.strings = "NA", stringsAsFactors = FALSE): no lines available in input
```
