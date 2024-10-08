% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils_colors.R
\name{rgba_to_hex}
\alias{rgba_to_hex}
\title{Convert RGB to HEX}
\usage{
rgba_to_hex(colour_rgba, background_colour = "#ffffff", ...)
}
\arguments{
\item{colour_rgba}{A vector of length 4: c(red value, green value, blue value, alpha).
All colour values must be between 0 and 255. Alpha must be between 0 and 1.}

\item{background_colour}{Defaults to white. Users can specify a different colour to get
the hex code for their original colour blended with a specified background colour.
\code{background_colour} must either be a recognised colour name (e.g. "white"),
a hex colour code (e.g. "#ffffff") or vector of length 3 (red value, green value, blue value),
with all values between 0 and 255. The default value is white ("#ffffff").}

\item{...}{Allows for US spelling of color/colour.}
}
\value{
Returns the corresponding hex colour code
}
\description{
Convert RGB to HEX
}
\examples{
rgba_to_hex(c(52, 46, 39, 0.8))

rgba_to_hex(c(52, 46, 39, 0.8), "blue")

rgba_to_hex(c(52, 46, 39, 0.8), "#032cfc")
}
