
#  ------------------------------------------------------------------------
#
# Title : Branding Utilities
#    By : Jimmy Briggs
#  Date : 2024-06-17
#
#  ------------------------------------------------------------------------


#' Fetch a Brand using the Brandfetch API
#'
#' @description
#' This function fetches a brand using the
#' [Brandfetch Brand API](https://docs.brandfetch.com/reference/brand-api).
#'
#' @param domain The domain of the brand to fetch
#' @param brandfetch_api_key The API key for the Brandfetch API
#' @param ... Additional arguments
#'
#' @return A tibble with the brand information
#'
#' @export
#'
#' @example examples/ex_brandfetch.R
#'
#' @importFrom httr2 request req_url_path_append req_method req_auth_bearer_token req_headers req_perform
#' @importFrom tibblify tibblify tspec_object tib_chr tib_lgl tib_dbl tib_unspecified tib_df tib_row
#' @importFrom purrr pluck
#' @importFrom tidyr unnest
#' @importFrom rlang abort
#' @importFrom config get
#' @importFrom tibble tibble
#' @importFrom httr2 resp_body_json
#' @importFrom dplyr pull
fetch_brand <- function(
    domain,
    brandfetch_api_key = Sys.getenv("BRANDFETCH_API_KEY", unset = config::get("brandfetch_api_key")),
    ...
) {

  base_url <- "https://api.brandfetch.io/v2/brands"

  if (is.null(brandfetch_api_key)) {
    brandfetch_api_key <- config::get("brandfetch_api_key")
  }

  if (is.null(brandfetch_api_key)) {
    rlang::abort("No Brandfetch API key found")
  }

  req <- httr2::request(
    base_url = base_url
  ) |>
    httr2::req_url_path_append(
      domain
    ) |>
    httr2::req_method("GET") |>
    httr2::req_auth_bearer_token(brandfetch_api_key) |>
    httr2::req_headers(
      `Accept` = "application/json",
      `Content-Type` = "application/json"
    )

  res <- req |> httr2::req_perform()
  if (res$status_code != 200) {
    rlang::abort("Brandfetch API request failed")
  }

  content <- res |>
    httr2::resp_body_json()

  spec <- tibblify::tspec_object(
    tibblify::tib_chr("id", required = FALSE),
    tibblify::tib_chr("name", required = FALSE),
    tibblify::tib_chr("domain", required = FALSE),
    tibblify::tib_lgl("claimed", required = FALSE),
    tibblify::tib_chr("description", required = FALSE),
    tibblify::tib_chr("longDescription", required = FALSE),
    tibblify::tib_dbl("qualityScore", required = FALSE),
    tibblify::tib_unspecified("images"),

    tibblify::tib_df(
      "links",
      tibblify::tib_chr("name", required = FALSE),
      tibblify::tib_chr("url", required = FALSE)
    ),

    tibblify::tib_df(
      "logos",
      tibblify::tib_chr("theme", required = FALSE),
      tibblify::tib_df(
        "formats",
        tibblify::tib_chr("src", required = FALSE),
        tibblify::tib_unspecified("background", required = FALSE),
        tibblify::tib_chr("format", required = FALSE),
        tibblify::tib_int("height", required = FALSE),
        tibblify::tib_int("width", required = FALSE),
        tibblify::tib_int("size", required = FALSE),
      ),
      tibblify::tib_unspecified("tags", required = FALSE),
      tibblify::tib_chr("type", required = FALSE)
    ),

    tibblify::tib_df(
      "colors",
      tibblify::tib_chr("hex", required = FALSE),
      tibblify::tib_chr("type", required = FALSE),
      tibblify::tib_int("brightness", required = FALSE),
    ),

    tibblify::tib_df(
      "fonts",
      tibblify::tib_chr("name", required = FALSE),
      tibblify::tib_chr("type", required = FALSE),
      tibblify::tib_chr("origin", required = FALSE),
      tibblify::tib_chr("originId", required = FALSE),
      tibblify::tib_unspecified("weights", required = FALSE),
    ),

    tibblify::tib_row(
      "company",
      tibblify::tib_unspecified("employees"),
      tibblify::tib_unspecified("foundedYear"),
      tibblify::tib_unspecified("kind"),
      tibblify::tib_unspecified("location"),
      tibblify::tib_df(
        "industries",
        tibblify::tib_unspecified("id", required = FALSE),
        tibblify::tib_unspecified("parent"),
        tibblify::tib_dbl("score", required = FALSE),
        tibblify::tib_chr("name", required = FALSE),
        tibblify::tib_chr("emoji", required = FALSE),
        tibblify::tib_chr("slug", required = FALSE)
      )
    )
  )

  out <- tibblify::tibblify(content, spec, unspecified = "drop")
  out$logos <- out$logos |> tidyr::unnest("formats")
  out$company <- out$company |> purrr::pluck("industries")

  return(out)

}


