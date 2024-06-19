#' `.gitignore` Templates
#'
#' @description
#' Get `.gitignore` templates from [Toptal](https://www.toptal.com/developers/gitignore).
#'
#' @param template (character) The name of the `.gitignore` template
#' @param as (character) The format to return the `.gitignore` template. Can be
#'   `list` or `json`. Default is `list`.
#'
#' @return The `.gitignore` template as a list or JSON
#' @export
#'
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
get_gitignore <- function(template, as = c("list", "json")) {

  gitignore_includes <- c(
    "secrets",
    "windows",
    "r",
    "python",
    "node",
    "markdown"
  )

  if (!template %in% gitignore_templates) {
    stop("Invalid gitignore template")
  }

  base_url <- "https://www.toptal.com/developers/gitignore/api/"
  url <- paste0(base_url, template)
  ignore <- httr::content(httr::GET(url), as = "text")

  if (as == "list") {
    ignore
  } else if (as == "json") {
    jsonlite::fromJSON(ignore)
  }
}

#' Add `.gitignore` Templates
#'
#' @param includes (character) The `.gitignore` templates to include
#' @param path (character) The path to the `.gitignore` file. Default is `getwd()`
#' @param ... Additional arguments
#'
#' @return The `.gitignore` file with the templates included
#' @export
#'
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
add_gitignore <- function(includes, path = getwd(), ...) {

  gitignore_file <- file.path(path, ".gitignore")
  if (!file.exists(gitignore_file)) {
    writeLines("", gitignore_file)
  }

  base_url <- "https://www.toptal.com/developers/gitignore/api/"
  ignores <- list
  i <- 0

  for (include in includes) {
    i <- i + 1
    url <- paste0(base_url, include)
    ignore <- httr::content(httr::GET(url), as = "text")
    ignores[[i]] <- ignore
    names(ignores[i]) <- include
    # writeLines(ignore, gitignore_file)
  }

  gitignore <- readLines(gitignore_file)
  # to_ignore <-

}
