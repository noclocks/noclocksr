`%||%` <- function (x, y) { if (is.null(x)) y else x }

is_windows <- function() {
  tolower(
    Sys.info()[["sysname"]]
  ) == "windows"
}

is.oauth_app <- function(x) {
  inherits(x, "oauth_app")
}

