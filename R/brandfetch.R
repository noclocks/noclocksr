
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


# out_company <- tibble::tibble(
#   id = content$id,
#   name = content$name,
#   domain = domain,
#   claimed = content$claimed,
#   description = content$description,
#   longDescription = content$longDescription,
#   links = content$links |> purrr::map_dfr(
#     ~ tibble::tibble(
#       name = .x$name,
#       url = .x$url
#     )
#   ),
#   qualityScore = content$qualityScore,
#   company = content$company |> purrr::map_dfr(
#     ~ tibble::tibble(
#       industries = .x$industries |> purrr::map_dfr(
#         ~ tibble::tibble(
#           score = .x$score,
#           id = .x$id,
#           name = .x$name,
#           emoji = .x$emoji,
#           parent = .x$parent |> purrr::map_dfr(
#             ~ tibble::tibble(
#               emoji = .x$emoji,
#               id = .x$id,
#               name = .x$name,
#               slug = .x$slug
#             )
#           ),
#           slug = .x$slug
#         )
#       ),
#       kind = .x$kind,
#       location = .x$location
#     )
#   )
#
# )

# out_logos <- content$logos |> purrr::map_dfr(
#   ~ tibble::tibble(
#     domain = domain,
#     theme = .x$theme,
#     src = .x$formats$src,
#     background = .x$formats$background,
#     format = .x$formats$format,
#     height = .x$formats$height,
#     width = .x$formats$width,
#     size = .x$formats$size,
#     tags = .x$tags,
#     type = .x$type
#   )
# )
#
# out_colors <- content$colors |> purrr::map_dfr(
#   ~ tibble::tibble(
#     domain = domain,
#     hex = .x$hex,
#     type = .x$type,
#     brightness = .x$brightness
#   )
# )
