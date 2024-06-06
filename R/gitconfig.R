git_config_get <- function(key) {

  git_config <- gert::git_config_global()

  keys <- unique(gitconfig$name)

  if (!key %in% keys) {
    warning(glue::glue(
      "The key '{key}' is not in your git config. Please set it before proceeding."
    ))
    return(NULL)
  }

  git_config |>
    dplyr::filter(
      level %in% c("global", "xdg"),
      name == key
    ) |>
    dplyr::pull(value) |>
    unique()
}


assert_git_config <- function() {

  gitconfig <- gert::git_config_global()

  if (is.null(gitconfig)) {
    stop("Please set your git config before proceeding.")
  }

  user_name <- git_config_get("user.name")
  user_email <- git_config_get("user.email")
  default_branch <- git_config_get("init.defaultbranch")
  signing_key <- git_config_get("user.signingkey")

  if (is.null(user_name) | is.null(user_email) | is.null(default_branch) | is.null(signing_key)) {
    stop("Please set your git config before proceeding.")
  }
}

