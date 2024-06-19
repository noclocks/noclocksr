#' Get Favicon from a URL
#'
#' @description
#' This function retrieves the favicon from provided URL or vector of URLs.
#'
#' @param url A character vector of URLs.
#' @param out_file A single path to a folder to save the favicons, or a
#'   character vector of file paths to save each individual favicon to.
#' @param fallback (optional) function to fallback to if favicon is not found.
#'
#' @return A character vector of file paths to the favicons.
#'
#' @export
get_favicon <- function(
  url,
  out_file = NULL,
  fallback = get_favicon.ddg
) {

  if (is.null(out_file)) {
    out_file <- nullfile()
  }

  if (!is.character(url)) {
    rlang::abort("`url` must be a character vector.")
  }

  purrr::map_chr(url, ~{
    favicon_url <- get_favicon_ico(.x, out_file)
    if (is.null(favicon)) {
      favicon <- fallback(.x)
    }
    if (is.null(favicon)) {
      return(NULL)
    }
    if (is.null(out_file)) {
      return(favicon)
    }
    file_path <- fs::path(out_file, basename(favicon))
    utils::download.file(favicon, file_path, mode = "wb")
    return(file_path)
  })


}

read_html <- function(url) {
  xml2::read_html(url(url), silent = TRUE)
}

get_favicon <- function(url) {

  parsed_url <- httr2::url_parse(url)
  scheme <- parsed_url$scheme
  server <- parsed_url$server
  path <- parsed_url$path

  if (scheme == "file") {
    path <- fs::path_expand(path)
    raw <- read_html(path)
  } else {
    raw <- read_html(url)
  }

  xpath <- "/html/head/link[@rel = 'icon' or @rel = 'shortcut icon']"
  link_element <- xml2::xml_find_first(raw, xpath)
  href <- xml2::xml_attr(link_element, "href")
  if (is.na(href)) return("")

  base_element <- xml2::xml_find_first(raw, "/html/head/base")
  base_link <- xml2::xml_attr(base_element, "href")
  if (!is.na(base_link)) { href <- paste0(base_link, href) }

  return(href)
}

get_favicon.ddg <- function(url) {

  domain <- httr2::url_parse(url)$hostname

  if (is.null(domain)) {
    return(NULL)
  }

  paste0("https://icons.duckduckgo.com/ip3/", domain, ".ico")

}

get_favicon_ico <- function(
  url,
  path,
  method = getOption("download.file.method", "auto"),
  extra = getOption("download.file.extra", NULL),
  headers = NULL
) {

  favicon_url <- paste0(url, "/favicon.ico")

  res <- tryCatch(
    suppressWarnings(
      utils::download.file(
        url = favicon_url,
        destfile = path,
        method = method,
        quiet = TRUE,
        extra = extra,
        headers = headers
      )
    ),
    error = function(e) return(1)
  )

  if (res == 0) return(favicon_url) else return(NULL)

}

