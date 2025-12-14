suppressWarnings({
  g <- read.delim("inst/extdata/Mus_musculus.GRCm39.115.gff3", header = FALSE, sep = "\t", quote = "", comment.char = "#", stringsAsFactors = FALSE)
  genes <- g[g[[3]] == "gene", ]
  attrs <- genes[[9]]
  gid <- sub(".*ID=([^;]+).*", "\\1", attrs)
  genes[["id"]] <- gid
  chrs <- unique(genes[[1]])
  chrs <- chrs[grepl("^chr(\\d+|X|Y)$", chrs)]
  chrs <- setdiff(chrs, "chrM")
  deg <- read.delim("inst/extdata/example.deg", header = TRUE, sep = "\t", stringsAsFactors = FALSE)
  set.seed(42)
  target_total_deg <- 1500L
  chr_set <- sort(unique(genes[genes[[1]] %in% chrs, ][[1]]))
  high_chroms <- c("chr1", "chr11", "chr19", "chrX")
  low_chroms <- c("chr4", "chr5", "chr6")
  w_deg <- setNames(rep(1.0, length(chr_set)), chr_set)
  w_deg[intersect(high_chroms, chr_set)] <- 2.5
  w_deg[intersect(low_chroms, chr_set)] <- 0.5
  w_deg["chrY"] <- 2.0
  w_deg <- w_deg / sum(w_deg)
  per_chr_deg <- pmax(20L, as.integer(target_total_deg * w_deg))
  gene_pool <- genes[genes[[1]] %in% chr_set, ]
  pick_deg <- function(ch, count, pool) {
    gi <- pool[pool[[1]] == ch, , drop = FALSE]
    if (nrow(gi) == 0) return(character(0))
    ids <- unique(gi[["id"]])
    if (length(ids) <= count) return(ids)
    sample(ids, count)
  }
  sel_ids <- unlist(lapply(seq_along(chr_set), function(i) pick_deg(chr_set[i], per_chr_deg[i], gene_pool)), use.names = FALSE)
  sel_ids <- unique(sel_ids)
  n_deg <- length(sel_ids)
  baseMean <- pmax(1L, round(rlnorm(n_deg, log(20000), 0.7)))
  id_to_chr_idx <- match(sel_ids, gene_pool[["id"]])
  id_chr <- gene_pool[[1]][id_to_chr_idx]
  small_frac <- ifelse(id_chr %in% high_chroms, 0.75, ifelse(id_chr %in% low_chroms, 0.95, 0.85))
  is_small <- runif(n_deg) < small_frac
  lfc_sd <- ifelse(is_small, runif(n_deg, 0.3, 0.9), runif(n_deg, 2.2, 4.8))
  log2FoldChange <- stats::rnorm(n_deg, mean = 0, sd = lfc_sd)
  log2FoldChange[id_chr %in% high_chroms] <- log2FoldChange[id_chr %in% high_chroms] + stats::rnorm(sum(id_chr %in% high_chroms), 0.15, 0.10)
  log2FoldChange[id_chr %in% low_chroms] <- log2FoldChange[id_chr %in% low_chroms] + stats::rnorm(sum(id_chr %in% low_chroms), -0.10, 0.10)
  log2FoldChange <- pmax(pmin(log2FoldChange, 6.0), -6.0)
  low_mask <- abs(log2FoldChange) < 1
  if (any(low_mask)) {
    nlow <- sum(low_mask)
    sgn <- ifelse(log2FoldChange[low_mask] >= 0, 1, -1)
    sgn[sgn == 0] <- sample(c(-1, 1), sum(sgn == 0), replace = TRUE)
    mag <- ifelse(is_small[low_mask],
                  stats::runif(nlow, 1.0, 1.8),
                  stats::runif(nlow, 2.2, 4.8))
    log2FoldChange[low_mask] <- sgn * mag
  }
  log2FoldChange <- pmax(pmin(log2FoldChange, 6.0), -6.0)
  mu_se <- 0.45 / pmax(1, sqrt(baseMean / 20000))
  lfcSE <- pmax(0.15, stats::rnorm(n_deg, mean = mu_se, sd = 0.08))
  stat <- log2FoldChange / lfcSE
  pvalue_num <- 2 * stats::pnorm(abs(stat), lower.tail = FALSE)
  pvalue_num <- pmax(pvalue_num, .Machine$double.xmin)
  padj_num <- stats::p.adjust(pvalue_num, method = "BH")
  pvalue <- pvalue_num
  padj <- padj_num
  deg_new <- data.frame(GeneID = sel_ids, baseMean = baseMean, log2FoldChange = log2FoldChange, lfcSE = lfcSE, stat = stat, pvalue = pvalue, padj = padj, check.names = FALSE, stringsAsFactors = FALSE)
  write.table(deg_new, file = "inst/extdata/example.deg", sep = "\t", quote = FALSE, row.names = FALSE)
  deg_ids <- deg_new[[1]]
  genes_deg <- genes[genes[["id"]] %in% deg_ids & genes[[1]] %in% chrs, ]

  target_total <- 3000L
  chr_set <- sort(unique(genes_deg[[1]]))
  w_dmr <- setNames(rep(1.0, length(chr_set)), chr_set)
  w_dmr[intersect(high_chroms, chr_set)] <- 2.2
  w_dmr[intersect(low_chroms, chr_set)] <- 0.6
  w_dmr["chrY"] <- 1.8
  w_dmr <- w_dmr / sum(w_dmr)
  per_chr <- pmax(50L, as.integer(target_total * w_dmr))

  pick_dmr <- function(ch, count, used) {
    gi <- genes_deg[genes_deg[[1]] == ch, , drop = FALSE]
    res <- list()
    tries <- 0L
    while (length(res) < count && tries < count * 50) {
      tries <- tries + 1L
      if (nrow(gi) == 0) break
      row <- gi[sample.int(nrow(gi), 1L), ]
      s <- as.integer(row[[4]])
      e <- as.integer(row[[5]])
      if (is.na(s) || is.na(e) || e <= s) next
      pos <- sample(seq.int(s, e), 1L)
      ws <- floor((pos - 1) / 2000) * 2000 + 1L
      we <- ws + 1999L
      if (ws %in% used[[ch]]) next
      adj <- c(ws - 2000L, ws + 2000L)
      if (any(adj %in% used[[ch]])) next
      used[[ch]] <- c(used[[ch]], ws)
      pv <- sample(c("1E-06", "1E-07", "1E-08", "1E-09"), 1L, prob = if (ch %in% high_chroms) c(0.30, 0.30, 0.25, 0.15) else if (ch %in% low_chroms) c(0.70, 0.20, 0.06, 0.04) else c(0.60, 0.25, 0.10, 0.05))
      qv <- if (ch %in% high_chroms) sprintf("%.6f", runif(1L, 0.001, 0.012)) else if (ch %in% low_chroms) sprintf("%.6f", runif(1L, 0.016, 0.020)) else if (runif(1L) < 0.8) sprintf("%.6f", runif(1L, 0.015, 0.020)) else sprintf("%.6f", runif(1L, 0.001, 0.010))
      md <- if (ch %in% high_chroms) sprintf("%.3f", round(runif(1L, 45.000, 100.000) * sample(c(-1, 1), 1L), 3)) else if (ch %in% low_chroms) sprintf("%.3f", round(runif(1L, 25.001, 40.000) * sample(c(-1, 1), 1L), 3)) else if (runif(1L) < 0.85) sprintf("%.3f", round(runif(1L, 25.001, 45.000) * sample(c(-1, 1), 1L), 3)) else sprintf("%.3f", round(runif(1L, 60.000, 100.000) * sample(c(-1, 1), 1L), 3))
      res[[length(res) + 1L]] <- data.frame(chr = ch, start = ws, end = we, strand = "*", pvalue = pv, qvalue = qv, meth.diff = md, check.names = FALSE, stringsAsFactors = FALSE)
    }
    if (length(res) == 0) return(list(df = NULL, used = used))
    df <- do.call(rbind, res)
    return(list(df = df, used = used))
  }

  used <- setNames(rep(list(integer(0)), length(chr_set)), chr_set)
  dmr_list <- list()
  for (i in seq_along(chr_set)) {
    ch <- chr_set[i]
    out <- pick_dmr(ch, per_chr[i], used)
    used <- out$used
    if (!is.null(out$df)) dmr_list[[length(dmr_list) + 1L]] <- out$df
  }
  dmr <- do.call(rbind, dmr_list)
  dmr <- dmr[order(dmr[["chr"]], dmr[["start"]]), ]
  write.table(dmr, file = "inst/extdata/example.dmr", sep = "\t", quote = FALSE, row.names = FALSE)

  avg_line <- 35
  target_bytes <- 8.2e6
  target_lines <- as.integer(target_bytes / avg_line)
  target_lines <- max(10000L, target_lines)
  chr_max <- tapply(as.integer(g[g[[1]] %in% chr_set, ][[5]]), g[g[[1]] %in% chr_set, ][[1]], max, na.rm = TRUE)
  w <- setNames(rep(1.0, length(chr_set)), chr_set)
  w["chr19"] <- 1.3
  w["chrX"] <- 1.3
  w["chrY"] <- 1.0
  w <- w / sum(w)
  per_chr_fst <- pmax(1000L, as.integer(target_lines * w))

  pick_fst <- function(ch, count, used) {
    chr_len <- as.integer(chr_max[[ch]])
    if (is.na(chr_len) || chr_len < 20000L) return(list(df = NULL, used = used))
    nbins <- as.integer(chr_len %/% 10000L)
    need <- count
    parity <- sample(c(0L, 1L), 1L)
    cands <- seq.int(1L + parity, nbins, by = 2L)
    gi <- genes_deg[genes_deg[[1]] == ch, , drop = FALSE]
    gq <- as.integer(need * 0.1)
    gbs <- integer(0)
    if (nrow(gi) > 0 && gq > 0) {
      pos <- as.integer(gi[[4]]) + floor((as.integer(gi[[5]]) - as.integer(gi[[4]])) / 2L)
      idx <- pmax(1L, pmin(nbins, as.integer((pos - 1L) %/% 10000L) + 1L))
      gbs <- unique(idx[idx %in% cands])
      if (length(gbs) > gq) gbs <- sample(gbs, gq)
    }
    rem <- need - length(gbs)
    if (rem <= 0) picked <- gbs else {
      pool <- setdiff(cands, gbs)
      if (length(pool) == 0) picked <- gbs else picked <- c(gbs, sample(pool, min(rem, length(pool))))
    }
    if (length(picked) == 0) return(list(df = NULL, used = used))
    bs <- (picked - 1L) * 10000L + 1L
    bs <- bs[!(bs %in% used[[ch]] | (bs - 10000L) %in% used[[ch]] | (bs + 10000L) %in% used[[ch]])]
    bs <- bs[seq_len(min(length(bs), need))]
    used[[ch]] <- c(used[[ch]], bs)
    be <- bs + 9999L
    nv <- sample(100:999, length(bs), replace = TRUE)
    wf_num <- runif(length(bs), -0.02, 0.06)
    hi_n <- ceiling(length(bs) * 0.03)
    if (hi_n > 0) {
      hi_idx <- sample(seq_len(length(bs)), hi_n)
      wf_num[hi_idx] <- runif(hi_n, 0.2, 0.8)
    }
    mf_num <- wf_num + rnorm(length(bs), 0, 0.005)
    wf <- sprintf("%.12f", wf_num)
    mf <- sprintf("%.12f", mf_num)
    df <- data.frame(CHROM = ch, BIN_START = bs, BIN_END = be, N_VARIANTS = nv, WEIGHTED_FST = wf, MEAN_FST = mf, check.names = FALSE, stringsAsFactors = FALSE)
    return(list(df = df, used = used))
  }

  used_f <- setNames(rep(list(integer(0)), length(chr_set)), chr_set)
  fst_list <- list()
  for (i in seq_along(chr_set)) {
    ch <- chr_set[i]
    out <- pick_fst(ch, per_chr_fst[i], used_f)
    used_f <- out$used
    if (!is.null(out$df)) fst_list[[length(fst_list) + 1L]] <- out$df
  }
  fst <- do.call(rbind, fst_list)
  fst <- fst[order(fst[["CHROM"]], fst[["BIN_START"]]), ]
  write.table(fst, file = "inst/extdata/example.fst", sep = "\t", quote = FALSE, row.names = FALSE)

  size_f <- file.info("inst/extdata/example.fst")$size
  size_d <- file.info("inst/extdata/example.dmr")$size
  cat("example.fst size bytes:", size_f, "\n")
  cat("example.dmr rows:", nrow(dmr), "\n")
  cat("FST rows:", nrow(fst), "\n")
})
