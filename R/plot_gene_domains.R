#' @title Plot protein domains from Ensembl
#' @description Plot \bold{\emph{protein domains}} from Ensembl.
#' @author benben-miao
#'
#' @return Plot of \bold{\emph{protein domains}}.
#' @param gene_name Official gene symbol. (\bold{\emph{"TP53"}}).
#' @param species Species in BioMart format. (\bold{\emph{"hsapiens"}}, "mmusculus").
#' @param transcript_id Ensembl transcript ID. (\bold{\emph{"ENST00000269305"}}).
#' @param transcript_choice Transcript choice. (\bold{\emph{"longest"}}, "canonical").
#' @param palette Color palette. (\bold{\emph{"Set 2"}}, "Set 2", "Set 3", "Warm", "Cold", "Dynamic", "Viridis", "Plasma", "Inferno", "Rocket", "Mako").
#' @param legend_ncol Legend columns per row. (\bold{\emph{2}}).
#' @param return_data Plot and data. (\bold{\emph{TRUE}}).
#'
#' @export
#'
#' @examples
#' # Plot TP53 domian
#' res <- plot_gene_domains(
#'   gene_name = "TP53",
#'   species = "hsapiens",
#'   transcript_id = NULL,
#'   transcript_choice = "longest",
#'   palette = "Set 2",
#'   legend_ncol = 2,
#'   return_data = TRUE)
#'
#' res$plot
#' head(res$domain_data)
#'
plot_gene_domains <- function(gene_name = NULL,
                              species = "hsapiens",
                              transcript_id = NULL,
                              transcript_choice = "longest",
                              palette = "Set 2",
                              legend_ncol = 2,
                              return_data = FALSE) {
  transcript_choice <- match.arg(transcript_choice)

  # Connect to Ensembl
  ensembl <- tryCatch({
    biomaRt::useMart("ensembl", dataset = paste0(species, "_gene_ensembl"))
  }, error = function(e) {
    stop("Failed to connect to Ensembl BioMart. Check internet or species name.")
  })

  # Step 1: Get transcript(s) — transcript-level attributes only
  if (!is.null(transcript_id)) {
    tx_meta <- biomaRt::getBM(
      attributes = c("ensembl_transcript_id", "external_gene_name"),
      filters = "ensembl_transcript_id",
      values = transcript_id,
      mart = ensembl
    )
    if (nrow(tx_meta) == 0)
      stop("Transcript not found: ", transcript_id)
    gene_used <- tx_meta$external_gene_name[1]
    candidate_tx <- transcript_id

  } else if (!is.null(gene_name)) {
    tx_meta <- biomaRt::getBM(
      attributes = c(
        "ensembl_transcript_id",
        "external_gene_name",
        "transcript_gencode_basic"
      ),
      filters = "external_gene_name",
      values = gene_name,
      mart = ensembl
    )
    if (nrow(tx_meta) == 0) {
      stop("Gene '",
           gene_name,
           "' not found in Ensembl for species '",
           species,
           "'.")
    }
    gene_used <- gene_name
    candidate_tx <- tx_meta$ensembl_transcript_id

    if (transcript_choice == "canonical") {
      canonical_tx <- tx_meta$ensembl_transcript_id[!is.na(tx_meta$transcript_gencode_basic)]
      if (length(canonical_tx) > 0) {
        candidate_tx <- canonical_tx[1]
      } else {
        message("No canonical transcript found; using longest CDS.")
      }
    }
  } else {
    stop("Either 'gene_name' or 'transcript_id' must be provided.")
  }

  # Step 2: Get protein info (separate query to avoid attribute page conflict)
  prot_info <- biomaRt::getBM(
    attributes = c(
      "ensembl_transcript_id",
      "ensembl_peptide_id",
      "cds_length"
    ),
    filters = "ensembl_transcript_id",
    values = if (length(candidate_tx) > 1)
      candidate_tx
    else
      as.character(candidate_tx),
    mart = ensembl
  )

  prot_info <- prot_info[!is.na(prot_info$ensembl_peptide_id) &
                           prot_info$cds_length > 0, , drop = FALSE]

  if (nrow(prot_info) == 0) {
    stop("No protein-coding transcripts found for the input.")
  }

  if (transcript_choice == "longest" || nrow(prot_info) > 1) {
    prot_info <- prot_info[order(-as.numeric(prot_info$cds_length)), , drop = FALSE]
  }
  selected <- prot_info[1, , drop = FALSE]

  transcript_used <- selected$ensembl_transcript_id
  peptide_id <- selected$ensembl_peptide_id
  protein_length <- as.numeric(selected$cds_length) / 3

  # Step 3: Fetch domains
  domain_data_raw <- tryCatch({
    biomaRt::getBM(
      attributes = c(
        "interpro_description",
        "interpro_short_description",
        "interpro_start",
        "interpro_end"
      ),
      filters = "ensembl_peptide_id",
      values = peptide_id,
      mart = ensembl
    )
  }, error = function(e) {
    message("Warning: Failed to retrieve domain data. Showing backbone only.")
    data.frame(
      interpro_description = character(0),
      interpro_short_description = character(0),
      interpro_start = numeric(0),
      interpro_end = numeric(0),
      stringsAsFactors = FALSE
    )
  })

  # Clean domain data
  if (nrow(domain_data_raw) > 0) {
    domain_data <- data.frame(
      domain = ifelse(
        is.na(domain_data_raw$interpro_description) |
          domain_data_raw$interpro_description == "",
        domain_data_raw$interpro_short_description,
        domain_data_raw$interpro_description
      ),
      start = as.numeric(domain_data_raw$interpro_start),
      end = as.numeric(domain_data_raw$interpro_end),
      stringsAsFactors = FALSE
    )
    domain_data <- domain_data[!is.na(domain_data$start) &
                                 !is.na(domain_data$end) &
                                 domain_data$start <= domain_data$end, , drop = FALSE]
  } else {
    domain_data <- data.frame(
      domain = character(0),
      start = numeric(0),
      end = numeric(0),
      stringsAsFactors = FALSE
    )
  }

  # Build plot data
  plot_df <- data.frame(
    domain = "Full protein",
    start = 1,
    end = protein_length,
    type = "backbone",
    stringsAsFactors = FALSE
  )

  if (nrow(domain_data) > 0) {
    domain_data$type <- "domain"
    plot_df <- rbind(plot_df, domain_data)
  }

  # Color palette
  unique_domains <- unique(plot_df$domain)
  n_extra <- max(0, length(unique_domains) - 1)

  if (n_extra > 0) {
    pal <- grDevices::hcl.colors(n = n_extra, palette = palette)
    names(pal) <- unique_domains[-1]
    fill_vals <- c("Full protein" = "lightgray", pal)
  } else {
    fill_vals <- c("Full protein" = "lightgray")
  }

  # Prepare y-bounds for rectangles
  plot_df$type <- factor(plot_df$type, levels = c("backbone", "domain"))
  plot_df$y <- as.numeric(plot_df$type)
  plot_df$ymin <- plot_df$y - 0.3
  plot_df$ymax <- plot_df$y + 0.3

  # Create plot
  p <- ggplot2::ggplot(plot_df,
                       ggplot2::aes(
                         xmin = start,
                         xmax = end,
                         ymin = ymin,
                         ymax = ymax,
                         fill = domain
                       )) +
    ggplot2::geom_rect(color = "black", alpha = 0.85) +
    ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 10), name = "Amino acid position") +
    ggplot2::scale_y_continuous(
      breaks = c(1, 2),
      labels = c("Backbone", "Domain"),
      expand = ggplot2::expansion(add = c(0.4, 0.8))
    ) +
    ggplot2::scale_fill_manual(values = fill_vals, drop = FALSE) +
    ggplot2::labs(fill = "Domain") +
    my_theme()

  if (TRUE && nrow(domain_data) > 0) {
    p <- p +
      ggplot2::theme(legend.position = "bottom", legend.box = "horizontal") +
      ggplot2::guides(fill = ggplot2::guide_legend(ncol = legend_ncol))
  } else {
    p <- p + ggplot2::theme(legend.position = "none")
  }

  if (TRUE) {
    p <- p + ggplot2::labs(
      title = paste("Protein Domains of", gene_used),
      subtitle = paste("Transcript:", transcript_used)
    ) +
      ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))
  }

  p <- p + ggplot2::coord_cartesian(ylim = c(0.5, 2.8))

  if (return_data) {
    list(
      plot = p,
      domain_data = domain_data,
      transcript_id = transcript_used,
      protein_length = protein_length,
      plot_df = plot_df
    )
  } else {
    p
  }
}
