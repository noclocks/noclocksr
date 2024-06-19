document_dataset <- function(
  data_obj,
  name = "DATASET_NAME",
  description = "DATASET_DESCRIPTION",
  source = "DATASET_SOURCE",
  col_types = purrr::map_chr(data_obj, typeof),
  col_descs = rep("COLUMN_DESCRIPTION", length(names(data_obj))),
  file = fs::path("R", "data.R"),
  append = TRUE,
  overwrite = FALSE,
  ...
) {

  col_names <- names(data_obj)

  if (missing(col_types) || is.null(col_types)) {
    col_types <- purrr::map_chr(data_obj, typeof)
  }

  if (missing(col_descs) || is.null(col_descs)) {
    col_descs <- rep("COLUMN_DESCRIPTION", length(col_names))
  }

  stopifnot(
    length(col_types) == length(col_names),
    length(col_descs) == length(col_names)
  )

  col_roxys <- glue::glue(
    .open = "[[",
    .close = "]]",
    "#'   \\item{\\code{[[col_names]]}}{[[col_types]]. [[col_descs]].}"
  ) |>
    paste(collapse = "\n")

  # cat(col_roxys)

  dims <- paste0(
    nrow(data_obj),
    " rows and ",
    ncol(data_obj),
    " columns"
  )

  pre <- glue::glue(
    .sep = "\n",
    "#' {name}",
    "#'",
    "#' @description",
    "#' {description}",
    "#'",
    "#' @source",
    "#' {source}",
    "#'",
    "#' @format A data.frame with {dims}:"
  )

  skeleton <- paste0(
    pre,
    "\n",
    "#' \\describe{\n",
    col_roxys,
    "\n",
    "#'}\n",
    '"', name, '"\n'
  )

  cat(skeleton,
      file = file,
      append = append,
      sep = "\n")

}



