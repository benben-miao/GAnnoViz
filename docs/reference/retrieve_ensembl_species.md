# List Supported Species from Ensembl

List supported species and their IDs from Ensembl GFF3 FTP directory.

## Usage

``` r
retrieve_ensembl_species(release = 115)
```

## Arguments

- release:

  Ensembl release version (e.g., 115).

## Value

A ***data.frame*** with two columns: `Species` (formatted name) and `ID`
(folder name).

## Author

benben-miao

## Examples

``` r
if (FALSE) { # \dontrun{
# List species for release 115
species_df <- retrieve_ensembl_species(release = 115)
head(species_df)
} # }
```
