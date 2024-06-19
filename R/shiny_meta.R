#' Use No Clocks `<meta>`
#'
#' @description
#' Adds `<meta>` tags and social media cards for No Clocks, LLC.
#'
#' @param name (character) The name of the site
#' @param version (character) The version of the site
#' @param description (character) The description of the site
#' @param url (character) The URL of the site
#' @param theme_color (character) The theme color of the site
#' @param robots (character) The robots meta tag
#' @param generator (character) The generator meta tag
#' @param subject (character) The subject meta tag
#' @param rating (character) The rating meta tag
#' @param referrer (character) The referrer meta tag
#' @param csp (character) The content security policy meta tag
#' @param image (character) The image URL for the site
#' @param image_alt (character) The image alt text for the site
#' @param twitter_creator (character) The Twitter creator meta tag
#' @param twitter_card_type (character) The Twitter card type meta tag
#' @param twitter_site (character) The Twitter site meta tag
#' @param ... Additional arguments
#'
#' @seealso [metathis::meta()]
#'
#' @return HTML via [htmltools::tags()] and `<meta>` tags via
#'   [metathis::meta()]
#' @export
#'
#' @example examples/ex_use_noclocks_meta.R
#'
#' @importFrom metathis meta meta_social
use_noclocks_meta <- function(
    name = "noclocks",
    version = "0.0.1",
    description = "<meta> and social media cards for No Clocks, LLC",
    url = "https://noclocks.dev",
    theme_color = "#000000",
    robots = "index,follow",
    generator = "R-Shiny",
    subject = "No Clocks, LLC",
    rating = "General",
    referrer = "origin",
    csp = "default-src 'self'",
    image = noclocks_logo(url = TRUE),
    image_alt = "No Clocks, LLC Logo",
    twitter_creator = "@noclocksdev",
    twitter_card_type = "summary_large_image",
    twitter_site = "@noclocksdev",
    ...
) {

  # noclocks_brand()$colors |> dplyr::filter(type == "dark") |> dplyr::pull(hex)

  htmltools::tags$head(
    metathis::meta() |>
      metathis::meta_viewport(maximum_scale = 1) |>
      metathis::meta_general(
        application_name = name,
        theme_color = theme_color,
        description = description,
        robots = robots,
        generator = generator,
        subject = subject,
        rating = rating,
        referrer = referrer
      ) |>
      metathis::meta_tag(
        "http-equiv" = "Content-Security-Policy",
        "content" = csp
      ) |>
      metathis::meta_name(
        "package" = name,
        "version" = version
      ) |>
      metathis::meta_social(
        title = name,
        description = description,
        url = url,
        image = image,
        image_alt = image_alt,
        twitter_creator = twitter_creator,
        twitter_card_type = twitter_card_type,
        twitter_site = twitter_site
      )
  )

}
