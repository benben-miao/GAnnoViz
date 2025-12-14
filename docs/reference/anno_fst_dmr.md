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
# Example GFF3 file in GAnnoViz
gff_file <- system.file(
  "extdata",
  "example.gff3.gz",
  package = "GAnnoViz")

# Annotate FST
fst_file <- system.file(
    "extdata",
    "example.fst",
    package = "GAnnoViz")

fst <- read.table(
  file = fst_file,
  header = TRUE,
  sep = "\t",
  na.strings = NA,
  stringsAsFactors = FALSE
)
head(fst)
#>   CHROM BIN_START BIN_END N_VARIANTS WEIGHTED_FST     MEAN_FST
#> 1  chr1         1   10000        119  0.034869746  0.027472144
#> 2  chr1     20001   30000        150 -0.009735326 -0.019103882
#> 3  chr1     40001   50000        587 -0.013269573 -0.004886184
#> 4  chr1     60001   70000        256  0.036700847  0.027643440
#> 5  chr1     80001   90000        842  0.020847846  0.011547497
#> 6  chr1    100001  110000        892  0.001750007  0.002121159

res <- anno_fst_dmr(
  gff_file = gff_file,
  format = "auto",
  genomic_ranges = fst_file,
  chrom_col = "CHROM",
  start_col = "BIN_START",
  end_col = "BIN_END",
  upstream = 2000,
  downstream = 200,
  ignore_strand = TRUE,
  features = c("promoter", "UTR5", "gene", "exon", "intron", "CDS", "UTR3", "intergenic")
)
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
head(res)
#>   CHROM BIN_START BIN_END N_VARIANTS WEIGHTED_FST     MEAN_FST  anno_type
#> 1  chr1         1   10000        119  0.034869746  0.027472144 intergenic
#> 2  chr1     20001   30000        150 -0.009735326 -0.019103882 intergenic
#> 3  chr1     40001   50000        587 -0.013269573 -0.004886184 intergenic
#> 4  chr1     60001   70000        256  0.036700847  0.027643440 intergenic
#> 5  chr1     80001   90000        842  0.020847846  0.011547497 intergenic
#> 6  chr1    100001  110000        892  0.001750007  0.002121159 intergenic
#>   gene_id
#> 1        
#> 2        
#> 3        
#> 4        
#> 5        
#> 6        

# Annotate DMR
dmr_file <- system.file(
    "extdata",
    "example.dmr",
    package = "GAnnoViz")

dmr <- read.table(
  file = dmr_file,
  header = TRUE,
  sep = "\t",
  na.strings = NA,
  stringsAsFactors = FALSE
)
head(dmr)
#>    chr   start     end strand pvalue   qvalue meth.diff
#> 1 chr1 4930001 4932000      *  1e-07 0.009117    89.850
#> 2 chr1 4936001 4938000      *  1e-08 0.005656   -82.314
#> 3 chr1 5670001 5672000      *  1e-09 0.011313   -69.908
#> 4 chr1 5914001 5916000      *  1e-09 0.001782   -93.310
#> 5 chr1 8576001 8578000      *  1e-08 0.009556   -68.589
#> 6 chr1 9098001 9100000      *  1e-07 0.009733   -68.756

res <- anno_fst_dmr(
  gff_file = gff_file,
  format = "auto",
  genomic_ranges = dmr_file,
  chrom_col = "chr",
  start_col = "start",
  end_col = "end",
  upstream = 2000,
  downstream = 200,
  ignore_strand = TRUE,
  features = c("promoter", "UTR5", "gene", "exon", "intron", "CDS", "UTR3", "intergenic")
)
#> Import genomic features from the file as a GRanges object ... 
#> OK
#> Prepare the 'metadata' data frame ... 
#> OK
#> Make the TxDb object ... 
#> OK
head(res)
#>    chr   start     end strand pvalue   qvalue meth.diff        anno_type
#> 1 chr1 4930001 4932000      *  1e-07 0.009117    89.850      gene,intron
#> 2 chr1 4936001 4938000      *  1e-08 0.005656   -82.314 gene,exon,intron
#> 3 chr1 5670001 5672000      *  1e-09 0.011313   -69.908      gene,intron
#> 4 chr1 5914001 5916000      *  1e-09 0.001782   -93.310       intergenic
#> 5 chr1 8576001 8578000      *  1e-08 0.009556   -68.589      gene,intron
#> 6 chr1 9098001 9100000      *  1e-07 0.009733   -68.756      gene,intron
#>                                       gene_id
#> 1 ENSMUSG00000033813(g),ENSMUSG00000104217(g)
#> 2 ENSMUSG00000033813(g),ENSMUSG00000104217(g)
#> 3                       ENSMUSG00000025905(g)
#> 4                                            
#> 5                       ENSMUSG00000025909(g)
#> 6                       ENSMUSG00000025909(g)
```
