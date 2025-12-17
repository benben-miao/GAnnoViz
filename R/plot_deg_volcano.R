#' @title Plot differentially expressed genes (DEGs) volcano
#' @description Plot differentially expressed genes (DEGs) \bold{\emph{volcano}}.
#' @author benben-miao
#'
#' @return A \bold{\emph{ggplot object}} visualizing DEGs volcano.
#' @param deg_file DEG table from \bold{\emph{DESeq2}} analysis.
#' @param id_col Gene IDs column name. (\bold{\emph{"GeneID"}}).
#' @param fc_col Log2(fold change) column name. (\bold{\emph{"log2FoldChange"}}).
#' @param sig_col Significance column name. (\bold{\emph{"padj"}}, "pvalue").
#' @param fc_threshold Absolute log2FC threshold. (\bold{\emph{1}}).
#' @param sig_threshold Significance threshold. (\bold{\emph{0.05}}).
#' @param point_size Point size. (\bold{\emph{2}}).
#' @param point_alpha Point alpha. (\bold{\emph{0.5}}).
#' @param up_color Color for up-regulated significant genes. (\bold{\emph{"#ff0000"}}).
#' @param down_color Color for down-regulated significant genes. (\bold{\emph{"#008800"}}).
#' @param ns_color Color for non-significant genes. (\bold{\emph{"#888888"}}).
#'
#' @importFrom magrittr %>%
#' @export
#'
#' @examples
#' # DEG results from DESeq2
#' deg_file <- system.file(
#'   "extdata",
#'   "example.deg",
#'   package = "GAnnoViz")
#'
#' # Volcano plot
#' plot_deg_volcano(
#'   deg_file = deg_file,
#'   id_col = "GeneID",
#'   fc_col = "log2FoldChange",
#'   sig_col = "padj",
#'   fc_threshold = 1,
#'   sig_threshold = 0.05,
#'   point_size = 2,
#'   point_alpha = 0.5,
#'   up_color = "#ff0000",
#'   down_color = "#008800",
#'   ns_color = "#888888"
#' )
#'
plot_deg_volcano <- function(deg_file,
                             id_col = "GeneID",
                             fc_col = "log2FoldChange",
                             sig_col = "padj",
                             fc_threshold = 1,
                             sig_threshold = 0.05,
                             point_size = 2,
                             point_alpha = 0.5,
                             up_color = "#ff0000",
                             down_color = "#008800",
                             ns_color = "#888888") {
  deg <- utils::read.table(
    deg_file,
    header = TRUE,
    sep = "\t",
    fill = TRUE,
    na.strings = "NA",
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  if (!(fc_col %in% colnames(deg)))
    stop("FC column not found: ", fc_col)
  sig_used <- sig_col

  x <- as.numeric(deg[[fc_col]])
  y_raw <- as.numeric(deg[[sig_used]])
  keep <- stats::complete.cases(x, y_raw) &
    is.finite(x) & is.finite(y_raw)
  x <- x[keep]
  y_raw <- y_raw[keep]
  gene <- if (id_col %in% colnames(deg))
    as.character(deg[[id_col]][keep])
  else
    rep(NA_character_, length(x))

  if (length(x) == 0)
    stop("No valid entries found after filtering")

  y <- -log10(pmax(y_raw, .Machine$double.xmin))
  state <- ifelse((x >= fc_threshold) &
                    (y_raw <= sig_threshold),
                  "up",
                  ifelse((x <= -fc_threshold) &
                           (y_raw <= sig_threshold), "down", "ns"))
  df <- data.frame(
    gene = gene,
    log2fc = x,
    neglog10 = y,
    state = factor(state, levels = c("down", "ns", "up")),
    stringsAsFactors = FALSE
  )

  p <- ggplot2::ggplot(df, ggplot2::aes(x = log2fc, y = neglog10, color = state)) +
    ggplot2::geom_point(size = point_size, alpha = point_alpha) +
    ggplot2::geom_vline(
      xintercept = c(-fc_threshold, fc_threshold),
      color = "#666666",
      linewidth = 0.4,
      linetype = "dashed"
    ) +
    ggplot2::geom_hline(
      yintercept = -log10(sig_threshold),
      color = "#666666",
      linewidth = 0.4,
      linetype = "dashed"
    ) +
    ggplot2::scale_color_manual(
      values = c(down = down_color, ns = ns_color, up = up_color),
      drop = FALSE,
      name = NULL,
      labels = c(down = "Down", ns = "NS", up = "Up")
    ) +
    ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 7)) +
    ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 7)) +
    ggplot2::labs(x = "Log2FoldChange",
                  y = paste0("-log10(", if (identical(sig_used, "padj"))
                    "Adjusted P"
                    else
                      "P-value", ")")) +
    my_theme()
  p
}
