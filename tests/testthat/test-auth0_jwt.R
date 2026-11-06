auth0_test_config <- function() {
  list(
    jwt_url = "https://tenant.example.com/oauth/token",
    client_id = "test-client-id",
    client_secret = "test-client-secret",
    audience = "https://api.example.com",
    grant_type = "client_credentials"
  )
}

test_that("Auth0 requests use only the supplied configuration", {
  settings <- auth0_test_config()
  captured <- NULL
  httr2::local_mocked_responses(function(req) {
    captured <<- req
    httr2::response(
      headers = list(`content-type` = "application/json"),
      body = charToRaw('{"access_token":"test-token","token_type":"Bearer"}')
    )
  })
  testthat::local_mocked_bindings(
    curl_translate = function(...) stop("Example code must not run"),
    .package = "httr2"
  )

  result <- get_auth0_jwt(settings)

  expect_equal(captured$url, settings$jwt_url)
  expect_equal(captured$method, "POST")
  expect_equal(captured$body$data, settings[c(
    "client_id", "client_secret", "audience", "grant_type"
  )])
  expect_equal(result, list(access_token = "test-token", token_type = "Bearer"))
})

test_that("missing or malformed configuration fails before any request", {
  httr2::local_mocked_responses(function(req) {
    stop("No network request should be attempted")
  })
  expect_error(get_auth0_jwt(NULL), "No Auth0 configuration found")
  expect_error(get_auth0_jwt("invalid"), "must be a named list")

  for (field in names(auth0_test_config())) {
    for (invalid in list(NULL, "", "  ", NA_character_, character(), c("a", "b"), 1)) {
      settings <- auth0_test_config()
      settings[field] <- list(invalid)
      expect_error(get_auth0_jwt(settings), field, fixed = TRUE)
    }
  }
  settings <- auth0_test_config()
  settings$jwt_url <- "http://tenant.example.com/oauth/token"
  expect_error(get_auth0_jwt(settings), "must use HTTPS")
})

test_that("HTTP failures still propagate", {
  httr2::local_mocked_responses(list(httr2::response(status_code = 401)))
  expect_error(get_auth0_jwt(auth0_test_config()), class = "httr2_http_401")
})

test_that("the default configuration is resolved from environment values", {
  withr::local_envvar(c(
    AUTH0_JWT_URL = "https://tenant.example.com/oauth/token",
    AUTH0_CLIENT_ID = "test-client-id",
    AUTH0_CLIENT_SECRET = "test-client-secret",
    AUTH0_AUDIENCE = "https://api.example.com"
  ))
  template <- testthat::test_path("..", "..", "inst", "config", "auth0-jwt.template.yml")
  withr::local_envvar(c(R_CONFIG_FILE = normalizePath(template)))
  httr2::local_mocked_responses(function(req) {
    expect_equal(req$body$data$client_secret, Sys.getenv("AUTH0_CLIENT_SECRET"))
    httr2::response(
      headers = list(`content-type` = "application/json"),
      body = charToRaw('{"access_token":"test-token"}')
    )
  })

  expect_equal(get_auth0_jwt()$access_token, "test-token")
})
