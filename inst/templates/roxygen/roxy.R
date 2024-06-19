#' Function Documentation Example
#'
#' @description
#' Show an example of roxygen tags organization, providing documentation best
#' practices and guidelines. An explicit `@description` is only needed for
#' multi-paragraph descriptions.
#'
#' @param first_arg (Required) Description of the first argument. Note: should
#'   define the expected input's class and structure, whether its required or
#'   optional, and (if applicable) its default value.
#' @param second_arg (Optional) Character string representing the second
#'   argument of the function. Defaults to `NULL`.
#'
#' @details
#' More details or context about the function and its behavior. List
#' possible side-effects, corner-cases and limitations here. Also use this
#' section for describing the meaning and usage of arguments when this is too
#' complex or verbose for the `@param` tags.
#'
#' @section Custom Section:
#' The content of a custom section.
#'
#' @return Returns `NULL`, invisibly. The function is called for illustration
#'   purposes only.
#'
#' @references
#' Hadley Wickham, Peter Danenberg and Manuel Eugster. roxygen2: In-Line
#' Documentation for R. [https://CRAN.R-project.org/package=roxygen2]().
#'
#' Hadley Wickham, The tidyverse style guide.
#' [https://style.tidyverse.org/documentation.html]().
#'
#' @seealso [my_other_function()], [roxygen2::roxygenize()]. Even if you just put
#'   comma-separated links to functions, don't forget the final period (.).
#'
#' @family function documentation examples
#'
#' @keywords function documentation
#'
#' @
#'
#' @example examples/ex_fun_doc.R
#'
#' @importFrom roxygen2 roxygenise
#'
#' @export
fun_doc <- function(
  first_arg,
  second_arg = NULL
) {
  invisible()
}
