
#  ------------------------------------------------------------------------
#
# Title : noclocksR Package Development Script
#    By : Jimmy Briggs
#  Date : 2024-02-07
#
#  ------------------------------------------------------------------------


# libraries ---------------------------------------------------------------

require(devtools)
require(usethis)
require(roxygen2)
require(testthat)
require(fusen)
require(lozen)
require(attachment)
require(gitdown)
require(testdown)

# pak::pak(c("covr", "codemetar", "pkgdown", "pagedown", "bookdown", "rmarkdown"))
# pak::pak("ThinkR-open/lozen")
# pak::pak("ThinkR-open/fusen")
# pak::pak("ThinkR-open/gitdown")
# pak::pak("ThinkR-open/testdown")

usethis::use_data_raw("gitignore_templates")
usethis::use_data_raw("client_demo_data")

# initialize --------------------------------------------------------------

usethis::create_package("noclocksR")
usethis::use_namespace()
usethis::use_roxygen_md()
usethis::use_git()
usethis::use_github(
  organization = "noclocks",
  private = FALSE
)
usethis::use_package_doc()
usethis::use_tibble() # #' @return a [tibble][tibble::tibble-package]
devtools::document()


# files & folders ---------------------------------------------------------

usethis::use_build_ignore("dev")
usethis::use_build_ignore("examples")

c(
  "inst",
  "inst/assets",
  "inst/assets/images",
  "inst/assets/css",
  "inst/assets/js",
  "inst/assets/fonts",
  "inst/templates",
  "inst/rstudio",
  "inst/extdata",
  "inst/shiny",
  "inst/shiny/www",
  "inst/plumber",
  "inst/scripts",
  "dev",
  "data-raw",
  "data-raw/scripts",
  ""
) |>
  purrr::walk(fs::dir_create)

file.create("CHANGELOG.md")

usethis::use_readme_rmd()
usethis::use_lifecycle_badge("Experimental")
usethis::use_logo("inst/assets/images/main-logo-white.png")
usethis::use_badge(
  "Project Status: WIP",
  href = "http://www.repostatus.org/#wip",
  src = "https://www.repostatus.org/badges/latest/wip.svg"
)
knitr::knit("README.Rmd")
library(templateeR)

templateeR::use_gh_labels()
templateeR::use_git_cliff()
templateeR::use_git_cliff_action("changelog.yml")


c(
  "colors",
  "shiny_resume"
) |> purrr::walk(usethis::use_r, open = FALSE)

c(
  # add data prep script names here:
  "color_palette"
) |> purrr::walk(usethis::use_data_raw)

c(

)

usethis::use_rmarkdown_template(
  "report",
  template_name = "Custom RMarkdown Report Template for No Clocks, LLC"
)


usethis::use_vignette("noclocksR")
usethis::use_vignette("styleguide")
usethis::use_vignette("shiny")

usethis::use_pkgdown()
usethis::use_pkgdown_github_pages()


usethis::use_testthat()
usethis::use_test("color_palette")
usethis::use_test("shiny_resume")
