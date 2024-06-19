# rs_shiny_mod <- function(
#   name = NULL,
#   open = rlang::is_interactive()
# ) {
#
#   rfile <- glue::glue("mod_{name}.R")
#   rfilepath <- usethis::proj_path("R", rfile)
#
#   if (!fs::file_exists(rfilepath)) {
#     fs::file_create(rfilepath)
#
#     roxy <- glue::glue(
#       .sep = "\n",
#       "#' {stringr::str_to_title(name)} Shiny Module",
#       "#'",
#       "#' @description",
#       "#' {stringr::str_to_title(name)} Shiny Module",
#       "#'",
#       "#' @param id The module id to use for namespacing",
#       "#' @param input,output,session The shiny server function arguments",
#       "#' @param ... Additional arguments",
#       "#'",
#       "#' @return The UI module returns an [htmltools::tagList()];",
#       "#'   the server module returns a [shiny::reactive()]",
#       "#'",
#       "#' @export",
#       "#'",
#       "#' @importFrom shiny moduleServer NS reactive observe",
#       "#' @importFrom htmltools tags tagList"
#     )
#
#     ui_func <- glue::glue(
#       .sep = "\n",
#       "#' {name} Module",
#       "mod_{name}_ui <- function(id, ...) {",
#       "  ns <- shiny::NS(id)",
#       "  htmltools::tagList(",
#       "    ",
#       "  )",
#       "}",
#       "",
#
#
#       )",
#     )
#
# }
