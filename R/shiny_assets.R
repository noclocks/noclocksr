
#  ------------------------------------------------------------------------
#
# Title : No Clocks R Shiny Assets
#    By : Jimmy Briggs
#  Date : 2024-07-26
#
#  ------------------------------------------------------------------------


# internal ----------------------------------------------------------------

# https://www.jsdelivr.com/package/npm/js-cookie
.dep_jscookie <- htmltools::htmlDependency(
  name = "js-cookie",
  version = "3.0.5",
  src = "https://cdn.jsdelivr.net/npm/js-cookie/dist/",
  meta = NULL,
  script = "js.cookie.min.js",
  stylesheet = NULL,
  head = NULL,
  attachment = NULL,
  package = NULL
)

# noclocks dependencies ---------------------------------------------------

noclocks_shiny_dependency <- function() {
  htmltools::htmlDependency(
    name = "noclocksShiny",
    version = utils::packageVersion("noclocksr"),
    src = c(href = "noclocksr", file = "assets"),
    package = "noclocksr",
    script = "noclocksShiny.script.min.js",
    stylesheet = "noclocksShiny.styles.min.css",
    all_files = FALSE
  )
}

attach_noclocks_shiny_dependency <- function(
  tag,
  widget = NULL,
  extra_deps = NULL
) {


  deps <- noclocks_shiny_dependency()



  htmltools::attachDependencies(
    htmltools::tagList(),
    noclocks_shiny_dependency()
  )
}
