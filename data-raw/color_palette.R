
#  ------------------------------------------------------------------------
#
# Title : Derivation of the No Clocks, LLC Color Pallet from Logo
#    By : Jimmy Briggs
#  Date : 2024-02-07
#
#  ------------------------------------------------------------------------

styles <- list(
  "primary" = "#121618",
  "secondary_1" = "#E6AA68",
  "secondary_2" = "#F4F4F9",
  "secondary_3" = "#29B1B2",
  "salmon" = "#F16876",
  "light_blue"= "#00A7E6",
  "light_grey" = "#E8ECF8",
  "brown"  = "#796C68"
)

get_styles <- function(...) {
  cols <- c(...)

  if (is.null(cols)) { return(styles) }

  styles[cols]

}

noclocks.palettes <- list(
  `main` = get_styles(),
  `cool` = get_styles("light_blue", "light_grey")
)

get_color_palette <- function(palette = "main", reverse = FALSE, ...) {

  pal <- noclocks.palettes[[palette]]

  if (reverse) { pal <- rev(pal) }

  grDevices::colorRampPalette(pal, ...)

}


scale_color_noclocks <-  function(palette = "main", discrete = TRUE, reverse = FALSE, ...) {

  pal <- get_color_palette(palette, reverse = reverse)

  if (discrete) {
    ggplot2::discrete_scale("color", paste0("noclocks_", palette), palette = pal, ...)
    # scales::scale_color_manual(values = pal, ...)
  } else {
    ggplot2::scale_color_gradientn(colours = pal(256), ...)
  }

}

scale_fill_noclocks <- function(palette = "main", discrete = TRUE, reverse = FALSE, ...) {

  pal <- get_color_palette(palette = palette, reverse = reverse)

  if (discrete) {
    ggplot2::discrete_scale("fill", paste0("ketch_", palette), palette = pal, ...)
  } else {
    ggplot2::scale_fill_gradientn(colours = pal(256), ...)
  }

}

# Primary: #121618;Secondary:#29B1B2, #F4F4F9, #E6AA68;

# Primary: #D67976;Secondary:#064152, #6369D1, #011627;

# pak::pak("AndreaCirilloAC/paletter")
library(paletter)
require(fs)

image_path <- file.path("inst/assets/images/main-logo-black.jpg")
# fs::dir_create("inst/assets/img")
# fs::file_copy(image_path, "inst/assets/img/PwC-Logo.jpg")

colors_vector <- create_palette(
  image_path = image_path,
  number_of_colors = 32,
  type_of_variable = "categorical"
)

colors_vector

usethis::use_data(pwc_colors_vector, overwrite = TRUE, internal = TRUE)

usethis::use_data(color_palette, overwrite = TRUE)
