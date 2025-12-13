GAnnoViz
================

- [GAnnoViz](#gannoviz)
  - [1. Introduction](#1-introduction)
  - [2. Installation](#2-installation)
  - [3. Shiny App](#3-shiny-app)
  - [4. Extract Features](#4-extract-features)

# GAnnoViz

## 1. Introduction

**SourceCode:** <https://github.com/benben-miao/GAnnoViz/>

**Website API**: <https://benben-miao.github.io/GAnnoViz/>

GAnnoViz: a R package for genomic annotation and visualization.

### Key features

- Comprehensive GFF/GTF parsing into tidy GRanges workflows
- Publication-grade genomic visualizations: gene structure, interval
  structure, and chromosome layouts
- Signal overlays for population and epigenetic analyses (FST, DMR) with
  robust window aggregation
- Innovative genome-wide density maps and circos-style rings for
  exploratory analysis
- Modular API with consistent theming for reproducible, high-quality
  figures

### Typical inputs

- Structural annotations: GFF3/GTF
- Population genetics: sliding-window FST tables
- Epigenetics: methylKit-derived DMR tables
- Differential expression: DESeq2-style DEG tables

### Design principles

- Consistent chromosome ordering and coordinate handling across
  functions
- Overlap-length weighted aggregation for window-based statistics
- Publication-ready defaults, minimal external dependencies,
  reproducible outputs

## 2. Installation

## 3. Shiny App

``` r
# GAnnoVizApp()
```

## 4. Extract Features

### Extract Genes

``` r
# Example GFF3 file in GAnnoViz
gff_file <- system.file(
  "extdata",
  "example.gff",
  package = "GAnnoViz")

# Extract Genes
# genes <- extract_genes(
#   gff_file = gff_file,
#   format = "auto",
#   gene_info = "all")
# genes

# Gene info: gene_range
# gene_range <- extract_genes(
#   gff_file = gff_file,
#   format = "auto",
#   gene_info = "gene_range")
# head(gene_range)

kable(
  head(cars),
  caption = "aaa",
  format = "markdown", 
  digits = 3, 
  row.names = NA,
  col.names = NA,
  align = "l",
  escape = FALSE)
```

| speed | dist |
|:------|:-----|
| 4     | 2    |
| 4     | 10   |
| 7     | 4    |
| 7     | 22   |
| 8     | 16   |
| 9     | 10   |

aaa
