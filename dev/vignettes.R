
#  ------------------------------------------------------------------------
#
# Title : noclocksR Package Vignettes
#    By : Jimmy Briggs
#  Date : 2024-06-16
#
#  ------------------------------------------------------------------------

require(usethis)
require(devtools)
require(knitr)
require(markdown)
require(rmarkdown)


# vignettes ---------------------------------------------------------------

c(
  "noclocksR",
  "devenv",
  "pkgdevt",
  "shiny",
  "plumber",
  "about_branding",
  "about_theming",
  "about_colors",
  "integrations"
) |>
  purrr::walk(
    usethis::use_vignette
  )
