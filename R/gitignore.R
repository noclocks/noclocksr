gitignore_includes <- c(
  "secrets",
  "windows",
  "r",
  "python",
  "node",
  "markdown"
)



get_gitignore <- function(template, as = c("list", "json")) {

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
