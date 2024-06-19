check_pkg_ns <- function(pkg, quiet = FALSE) {
  if (isFALSE(quiet)) {
    # with messages
    if (!isNamespaceLoaded(pkg)) {
      if (requireNamespace(pkg, quietly = FALSE)) {
        cat(paste0("Loading package: ", pkg, "\n"))
      } else {
        stop(paste0(pkg, " not available"))
      }
    } else {
      cat(paste0("Package ", pkg, " loaded\n"))
    }
  } else {
    # without messages
    if (!isNamespaceLoaded(pkg)) {
      if (requireNamespace(pkg, quietly = TRUE)) {
      } else {
        stop(paste0(pkg, " not available"))
      }
    }
  }
}
