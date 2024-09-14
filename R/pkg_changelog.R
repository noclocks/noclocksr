
#  ------------------------------------------------------------------------
#
# Title : Package CHANGELOG.md
#    By : Jimmy Briggs
#  Date : 2024-09-14
#
#  ------------------------------------------------------------------------

# internal ----------------------------------------------------------------

.git_cliff_config_url <- "https://raw.githubusercontent.com/noclocks/.github/main/workflow-templates/cliff.template.toml"

.git_cliff_changelog_gha_url <- "https://raw.githubusercontent.com/noclocks/.github/main/.github/workflows/changelog.yml"

git_cliff <- function(
    changelog_path = "CHANGELOG.md",
    config_path = ".github/cliff.toml",
    open = rlang::is_interactive()
) {

  cmd <- "git-cliff.exe"

  if (!test_sys_path(cmd)) {
    rlang::abort(
      c(
        "{.code {cmd}} not found on the system's {.code PATH}."
      )
    )
  }

  full_cmd <- paste0(
    cmd, " -o ", changelog_path, " -c ", config_path
  )

  shell(full_cmd)

  cli::cli_alert_success("Git Cliff has successfully generated the changelog.")
  if (open) { file.edit(changelog_path) }

  return(invisible(0))

}

use_git_cliff <- function(
    path = "CHANGELOG.md",
    config = ".github/cliff.toml"
) {

  # get the cliff config file
  if (!file.exists(config)) {
    download.file(url = .git_cliff_config_url, destfile = config)
  }

  # get the cliff changelog action file
  if (!file.exists(".github/workflows/changelog.yml")) {
    download.file(url = .git_cliff_changelog_gha_url, destfile = ".github/workflows/changelog.yml")
  }

  # load the yaml file
  yaml <- yaml::yaml.load_file(".github/workflows/changelog.yml")

  # ensure the output in yaml points to the changelog path
  yaml$jobs$changelog$steps[[2]]$with$output <- path

  # ensure the template-config in yaml points to the config path
  yaml$jobs$changelog$steps[[2]]$with$`template-config` <- config

  # write the yaml back to the file
  yaml::write_yaml(yaml, ".github/workflows/changelog.yml")

  cli::cli_alert_success("Git Cliff has been successfully configured.")

}
