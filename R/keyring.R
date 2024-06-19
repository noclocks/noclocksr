init_keyring <- function(
    keyring_name = getOption("noclocks.keyring.name", default = "noclocks"),
    username = getOption("noclocks.keyring.username", default = "noclocks"),
    password = getOption("noclocks.keyring.password", default = NULL),
    ...
) {

  stopifnot(keyring::has_keyring_support())

  keyrings <- keyring::keyring_list()$keyring |> unique()

  if (keyring_name %in% keyrings) {
    rlang::warn(
      "Keyring already exists. Skipping creation."
    )
  } else {
    keyring::keyring_create(
      keyring = keyring_name,,
      password = password
    )

    msg <- glue::glue(
      "Keyring '{name}' created successfully.",
      "To add secrets to the keyring, use `noclocksR::add_secret()`."
    )

    rlang::inform(msg)
  }

  if (getOption("noclocks.keyring.username", default = "noclocks") != username) {
    msg <- glue::glue(
      "Setting the default keyring username to '{username}':",
      "To change this, use `options(noclocks.keyring.username = '<username>')`."
    )

    options("noclocks.keyring.username" = username)

    rlang::inform(msg)
  }

  if (!is.null(password)) {
    msg <- glue::glue(
      "Setting the default keyring password:",
      "To change this, use `options(noclocks.keyring.password = '<password>')`."
    )

    options("noclocks.keyring.password" = password)

    rlang::inform(msg)
  }

  invisible(TRUE)

}

check_keyring <- function(
  keyring = "noclocks"
) {

  stopifnot(keyring::has_keyring_support())

  keyrings <- keyring::keyring_list()$keyring |> unique()

  if (keyring %in% keyrings) {
    rlang::inform(
      glue::glue(
        "Keyring '{keyring}' exists."
      )
    )
  } else {
    rlang::abort(
      glue::glue(
        "Keyring '{keyring}' does not exist.",
        "Please create it using `noclocksR::init_keyring()`."
      )
    )
  }

  invisible(TRUE)

}

get_secret <- function(
  secret,
  username = "noclocks",
  keyring = "noclocks",
  ...
) {

  stopifnot(check_keyring(keyring))

  secret <- keyring::key_get(
    service = secret,
    keyring = keyring,
    password = password
  )

  secret
}

setup_keyring <- function() {
  keyring::keyring_path <- here::here("keyring")
  keyring::keyring_path
}
