#' @title List Supported Species from Ensembl
#' @description List supported species and their IDs from Ensembl GFF3 FTP directory.
#' @author benben-miao
#'
#' @return A \bold{\emph{data.frame}} with two columns: \code{Species} (formatted name) and \code{ID} (folder name).
#' @param release Ensembl release version (e.g., 115).
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # List species for release 115
#' species_df <- retrieve_ensembl_species(release = 115)
#' head(species_df)
#' }
#' 
retrieve_ensembl_species <- function(release = 115) {
  # Base URL for the release
  base_url <- sprintf("https://ftp.ensembl.org/pub/release-%s/gff3/", release)

  message(sprintf("Fetching species list from: %s", base_url))

  tryCatch({
    # Read directory listing
    # This retrieves the HTML content of the directory listing
    content <- readLines(base_url, warn = FALSE)

    # Extract folder names (species IDs)
    # Pattern looks for href="species_name/"
    # We ignore parent directory links (starts with / or ..)
    # The IDs are typically lowercase strings with underscores
    ids <- unique(na.omit(stringr::str_extract(content, '(?<=href=")[a-z0-9_]+(?=/"?)')))

    # Filter out common non-species directories if any (though regex above is restrictive)
    # Usually directories like 'current_README' might exist but the regex expects lowercase/underscore
    
    if (length(ids) == 0) {
      stop("No species found. Check network connection or release version.")
    }

    # Format Species Names from IDs
    # e.g., mus_musculus -> Mus musculus
    species_names <- sapply(ids, function(x) {
      parts <- unlist(strsplit(x, "_"))
      parts <- paste0(toupper(substr(parts, 1, 1)), substr(parts, 2, nchar(parts)))
      paste(parts, collapse = " ")
    })

    # Return data frame
    return(data.frame(
      Species = unname(species_names),
      ID = unname(ids),
      stringsAsFactors = FALSE
    ))

  }, error = function(e) {
    stop(sprintf("Failed to list species: %s", e$message))
  })
}