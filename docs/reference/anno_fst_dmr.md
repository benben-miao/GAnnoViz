# Annotate FST/DMR slide windows with genomic features

Annotate ***FST/DMR*** slide windows with ***genomic features***.

## Usage

``` r
anno_fst_dmr(
  gff_file,
  format = "auto",
  genomic_ranges,
  chrom_col = "CHROM",
  start_col = "BIN_START",
  end_col = "BIN_END",
  upstream = 2000,
  downstream = 200,
  ignore_strand = TRUE,
  features = c("promoter", "UTR5", "gene", "exon", "intron", "CDS", "UTR3", "intergenic")
)
```

## Arguments

- gff_file:

  Genomic structural annotation **`GFF3/GTF`** file path.

- format:

  Format of GFF3/GTF file. (***"auto"***, "gff3", "gtf").

- genomic_ranges:

  Genomic ranges file (e.g., FST, DMR). (***chromosome (prefix: chr),
  start, end***).

- chrom_col:

  Chromosome column name. (***FST: "CHROM", DMR: "chr"***).

- start_col:

  Start column name. (***FST: "BIN_START", DMR: "start"***).

- end_col:

  End column name. (***FST: "BIN_END", DMR: "end"***).

- upstream:

  Promoter upstream (bp). (***2000***).

- downstream:

  Promoter downstream (bp). (***200***).

- ignore_strand:

  Whether to ignore strand when computing overlaps. (***TRUE***).

- features:

  Which feature types to annotate. c(***"promoter", "UTR5", "gene",
  "exon", "intron", "CDS", "UTR3", "intergenic"***).

## Value

Data.frame with input intervals and ***annotation results***.

## Author

benben-miao

## Examples

``` r
# Example GFF3 file in SlideAnno
gff_file <- system.file(
  "extdata",
  "example.gff",
  package = "SlideAnno")

# Annotate FST
fst_table <- system.file(
    "extdata",
    "example.fst",
    package = "SlideAnno")

res <- anno_fst_dmr(
  gff_file = gff_file,
  format = "auto",
  genomic_ranges = fst_table,
  chrom_col = "CHROM",
  start_col = "BIN_START",
  end_col = "BIN_END",
  upstream = 2000,
  downstream = 200,
  ignore_strand = TRUE,
  features = c("promoter", "UTR5", "gene", "exon", "intron", "CDS", "UTR3", "intergenic")
)
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
head(res)
#> Error: object 'res' not found

# Annotate DMR
dmr_table <- system.file(
    "extdata",
    "example.dmr",
    package = "SlideAnno")

res <- anno_fst_dmr(
  gff_file = gff_file,
  format = "auto",
  genomic_ranges = dmr_table,
  chrom_col = "chr",
  start_col = "start",
  end_col = "end",
  upstream = 2000,
  downstream = 200,
  ignore_strand = TRUE,
  features = c("promoter", "UTR5", "gene", "exon", "intron", "CDS", "UTR3", "intergenic")
)
#> Error in txdbmaker::makeTxDbFromGFF(file = gff_file, format = format): Cannot detect whether 'file' is a GFF3 or GTF file. Please use the 'format'
#>   argument to specify the format ("gff3" or "gtf").
head(res)
#> Error: object 'res' not found
```
