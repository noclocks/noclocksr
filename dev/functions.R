new_function <- function(
  name,
  path = fs::path("R", glue::glue("{name}.R")),
  title = stringr::str_to_title(stringr::str_replace(name, "_", " ")),
  test = TRUE,
  example = TRUE,
  export = TRUE,
  open = rlang::is_interactive()
) {

  # setup for test and example if necessary
  if (test) {
    test_path <- fs::path("tests", "testthat", glue::glue("test_{name}.R"))
    usethis::use_test(name = name, open = FALSE)
  }

  if (example) {

    example_path <- fs::path("examples", glue::glue("ex_{name}.R"))
    example_roxy <- glue::glue("#' @example examples/ex_{name}.R\n")
    example_content <- glue::glue(
      "if (FALSE) {{\n\n",
      "  {name}()\n\n",
      "}}\n"
    )

    if (!fs::dir_exists(fs::path("examples"))) {
      fs::dir_create(fs::path("examples"))
      cli::cli_alert_success("Created examples directory: {.path {fs::path('examples')}/}.")
    }

    if (!fs::file_exists(example_path)) {
      cat(example_content, file = example_path, sep = "\n")
      cli::cli_alert_success("Created example file: {.path {example_path}}.")
    }

  }

  # function skeleton
  skeleton <- glue::glue(
    "#' {title}", "\n",
    "#'", "\n",
    "#' @description", "\n",
    "#'", " ...", "\n",
    "#'", "\n",
    "#' @param ... ...", "\n",
    "#'", "\n",
    "#' @return ...", "\n",
    "#'", "\n",
    if (export) { "#' @export\n" } else { "#' @keywords internal\n" },
    "#'", "\n",
    if (example) { "#' @example examples/ex_{name}.R\n" },
    "{name} <- function(...) {{",
    "  ",
    "}}"
  )

  # write to file
  if (!fs::file_exists(path)) {
    cat(skeleton, file = path)
    cli::cli_alert_success("Created function file: {.path {path}}.")
  }

  if (open) {
    rstudioapi::navigateToFile(path)
  }

}

