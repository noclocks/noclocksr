
#  ------------------------------------------------------------------------
#
# Title : HTTP Status Codes Dataset
#    By : Jimmy Briggs
#  Date : 2024-06-19
#
#  ------------------------------------------------------------------------

require(tibble)


# status codes -----------------------------------------------------------

http_status_codes <- tibble::tribble(
  ~code, ~message, ~category,
  100L, "Continue", "Informational",
  101L, "Switching Protocols", "Informational",
  102L, "Processing", "Informational",
  103L, "Early Hints", "Informational",
  200L, "OK", "Success",
  201L, "Created", "Success",
  202L, "Accepted", "Success",
  203L, "Non-Authoritative Information", "Success",
  204L, "No Content", "Success",
  205L, "Reset Content", "Success",
  206L, "Partial Content", "Success",
  207L, "Multi-Status", "Success",
  208L, "Already Reported", "Success",
  226L, "IM Used", "Success",
  300L, "Multiple Choices", "Redirection",
  301L, "Moved Permanently", "Redirection",
  302L, "Found", "Redirection",
  303L, "See Other", "Redirection",
  304L, "Not Modified", "Redirection",
  305L, "Use Proxy", "Redirection",
  306L, "(Unused)", "Redirection",
  307L, "Temporary Redirect", "Redirection",
  308L, "Permanent Redirect", "Redirection",
  400L, "Bad Request", "Client Error",
  401L, "Unauthorized", "Client Error",
  402L, "Payment Required", "Client Error",
  403L, "Forbidden", "Client Error",
  404L, "Not Found", "Client Error",
  405L, "Method Not Allowed", "Client Error",
  406L, "Not Acceptable", "Client Error",
  407L, "Proxy Authentication Required", "Client Error",
  408L, "Request Timeout", "Client Error",
  409L, "Conflict", "Client Error",
  410L, "Gone", "Client Error",
  411L, "Length Required", "Client Error",
  412L, "Precondition Failed", "Client Error",
  413L, "Payload Too Large", "Client Error",
  414L, "URI Too Long", "Client Error",
  415L, "Unsupported Media Type", "Client Error",
  416L, "Range Not Satisfiable", "Client Error",
  417L, "Expectation Failed", "Client Error",
  418L, "I'm a teapot", "Client Error",
  421L, "Misdirected Request", "Client Error",
  422L, "Unprocessable Entity", "Client Error",
  423L, "Locked", "Client Error",
  424L, "Failed Dependency", "Client Error",
  425L, "Too Early", "Client Error",
  426L, "Upgrade Required", "Client Error",
  428L, "Precondition Required", "Client Error",
  429L, "Too Many Requests", "Client Error",
  431L, "Request Header Fields Too Large", "Client Error",
  451L, "Unavailable For Legal Reasons", "Client Error",
  500L, "Internal Server Error", "Server Error",
  501L, "Not Implemented", "Server Error",
  502L, "Bad Gateway", "Server Error",
  503L, "Service Unavailable", "Server Error",
  504L, "Gateway Timeout", "Server Error",
  505L, "HTTP Version Not Supported", "Server Error",
  506L, "Variant Also Negotiates", "Server Error",
  507L, "Insufficient Storage", "Server Error",
  508L, "Loop Detected", "Server Error",
  510L, "Not Extended", "Server Error",
  511L, "Network Authentication Required", "Server Error"
)

usethis::use_data(http_status_codes, overwrite = TRUE)


# document dataset --------------------------------------------------------

source(fs::path("data-raw/R/utils_data_docs.R"))

col_descs <- c(
  "The HTTP Status Code",
  "The HTTP Status Message",
  "The HTTP Status Category"
)

document_dataset(
  http_status_codes,
  name = "http_status_codes",
  description = "A dataset containing HTTP status codes and their corresponding messages.",
  source = "https://en.wikipedia.org/wiki/List_of_HTTP_status_codes",
  col_descs = col_descs
)

