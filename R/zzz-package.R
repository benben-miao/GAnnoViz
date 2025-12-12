#' GAnnoViz: Genomic Annotation and Visualization
#'
#' The \pkg{GAnnoViz} package provides tools for genomic annotation using
#' sliding windows and GFF/GTF parsing.
#'
#' @section Main Functions:
#' \itemize{
#'   \item \code{\link{extract_genes}}: Extract gene annotations from GFF/GTF.
#'   \item \code{\link{extract_exons}}: Extract exon regions.
#' }
#'
#' @section Utilities:
#' \itemize{
#'   \item \code{\link{extract_mrnas}}: Extract mRNA transcripts.
#'   \item \code{\link{extract_cds}}: Extract coding sequences (CDS).
#' }
#'
#' @importFrom utils packageVersion
#' @keywords internal
"_PACKAGE"

resolve_gff_format <- function(gff_file, format) {
  fmt <- if (is.null(format) || length(format) == 0) "auto" else format
  if (!identical(fmt, "auto"))
    return(fmt)
  if (is.character(gff_file) && length(gff_file) > 0) {
    if (grepl("(?i)\\.gtf$", gff_file))
      return("gtf")
    if (grepl("(?i)\\.gff3?$", gff_file))
      return("gff3")
  }
  lines <- tryCatch(utils::readLines(gff_file, n = 50), error = function(e) character(0))
  if (length(lines) > 0) {
    if (any(grepl("gff-version\\s*3", lines, ignore.case = TRUE)))
      return("gff3")
    if (any(grepl("\\btranscript_id\\b", lines)))
      return("gtf")
  }
  "gff3"
}
