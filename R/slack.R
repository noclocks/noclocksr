setup_slack <- function(
  slack_config = config::get("slack"),
  slack_config_file = here::here("slack_config.dcf"),
  ...
) {

  if (is.null(slack_config)) {
    rlang::abort("No Slack configuration found")
  }

  req_cfg <- c("oauth_access_token", "incoming_webhook_url", "channel")

  stopifnot(
     all(req_cfg %in% names(slack_config))
  )

  slackr::slackr_setup(
    channel = slack_config$channel,
    username = "slackr",
    icon_emoji = ":robot_face:",
    incoming_webhook_url = slack_config$incoming_webhook_url,
    token = slack_config$oauth_access_token#,
    # config_file = "inst/config/slackr.dcf",
    # echo = FALSE,
    # cache_dir = "data-raw/cache/slackr"
  )

}

get_slack_channels <- function() {
  slackr::slackr_channels()
}
