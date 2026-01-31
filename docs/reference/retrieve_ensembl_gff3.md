# Download GFF3 Annotation from Ensembl

Download ***GFF3*** annotation file from Ensembl database.

## Usage

``` r
retrieve_ensembl_gff3(
  species = "mus_musculus",
  release = 115,
  only_chr = TRUE,
  dest_dir = tempdir()
)
```

## Arguments

- species:

  Species name (e.g., "mus_musculus", "homo_sapiens").

- release:

  Ensembl release version (e.g., 115).

- only_chr:

  Logical. If `TRUE`, download only chromosomes (chr). Default `TRUE`.

- dest_dir:

  Destination directory. Default is session temporary directory.

## Value

A ***character*** string of the downloaded file absolute path.

## Author

benben-miao

## Examples

``` r
if (FALSE) { # \dontrun{
# Download Human GFF3 (Chr only)
# gff_file <- retrieve_ensembl_gff3(
#   species = "homo_sapiens",
#   release = 115,
#   only_chr = TRUE,
#   dest_dir = tempdir())
} # }
```
