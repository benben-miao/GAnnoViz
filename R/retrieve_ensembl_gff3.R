#' @title Download GFF3 Annotation from Ensembl
#' @description Download \bold{\emph{GFF3}} annotation file from Ensembl database.
#' @author benben-miao
#'
#' @return A \bold{\emph{character}} string of the downloaded file absolute path.
#' @param species Species name (e.g., "mus_musculus", "homo_sapiens").
#' @param release Ensembl release version (e.g., 115).
#' @param only_chr Logical. If \code{TRUE}, download only chromosomes (chr). Default \code{TRUE}.
#' @param dest_dir Destination directory. Default is session temporary directory.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Download Human GFF3 (Chr only)
#' # gff_file <- retrieve_ensembl_gff3(
#' #   species = "homo_sapiens",
#' #   release = 115,
#' #   only_chr = TRUE,
#' #   dest_dir = tempdir())
#' }
#' 
retrieve_ensembl_gff3 <- function(
    species = "mus_musculus",
    release = 115,
    only_chr = TRUE,
    dest_dir = tempdir()) {

  # Ensure destination directory exists
  if (!dir.exists(dest_dir)) {
    dir.create(dest_dir, recursive = TRUE)
  }

  # Format species name
  # URL path uses lowercase: mus_musculus
  species_lower <- tolower(species)
  # Filename prefix uses Capitalized: Mus_musculus
  species_cap <- paste0(toupper(substr(species_lower, 1, 1)), substr(species_lower, 2, nchar(species_lower)))

  # Directory URL for the species
  species_url <- sprintf(
    "https://ftp.ensembl.org/pub/release-%s/gff3/%s/",
    release,
    species_lower
  )

  message(sprintf("Checking available files at: %s", species_url))

  tryCatch({
    # Read file listing
    content <- readLines(species_url, warn = FALSE)
  }, error = function(e) {
    stop(sprintf("Failed to access species directory: %s", e$message))
  })

  # Define regex pattern to match files
  # Pattern: Species.Assembly.Release[.chr].gff3.gz
  # We want to match the Assembly part dynamically
  # Example: Mus_musculus.GRCm39.115.chr.gff3.gz
  
  # Base pattern for the filename
  # ^Mus_musculus\..+\.115
  pattern_prefix <- sprintf("^%s\\..+\\.%s", species_cap, release)
  
  # Extract all href links that match the prefix and end with .gff3.gz
  # Regex: href="FILENAME"
  # We extract FILENAME
  files <- unique(na.omit(stringr::str_extract(content, '(?<=href=")[^"]+\\.gff3\\.gz(?=")')))
  
  # Filter based on pattern
  # Must start with Species.
  valid_files <- files[grepl(pattern_prefix, files)]
  
  if (length(valid_files) == 0) {
    stop(sprintf("No matching GFF3 files found for %s (release %s).", species, release))
  }

  # Filter based on only_chr
  if (isTRUE(only_chr)) {
    # Match files containing ".chr."
    # e.g. Mus_musculus.GRCm39.115.chr.gff3.gz
    target_files <- valid_files[grepl("\\.chr\\.gff3\\.gz$", valid_files)]
  } else {
    # Match files ending in .gff3.gz but NOT .chr.gff3.gz, .abinitio., .chromosome.
    # Usually the main file is Species.Assembly.Release.gff3.gz
    # So it shouldn't have extra dots fields after Release except gff3.gz
    # Wait, the format is Species.Assembly.Release.gff3.gz
    # Other files: Species.Assembly.Release.abinitio.gff3.gz
    
    # Let's exclude specific keywords
    exclude_patterns <- c("\\.chr\\.gff3\\.gz$", "\\.abinitio\\.gff3\\.gz$", "\\.chromosome\\.")
    
    target_files <- valid_files
    for (p in exclude_patterns) {
      target_files <- target_files[!grepl(p, target_files)]
    }
  }

  if (length(target_files) == 0) {
    stop("No suitable GFF3 file found matching criteria.")
  }

  # If multiple files remain (unlikely for standard structure but possible), pick the shortest one (usually the main assembly)
  # or just the first one.
  target_file <- target_files[which.min(nchar(target_files))]
  
  message(sprintf("Identified file: %s", target_file))

  # Construct full download URL
  url <- paste0(species_url, target_file)
  dest_path <- file.path(dest_dir, target_file)

  # Download
  message(sprintf("Downloading from: %s", url))
  message(sprintf("Saving to: %s", dest_path))

  tryCatch({
    # Use mode = "wb" for binary files (gzip) to ensure Windows compatibility
    utils::download.file(url, dest_path, mode = "wb")
  }, error = function(e) {
    stop(sprintf("Download failed: %s", e$message))
  })

  # Return absolute path
  return(normalizePath(dest_path, winslash = "/", mustWork = FALSE))
}
