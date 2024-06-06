## code to prepare `gitignore_templates` dataset goes here

gitignore_template_names <- httr::GET("https://www.toptal.com/developers/gitignore/api/list?format=lines") |>
  httr::content(as = "text") |>
  strsplit("\n") |>
  unlist()

get_gitignore_template_contents <- function(template) {
  base_url <- "https://www.toptal.com/developers/gitignore/api/"
  url <- paste0(base_url, template)
  httr::GET(url) |> httr::content(as = "text")
}

.cache <- memoise::cache_filesystem("data-raw/cache")

mem_get_gitignore_template_contents <- memoise::memoise(
  get_gitignore_template_contents,
  cache = .cache
)

gitignore_template_contents <- purrr::map_chr(
  gitignore_template_names,
  mem_get_gitignore_template_contents,
  .progress = TRUE
)

gitignore_templates <- tibble::tibble(
  template = gitignore_template_names,
  content = gitignore_template_contents
)

usethis::use_data(gitignore_templates, overwrite = TRUE)

# purrr::map_chr(gitignore_template_names, ~ httr::GET(paste0("https://www.toptal.com/developers/gitignore/api/", .x)) |>
#                  httr::content(as = "text"))
