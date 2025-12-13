#' @title Launch GAnnoViz Shiny application
#' @description Launch the \bold{\emph{GAnnoViz}} Shinyapp.
#'
#' @param host Host interface, e.g., \bold{\emph{"0.0.0.0"}} or "127.0.0.1".
#' @param port Port number, e.g., \bold{\emph{8888}}.
#' @param launch.browser Whether to launch in a browser. (\bold{\emph{TRUE}}).
#' @param ... Additional parameters passed to \bold{\emph{shiny::runApp}}.
#'
#' @export
#'
#' @examples
#' # GAnnoVizApp()
#'
GAnnoVizApp <- function(host = NULL,
						port = NULL,
						launch.browser = TRUE,
						...) {
	appDir <- system.file("shiny", package = "GAnnoViz")
	if (identical(appDir, "") || !dir.exists(appDir))
		stop("Shiny app directory not found in this package.")
	shiny::runApp(
		appDir,
		host = host,
		port = port,
		launch.browser = launch.browser,
		...
	)
}