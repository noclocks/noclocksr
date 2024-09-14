#' Startup Functions
#'
#' @description
#' These functions are run when the package is loaded or attached.

.onAttach <- function(
    libname = find.package("noclocksr"),
    pkgname = "noclocksr"
) {

  vers <- as.character(utils::packageVersion(pkgname))
  msg <- sprintf(
    "Welcome to `noclocksr`! This is version: %s\n",
    vers
  )

  if (interactive()) {
    packageStartupMessage(msg)
  }

  # force the use of HTTP/2
  httr::set_config(httr::config(http_version = 2))

}

#' @importFrom gargle gargle_oauth_client_from_json init_AuthState
#' @importFrom fs path_package
#' @importFrom pkgload pkg_name
#' @importFrom utils assignInMyNamespace
.onLoad <- function(libname, pkgname) {

  # oauth_client <- gargle::gargle_oauth_client_from_json(
  #   path = fs::path_package(
  #     pkgload::pkg_name(),
  #     "inst/config/noclocksr-oauth-client.json"
  #   )
  # )
  #
  # .auth_env <<- rlang::env(
  #   auth_state = gargle::init_AuthState(
  #     package = "noclocksr",
  #     client = oauth_client,
  #     auth_active = TRUE
  #   )
  # )

}

# .auth_env <- NULL
# Load the auth state
# if (!exists(".auth_env", envir = .GlobalEnv)) {
#   source("onLoad.R")
# }


