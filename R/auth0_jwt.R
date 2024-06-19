get_auth0_jwt <- function(
  auth0_config = config::get("auth0"),
  ...
) {

  if (is.null(auth0_config)) {
    rlang::abort("No Auth0 configuration found")
  }

  httr2::curl_translate(
    "curl --request POST --url https://jimbrig.us.auth0.com/oauth/token --header 'content-type: application/json' --data '{\"client_id\":\"tCLHUNuGdBXlaeZ94OrHfjVOUVuFPRte\",\"client_secret\":\"te2n7aYvXPYflth3OFMi8QK5c7obtjoJPNxfBfs1LKQIx2j9YfobR2rPKWsbEz-3\",\"audience\":\"https://auth-api.noclocks.dev\",\"grant_type\":\"client_credentials\"}'"
  )

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
