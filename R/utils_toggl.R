
#  ------------------------------------------------------------------------
#
# Title : Toggl Utilities
#    By : Jimmy Briggs
#  Date : 2024-09-05
#
#  ------------------------------------------------------------------------


#' Toggl Time Tracking
#'
#' @name time_tracking
#'
#' @description
#' Functions for tracking time in the current project's context via Toggl.
#'
#' - `start_time_tracking()`: Start tracking time in Toggl.
#' - `stop_time_tracking()`: Stop tracking time in Toggl.
#' - `get_tracked_time()`: Retrieve tracked time entries from Toggl.
#'
#' @param description A description of the time entry.
#'   Default is "R Development for GMH Leasing Dashboard" in this project.
#' @param tags A character vector of tags to apply to the time entry.
#'   Note that if the project is billable, the "Billable" tag will be added.
#' @param config A configuration list for the Toggl project.
#'   By default will retrieve values from the `toggl` configuration setup in
#'   the `config.yml` for the project.
#' @param ... Additional arguments to pass to the various `togglr` functions.
#'
#' @return
#' - `start_time_tracking()`: The response from the Toggl API for starting time tracking.
#' - `stop_time_tracking()`: The response from the Toggl API for stopping time tracking.
#' - `get_tracked_time()`: A data frame of the time entries retrieved from Toggl.
NULL

#' @rdname time_tracking
#' @export
#' @importFrom togglr toggl_start get_toggl_api_token set_toggl_api_token
#' @importFrom config get
#' @importFrom cli cli_bullets
start_time_tracking <- function(
    description = "R Development for GMH Leasing Dashboard",
    tags = c(),
    config = config::get("toggl"),
    ...
) {

  api_key <- togglr::get_toggl_api_token(ask = FALSE)
  if (is.null(api_key)) {
    api_key <- config$api_token
    togglr::set_toggl_api_token(api_key)
  }

  if (as.logical(config$is_billable) == TRUE) {
    tags <- c("Billable", tags)
  }

  res <- togglr::toggl_start(
    description = description,
    client = config$client_name,
    project_name = config$project_name,
    api_token = api_key,
    tags = tags
  )

  cli::cli_bullets(
    c(
      "v" = "Time Tracking Started via Toggl (ID: {.field {res}})",
      "i" = "Description: {.field {description}}",
      "i" = "Client: {.field {config$client_name}}",
      "i" = "Project: {.field {config$project_name}}",
      "i" = "Tags: {.field {tags}}",
      ">" = "To Stop Tracking run {.code stop_time_tracking()}"
    )
  )

  return(res)

}

#' @rdname time_tracking
#' @export
#' @importFrom togglr toggl_stop
#' @importFrom cli cli_abort cli_bullets
#' @importFrom rlang current_env
stop_time_tracking <- function(...) {

  call_env <- rlang::current_env()

  res <- tryCatch({
    togglr::toggl_stop(...)
  }, error = function(e, call = call_env) {
    cli::cli_abort(
      c(
        "Failed to stop time tracking via Toggl. Error: {.error {e}}",
        "Are tou sure you started tracking time?"
      ),
      call = call
    )
  })

  cli::cli_bullets(
    c(
      "v" = "Time Tracking Stopped via Toggl",
      ">" = "To view the time entry run {.code get_tracked_time()}"
    )
  )

}

#' @rdname time_tracking
#' @export
#' @importFrom lubridate weeks
#' @importFrom togglr get_time_entries
get_tracked_time <- function(
    start = Sys.time() - lubridate::weeks(1),
    end = Sys.time(),
    ...
) {
  togglr::get_time_entries(since = start, until = end, ...)
}
