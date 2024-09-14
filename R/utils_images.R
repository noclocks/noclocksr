resize_crop_to_face <- function(image, size = 600) {
  image <- resize_fit(image, size)
  info <- image_info(image)

  # size may have changed after refit
  size <- min(info$height, info$width)

  is_image_square <- info$width == info$height
  if (is_image_square) {
    return(image)
  }

  face <- find_face_center(image)

  image_crop(
    image,
    geometry = geometry_area(
      width = size,
      height = size,
      x_off = crop_offset(face$x, info$width, size),
      y_off = crop_offset(face$y, info$height, size)
    )
  )
}
