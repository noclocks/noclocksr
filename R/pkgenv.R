#' @keywords internal
#' @noRd
.pkgenv <- new.env(parent = emptyenv())
.pkgenv$configs <- list()
.pkgenv$secrets <- list()
.pkgenv$completions <- list()
.pkgenv$paths <- list()
.pkgenv$auth <- NULL

#' @keywords internal
#' @noRd
find_pkgenv <- function() {
  names(
    which(
      sapply(
        loadedNamespaces(),
        function(x) {
          any(grepl("^.pkgenv$", ls(envir = asNamespace(x))))
        }
      )
    )
  )
}
