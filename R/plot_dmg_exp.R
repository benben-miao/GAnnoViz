#' @title Plot DMGs hyper/hypo along chromosomes
#' @description Plot \bold{\emph{DMGs hyper/hypo}} along chromosomes.
#' @author benben-miao
#'
#' @return A \bold{\emph{ggplot object}} visualizing DMGs along chromosomes.
#' @param dmr_file DEG table from \bold{\emph{MethylKit}} analysis.
#' @param orientation Coordinate orientation. (\bold{\emph{"horizontal"}}, "vertical").
#' @param chrom_alpha Chromosome bar alpha. (\bold{\emph{0.1}}).
#' @param chrom_color Chromosome bar color. (\bold{\emph{"#008888"}}).
#' @param bar_height Chromosome bar thickness. (\bold{\emph{0.8}}).
#' @param point_size Point size. (\bold{\emph{1}}).
#' @param point_alpha Point alpha. (\bold{\emph{0.3}}).
#' @param hyper_color Color for hyper-methylated. (\bold{\emph{"#ff0000"}}).
#' @param hypo_color Color for hypo-methylated. (\bold{\emph{"#008800"}}).
#' @param mark_style Marker style for DMGs. (\bold{\emph{"point"}}, "line").
#' @param line_width Line width when \code{mark_style="line"}. (\bold{\emph{0.6}}).
#' @param line_height Line height relative to bar radius. (\bold{\emph{0.8}}).
#'
#' @importFrom magrittr %>%
#' @export
#'
#' @examples
#' # DMR results
#' dmr_file <- system.file(
#'   "extdata",
#'   "example.dmr",
#'   package = "GAnnoViz")
#'
#' # Plot DMG expression
#' plot_dmg_exp(
#'   dmr_file = dmr_file,
#'   orientation = "horizontal",
#'   chrom_alpha = 0.1,
#'   chrom_color = "#008888",
#'   point_size = 1,
#'   point_alpha = 0.3,
#'   hyper_color = "#ff0000",
#'   hypo_color = "#008800",
#'   mark_style = "point",
#'   line_width = 0.6,
#'   line_height = 0.8)
#'
plot_dmg_exp <- function(dmr_file,
                         orientation = "horizontal",
                         chrom_alpha = 0.1,
                         chrom_color = "#008888",
                         bar_height = 0.8,
                         point_size = 1,
                         point_alpha = 0.3,
                         hyper_color = "#ff0000",
                         hypo_color = "#008800",
                         mark_style = c("point", "line"),
                         line_width = 0.6,
                         line_height = 0.8) {
  # DMR results
  mark_style <- match.arg(mark_style)
  dmr <- utils::read.table(
    dmr_file,
    header = TRUE,
    sep = "\t",
    fill = TRUE,
    na.strings = "NA",
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  cols <- colnames(dmr)
  needed <- c("chr", "start", "meth.diff")
  missing <- setdiff(needed, cols)
  if (length(missing) > 0)
    stop(paste0("Missing required columns: ", paste(missing, collapse = ", ")))
  dmr <- dmr[stats::complete.cases(dmr$chr, dmr$start, dmr$meth.diff), , drop = FALSE]
  if (nrow(dmr) == 0)
    stop("No DMGs with valid positions found")

  # Chromosomes
  chrom_raw <- as.character(dmr$chr)
  chr_prefix <- any(stringr::str_detect(chrom_raw, "^(?i)chr"))
  keep_mask <- if (chr_prefix)
    stringr::str_detect(chrom_raw, "^(?i)chr")
  else
    rep(TRUE, length(chrom_raw))
  dmr <- dmr[keep_mask, , drop = FALSE]
  if (nrow(dmr) == 0)
    stop("No DMGs found on selected chromosomes")
  end_col <- if ("end" %in% colnames(dmr))
    dmr$end
  else
    dmr$start
  dmr$pos <- if ("end" %in% colnames(dmr))
    (dmr$start + dmr$end) / 2
  else
    dmr$start
  chrom_chr <- as.character(dmr$chr)
  chrom_num <- stringr::str_extract(chrom_chr, "\\d+")
  suppressWarnings({
    chrom_num <- as.numeric(chrom_num)
  })
  order_index <- order(is.na(chrom_num), chrom_num, chrom_chr)
  chrom_levels <- unique(chrom_chr[order_index])
  length_map <- stats::aggregate(end_col ~ chr,
                                 data = data.frame(chr = dmr$chr, end_col = end_col),
                                 FUN = max)
  length_map <- length_map[match(chrom_levels, length_map$chr), , drop = FALSE]
  length_map$y <- seq_along(chrom_levels)
  length_map$ymin <- length_map$y - bar_height / 2
  length_map$ymax <- length_map$y + bar_height / 2
  dmr$y <- length_map$y[match(dmr$chr, length_map$chr)]
  dmr$state <- ifelse(dmr$meth.diff >= 0, "hyper", "hypo")
  col_map <- c(hyper = hyper_color, hypo = hypo_color)

  # Plot
  p <- ggplot2::ggplot() +
    ggplot2::geom_rect(
      data = length_map,
      ggplot2::aes(
        xmin = 0,
        xmax = end_col,
        ymin = ymin,
        ymax = ymax
      ),
      fill = chrom_color,
      color = NA,
      alpha = chrom_alpha
    ) +
    {
      if (identical(mark_style, "point")) {
        ggplot2::geom_point(
          data = dmr,
          ggplot2::aes(x = pos, y = y, color = state),
          size = point_size,
          alpha = point_alpha
        )
      } else {
        h <- bar_height * line_height / 2
        dmr$y1 <- dmr$y - h
        dmr$y2 <- dmr$y + h
        ggplot2::geom_segment(
          data = dmr,
          ggplot2::aes(
            x = pos,
            xend = pos,
            y = y1,
            yend = y2,
            color = state
          ),
          linewidth = line_width,
          lineend = "round",
          alpha = point_alpha
        )
      }
    } +
    ggplot2::scale_color_manual(
      values = col_map,
      drop = FALSE,
      name = NULL,
      labels = c(hypo = "Hypo", hyper = "Hyper")
    ) +
    ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 8)) +
    ggplot2::scale_y_continuous(
      breaks = length_map$y,
      labels = chrom_levels,
      expand = ggplot2::expansion(mult = c(0.05, 0.05))
    ) +
    ggplot2::labs(x = "Genomic position", y = "Chromosome") +
    my_theme()
  if (orientation == "horizontal")
    p <- p + ggplot2::coord_flip()
  p
}
