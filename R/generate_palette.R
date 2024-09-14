generate_palette_from_img <- function(
  img_path,
  num_colors = 40,
  ...
) {

  paletter::create_palette(
    image_path = img_path,
    number_of_colors = num_colors,
    ...
  )

}

generate_palette_from_color <- function(
  color,
  modification,
  num_colors,
  blend_color = NULL,
  view_palette = TRUE,
  view_labels = TRUE,
  ...
) {

  monochromeR::generate_palette(
    color = color,
    modification = modification,
    num_colors = num_colors,
    blend_color = blend_color,
    view_palette = view_palette,
    view_labels = view_labels,
    ...
  )

}
