
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
#' @export
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
    tibblify::tib_chr("id"),
    tibblify::tib_chr("name"),
    tibblify::tib_chr("domain"),
    tibblify::tib_lgl("claimed"),
    tibblify::tib_chr("description"),
    tibblify::tib_chr("longDescription"),
    tibblify::tib_dbl("qualityScore"),
    tibblify::tib_unspecified("images"),

    tibblify::tib_df(
      "links",
      tibblify::tib_chr("name"),
      tibblify::tib_chr("url")
    ),

    tibblify::tib_df(
      "logos",
      tibblify::tib_chr("theme"),
      tibblify::tib_df(
        "formats",
        tibblify::tib_chr("src"),
        tibblify::tib_unspecified("background"),
        tibblify::tib_chr("format"),
        tibblify::tib_int("height"),
        tibblify::tib_int("width"),
        tibblify::tib_int("size"),
      ),
      tibblify::tib_unspecified("tags"),
      tibblify::tib_chr("type")
    ),

    tibblify::tib_df(
      "colors",
      tibblify::tib_chr("hex"),
      tibblify::tib_chr("type"),
      tibblify::tib_int("brightness"),
    ),

    tibblify::tib_df(
      "fonts",
      tibblify::tib_chr("name"),
      tibblify::tib_chr("type"),
      tibblify::tib_chr("origin"),
      tibblify::tib_chr("originId"),
      tibblify::tib_unspecified("weights"),
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

#' Download Brand Logos
#'
#' @param brand Brand
#' @param path Path
#' @param ... ...
#'
#' @return Invisible
#' @export
#'
#' @importFrom dplyr mutate
#' @importFrom fs dir_exists dir_create
#' @importFrom purrr pmap_chr pwalk
download_brand_logos <- function(
    brand,
    path = "inst/extdata/brand",
    ...
) {

  if (!fs::dir_exists(path)) {
    fs::dir_create(path)
  }

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

  brand_logos |>
    purrr::pwalk(
      download_logo,
      src = brand$logos$src,
      name = brand$name,
      path = path,
      ...
    )

  return(
    invisible(TRUE)
  )

}

#' Get Brand Logos
#'
#' @param brand Brand
#' @param path Path
#' @param ... ...
#'
#' @return Invisible
#' @export
#'
#' @importFrom dplyr mutate
#' @importFrom purrr pmap_chr
#' @importFrom fs dir_exists dir_create
#' @importFrom purrr pwalk pmap_chr
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

#' Get Logo File Name
#'
#' @param brand_name Brand Name
#' @param type Type
#' @param theme Theme
#' @param format Format
#' @param height Height
#' @param width Width
#' @param ... ...
#'
#' @return The logo file name
#' @export
#'
#' @importFrom stringr str_replace_all str_to_lower
get_logo_file_name <- function(
    brand_name,
    type,
    theme,
    format,
    height = NA,
    width = NA,
    ...
) {

  brand_name_clean <- stringr::str_to_lower(brand_name) |> stringr::str_replace_all(" ", "_")
  size <- ""
  if (all(
    !is.na(height),
    !is.na(width),
    format != "svg"
  )) {
    size <- paste0("-", as.character(height), "x", as.character(width))
  }

  paste0(
    brand_name_clean,
    "-",
    type,
    "-",
    theme,
    size,
    ".",
    format
  )

}
