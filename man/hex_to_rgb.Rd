% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils_colors.R
\name{hex_to_rgb}
\alias{hex_to_rgb}
\title{Converts Hex codes values to RGB vectors}
\usage{
hex_to_rgb(x)
}
\arguments{
\item{x}{A hex colour code}
}
\value{
A corresponding matrix of red, blue and green values
}
\description{
Converts Hex codes values to RGB vectors
}
\examples{
hex_to_rgb("purple")
hex_to_rgb("#fafafa")

}
