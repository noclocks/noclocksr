#' Converts RGB values to hex colour code
#'
#' @param x A matrix of red, blue and green values
#'
#' @return A corresponding hex colour code
#' @export
#'
#' @examples temp_rgb_matrix <- rgba_to_rgb(c(52, 46, 39, 0.8))
#' rgb_to_hex(temp_rgb_matrix)
#'
rgb_to_hex <- function(x){
  grDevices::rgb(x[1], x[2], x[3], maxColorValue = 255)
}

#' Converts Hex codes values to RGB vectors
#'
#' @param x A hex colour code
#'
#' @return A corresponding matrix of red, blue and green values
#' @export
#'
#' @examples hex_to_rgb("purple")
#' hex_to_rgb("#fafafa")
#'
hex_to_rgb <- function(x){

  temp_tibble <- as.data.frame(grDevices::col2rgb(x, alpha = FALSE))

  paste0(c("r = ", "g = ", "b = "), temp_tibble$V1,
         collapse = ", ")
}

#' Convert RGB to HEX
#'
#' @param colour_rgba A vector of length 4: c(red value, green value, blue value, alpha).
#' All colour values must be between 0 and 255. Alpha must be between 0 and 1.
#' @param background_colour Defaults to white. Users can specify a different colour to get
#' the hex code for their original colour blended with a specified background colour.
#' `background_colour` must either be a recognised colour name (e.g. "white"),
#' a hex colour code (e.g. "#ffffff") or vector of length 3 (red value, green value, blue value),
#' with all values between 0 and 255. The default value is white ("#ffffff").
#' @param ... Allows for US spelling of color/colour.
#'
#' @return Returns the corresponding hex colour code
#' @export
#'
#' @examples rgba_to_hex(c(52, 46, 39, 0.8))
#'
#' rgba_to_hex(c(52, 46, 39, 0.8), "blue")
#'
#' rgba_to_hex(c(52, 46, 39, 0.8), "#032cfc")
rgba_to_hex <- function(colour_rgba,  background_colour = "#ffffff", ...){

  # Allows for US spelling input
  check_dots <- list(...)

  if(missing(colour_rgba) & "color_rgba" %in% names(check_dots)) {
    colour_rgba <- check_dots$color_rgba
  }

  if("background_color" %in% names(check_dots)) {
    background_colour <- check_dots$background_color
  }

  new_col <- rgba_to_rgb(colour_rgba, background_colour)

  new_col_hex <- rgb_to_hex(new_col)

  return(new_col_hex)

}