get_brand_logos <- function(
  brand,
  path,
  ...
) {

  brand_logos <- brand$logos |>
    dplyr::mutate(
      file = purrr::pmap_chr(
        list(
          brand_name = brand$name,
          type = type,
          format = format,
          height = height,
          width = width
        ),
        get_logo_file_name
      )
    )

  purrr::walk2(
    brand_logos$src,
    brand_logos$file,
    ~download_logo(
      src = .x,
      file = .y,
      name = brand$name,
      type = brand_logos$type,
      format = brand_logos$format,
      height = brand_logos$height,
      width = brand_logos$width
    )
  )

  return(
    invisible(TRUE)
  )




}

#' Download Brand Logo File
#'
#' @description
#' This function downloads a brand logo file from a URL to the specified path.
#'
#' @param src The URL of the logo file
#' @param file The name of the logo file
#' @param name The name of the brand
#' @param path The path to save the logo file
#' @param type The type of logo (icon or logo)
#' @param format The format of the logo (png, svg, jpeg)
#' @param height The height of the logo
#' @param width The width of the logo
#' @param ... Additional arguments
#'
#' @return Invisible
#' @export
#'
#' @importFrom stringr str_replace_all str_to_lower
#' @importFrom fs dir_exists dir_create path
download_logo <- function(
    src,
    file,
    name,
    path = "inst/extdata/brand",
    type = c("icon", "logo"),
    format = c("png", "svg", "jpeg"),
    height,
    width,
    ...
) {

  type <- match.arg(type)
  format <- match.arg(format)
  height <- as.integer(height)
  width <- as.integer(width)
  src <- src |> stringr::str_replace_all(" ", "%20")
  brand_name_clean <- stringr::str_to_lower(name) |> stringr::str_replace_all(" ", "_")
  size <- paste0(as.character(height), "x", as.character(width))

  if (!fs::dir_exists(path)) {
    fs::dir_create(path)
  }

  file_path <- fs::path(path, file)

  download.file(
    src,
    destfile = file_path,
    method = "curl"
  )

  return(
    invisible(TRUE)
  )

}

#' @param brand_name The name of the brand
#' @param type The type of logo
#' @param format The format of the logo
#' @param height The height of the logo
#' @param width The width of the logo
#' @param ... Additional arguments
#'
#' @return The file name of the logo
#'
#' @export
#'
#' @noRd
#'
#' @keywords internal
#'
#' @importFrom stringr str_to_lower str_replace_all
#' @importFrom purrr pmap_chr
#' @importFrom dplyr mutate
#' @importFrom fs dir_exists dir_create path
get_logo_file_name <- function(
    brand_name,
    type,
    format,
    height,
    width,
    ...
) {

  brand_name_clean <- stringr::str_to_lower(brand_name) |> stringr::str_replace_all(" ", "_")
  size <- ""
  if (!is.na(height) && !is.na(width) && format != "svg") {
    size <- paste0("-", as.character(height), "x", as.character(width))
  }

  paste0(
    brand_name_clean,
    "-",
    type,
    size,
    ".",
    format
  )

}

# brand_logos <- brand$logos |>
#   dplyr::mutate(
#     file = purrr::pmap_chr(
#       list(
#         brand_name = brand$name,
#         type = type,
#         format = format,
#         height = height,
#         width = width
#       ),
#       get_logo_file_name
#     )
#   )




# download_logo(
#   src = brand_logos$src[3],
#   file = brand_logos$file[3],
#   name = brand$name,
#   type = brand_logos$type[3],
#   format = brand_logos$format[3],
#   height = brand_logos$height[3],
#   width = brand_logos$width[3]
# )
