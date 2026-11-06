get_auth0_jwt <- function(
  auth0_config = config::get("auth0"),
  ...
) {

  if (is.null(auth0_config)) {
    rlang::abort("No Auth0 configuration found")
  }

  required_fields <- c(
    "jwt_url", "client_id", "client_secret", "audience", "grant_type"
  )
  if (!is.list(auth0_config)) {
    rlang::abort("Auth0 configuration must be a named list")
  }
  invalid_fields <- required_fields[!vapply(
    required_fields,
    function(field) {
      value <- auth0_config[[field]]
      is.character(value) && length(value) == 1L &&
        !is.na(value) && nzchar(trimws(value))
    },
    logical(1)
  )]
  if (length(invalid_fields) > 0L) {
    rlang::abort(paste0(
      "Auth0 configuration requires non-empty string values for: ",
      paste(invalid_fields, collapse = ", ")
    ))
  }
  if (!grepl("^https://[^/?#[:space:]]+", auth0_config$jwt_url)) {
    rlang::abort("Auth0 jwt_url must use HTTPS")
  }

  base_url <- auth0_config$jwt_url
  client_id <- auth0_config$client_id
  client_secret <- auth0_config$client_secret
  audience <- auth0_config$audience
  grant_type <- auth0_config$grant_type

  req <- httr2::request(
    base_url = base_url
  ) |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      `Content-Type` = "application/json"
    ) |>
    httr2::req_body_json(
      list(
        client_id = client_id,
        client_secret = client_secret,
        audience = audience,
        grant_type = grant_type
      )
    )

  res <- req |> httr2::req_perform()

  if (res$status_code != 200) {
    rlang::abort("Auth0 JWT request failed")
  }

  content <- res |>
    httr2::resp_body_json()

  content

}
