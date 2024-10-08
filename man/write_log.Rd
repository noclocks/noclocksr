% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pdf.R
\name{write_log}
\alias{write_log}
\title{Write Log}
\usage{
write_log(
  message,
  log_file = getOption("log_file"),
  log_lvl = "INFO",
  event = "Process"
)
}
\arguments{
\item{message}{(Required) Character string of the message to log.}

\item{log_file}{(Optional) The path to the log file. Default is \code{getOption("log_file")}.}

\item{log_lvl}{(Optional) The log level. Default is \code{INFO}.}

\item{event}{(Optional) The event type. Default is \code{Process}.}
}
\value{
Invisibly returns the log message.
}
\description{
Write log messages to the console and a log file.
}
