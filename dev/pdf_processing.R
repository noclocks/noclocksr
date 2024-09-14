#' Process PDF Invoices and Receipts
#'
#' @description
#' This function processes PDF invoices and receipts by extracting the content,
#' parsing the content, and saving the files to the output directory.
#'
#' @details
#' This function implements PDF extraction by extracting the PDF content via
#' [pdftools::pdf_text()] and parsing the extracted text into the following
#' components:
#'   - Document Type (Receipt or Invoice)
#'   - Date
#'   - Company Name
#'   - ID (Receipt or Invoice Number)
#'   - New File Name (Formatted as `YYYY-MM-DD-Company-DocumentType-ID.pdf`)
#'
#' The PDF file is then copied and renamed using the new file name inside of the
#' specified output directory and archived in the specified archive directory.
#'
#' Logs of the processing are written to a log file.
#'
#' @param input_dir (Required) The directory containing the PDF files to process.
#' @param output_dir (Required) The directory to save the processed PDF files.
#' @param archive_dir (Optional) The directory to archive the processed PDF files.
#' @param log_file (Optional) The path to the log file. Default is `getOption("log_file")`,
#'   and if that is not set it will default to the path `Logs/` in the specified
#'   output directory.
#' @param ... Additional arguments
#'
#' @return A list of the processed PDF files in the output directory.
#' @export
#'
#' @importFrom fs dir_exists dir_info dir_ls path_dir path file_exists file_create
#' @importFrom cli cli_progress_bar cli_progress_update cli_progress_done
#' @importFrom assertthat assert_that
#' @importFrom stringr str_extract str_trim
#' @importFrom pdftools pdf_text pdf_data
#' @importFrom purrr map pluck
#' @importFrom glue glue
#'
#' @examples
#' \dontrun{
#' process_pdfs(
#'   input_dir = fs::path_package("noclocksr", "PDFs"),
#'   output_dir = fs::path("output"),
#'   archive_dir = fs::path("archive"),
#'   log_file = fs::path("Logs", paste0(Sys.Date(), ".log"))
#' )
#' }
#'
#' @seealso
#' [extract_pdf_content()], [parse_pdf_content()]
#' [pdftools::pdf_text()], [pdftools::pdf_data()]
process_pdfs <- function(
    input_dir,
    output_dir,
    archive_dir = fs::path(
      input_dir,
      "Archive",
      Sys.Date()
    ),
    log_file = getOption(
      "log_file",
      fs::path(
        output_dir,
        "Logs",
        paste0(
          Sys.Date(),
          ".log"
        )
      )
    ),
    ...
) {

  if (!is.null(log_file)) {
    if (!fs::file_exists(log_file)) {
      if (!fs::dir_exists(fs::path_dir(log_file))) {
        fs::dir_create(fs::path_dir(log_file), recurse = TRUE)
      }
      fs::file_create(log_file)
    }
    if (is.null(getOption(log_file))) {
      options("log_file" = log_file)
    }
  } else {
    cli::cli_warn("⚠️ No log file specified. Logging to console only.")
  }

  write_log(
    message = "Setting up PDF Processing...",
    log_lvl = "INFO",
    event = "Start"
  )

  invisible(
    assertthat::assert_that(
      fs::dir_exists(input_dir),
      nrow(fs::dir_info(input_dir, glob = "*.pdf")) > 0,
      msg = "The input directory must exist and contain PDF files."
    )
  )

  if (!fs::dir_exists(output_dir)) {
    fs::dir_create(output_dir, recurse = TRUE)
    write_log(
      message = glue::glue(
        "Created output directory: {output_dir}"
      ),
      log_lvl = "INFO",
      event = "Success"
    )
  }

  pdf_files <- fs::dir_ls(input_dir, glob = "*.pdf")

  write_log(
    message = glue::glue(
      "Found {length(pdf_files)} PDF files in {input_dir}"
    ),
    log_lvl = "INFO",
    event = "Search"
  )

  cli::cli_progress_bar(
    name = "Processing PDFs",
    # status = "Processing",
    # type = "iterator",
    total = length(pdf_files)#,
    # format = "{cli::pb_spin} Processing PDF File {cli::pb_current}/{cli::pb_total} {cli::pb_percent}\n{cli::pb_bar}",
  )

  for (pdf_file in pdf_files) {

    # browser()

    write_log(
      message = glue::glue(
        "Processing {pdf_file}..."
      ),
      log_lvl = "INFO",
      event = "Process"
    )

    pdf_content <- extract_pdf_content(pdf_file)
    pdf_content_parsed <- tryCatch({
      parse_pdf_content(pdf_content)
    }, error = function(e) {
      message <- glue::glue(
        "Error processing {pdf_file}: {e$message}"
      )
      write_log(
        message = message,
        log_lvl = "ERROR",
        event = "Error"
      )
      next # Skip to the next iteration
    }, finally = {
      if (is.null(pdf_content_parsed)) {
        next # Skip to the next iteration
      }
    })

    output_file <- fs::path(
      output_dir,
      paste0(pdf_content_parsed$type, "s"),
      pdf_content_parsed$company,
      pdf_content_parsed$new_file_name
    )

    if (fs::file_exists(output_file)) {
      write_log(
        message = glue::glue(
          "File {output_file} already exists. Overwriting..."
        ),
        log_lvl = "WARNING",
        event = "Warning"
      )
    }

    fs::dir_create(
      dirname(output_file),
      recurse = TRUE
    )

    fs::file_copy(pdf_file, output_file, overwrite = TRUE)

    write_log(
      message = glue::glue(
        "Processed {pdf_file} to {output_file}"
      ),
      log_lvl = "INFO",
      event = "Success"
    )

    if (!fs::dir_exists(archive_dir)) {
      fs::dir_create(archive_dir, recurse = TRUE)
    }

    fs::file_move(pdf_file, fs::path(archive_dir, basename(pdf_file)))

    write_log(
      message = glue::glue(
        "Archived {pdf_file} to {archive_dir}"
      ),
      log_lvl = "INFO",
      event = "Saved"
    )

    cli::cli_progress_update()

    write_log(
      message = glue::glue(
        "Finished processing {pdf_file}"
      ),
      log_lvl = "INFO",
      event = "Stop"
    )

  }

  cli::cli_progress_done()

  invisible(fs::dir_info(output_dir, glob = "*.pdf"))

}

extract_pdf_content <- function(path, ...) {

  assertthat::assert_that(
    fs::path_ext(path) == "pdf",
    msg = "The file must be a PDF."
  )

  assertthat::assert_that(
    fs::file_exists(path),
    msg = "The file does not exist."
  )

  pdf_content <- pdftools::pdf_text(path)

  assertthat::assert_that(
    !is.null(pdf_content),
    class(pdf_content) == "character",
    length(pdf_content) > 0,
    stringr::str_extract(pdf_content, stringr::boundary("word"))[[1]] %in% c("Receipt", "Invoice"),
    msg = "The extracted PDF content is not valid."
  )

  return(pdf_content)

}

parse_pdf_content <- function(pdf_content, ...) {

  assertthat::assert_that(
    !is.null(pdf_content),
    class(pdf_content) == "character",
    length(pdf_content) > 0,
    stringr::str_extract(pdf_content, stringr::boundary("word"))[[1]] %in% c("Receipt", "Invoice"),
    msg = "The extracted PDF content is not valid."
  )

  # Determine document type (Receipt or Invoice)
  doc_type <- stringr::str_extract(pdf_content, stringr::boundary("word"))[[1]]
  assertthat::assert_that(
    !is.null(doc_type),
    msg = "The document type could not be determined."
  )

  # Extract date from the appropriate line using global regex pattern
  date_raw <- stringr::str_extract(
    pdf_content,
    "(?<=Date paid |paid on |Date of issue |due )[A-Za-z]+ \\d{1,2}, \\d{4}"
  )

  assertthat::assert_that(
    !is.na(date_raw),
    !is.null(date_raw),
    msg = "The date could not be extracted."
  )

  date <- format(
    as.Date(
      date_raw,
      format = "%B %d, %Y"
    ),
    "%Y-%m-%d"
  ) |> as.character()

  assertthat::assert_that(
    !is.na(date),
    !is.null(date),
    nchar(date) == 10,
    msg = "The date could not be formatted."
  )

  # Extract company name from the address block by finding the text right
  # before "Bill to"\
  # example: "\nFly.io, Inc.                                       Bill to\n2261 Market Street #4990"
  # company: Fly.io, Inc.
  company_line <- stringr::str_extract(
    pdf_content,
    "(?<=\\n)[A-Za-z\\. ]+(?=\\n\\d{4} |\\n\\d{3,5} )"
  )

  if (is.na(company_line)) {
    company_line <- stringr::str_extract(
      pdf_content,
      "(?<=\\n)[A-Za-z\\.,\\s]+(?=\\s+Bill to)"
    )
  }

  company_line <- company_line |>
    stringr::str_trim()

  company <- stringr::str_extract(
    company_line,
    "[A-Za-z\\.]+"
  )

  assertthat::assert_that(
    !is.na(company),
    !is.null(company),
    company != "",
    msg = "Company name not found or invalid"
  )

  # Extract ID from the "Receipt" or "Invoice" number line
  id <- ifelse(
    doc_type == "Receipt",
    stringr::str_extract(
      pdf_content,
      "(?<=Receipt number )[\\d\\-]+"
    ),
    stringr::str_extract(
      pdf_content,
      "(?<=Invoice number )[A-Z\\d\\-]+"
    )
  )

  assertthat::assert_that(
    !is.na(id),
    id != "",
    msg = "ID not found or invalid"
  )

  new_file_name <- glue::glue(
    "{date}-{company}-{doc_type}-{id}.pdf"
  )

  list(
    type = doc_type,
    date = date,
    company = company,
    id = id,
    new_file_name = new_file_name
  )
}

#' Write Log
#'
#' @description
#' Write log messages to the console and a log file.
#'
#' @param message (Required) Character string of the message to log.
#' @param log_file (Optional) The path to the log file. Default is `getOption("log_file")`.
#' @param log_lvl (Optional) The log level. Default is `INFO`.
#' @param event (Optional) The event type. Default is `Process`.
#'
#' @return Invisibly returns the log message.
#' @export
#'
#' @importFrom fs file_exists dir_exists dir_create file_create file_copy file_move
#' @importFrom cli cat_line cli_warn
#' @importFrom glue glue
write_log <- function(message,
                      log_file = getOption("log_file"),
                      log_lvl = "INFO",
                      event = "Process") {

  if (!is.null(log_file)) {
    if (!fs::file_exists(log_file)) {
      if (!fs::dir_exists(fs::path_dir(log_file))) {
        fs::dir_create(fs::path_dir(log_file), recurse = TRUE)
      }
      fs::file_create(log_file)
    }
  } else {
    cli::cli_warn("⚠️ No log file specified. Logging to console only.")
  }

  color <- switch(
    log_lvl,
    TRACE = "gray",
    DEBUG = "orange",
    INFO = "cyan",
    WARNING = "yellow",
    WARN = "yellow",
    ERROR = "red",
    FATAL = "maroon",
    CRITICAL = "darkred",
    "black"
  )

  event_sym <- switch(
    event,
    Start = "🚀",
    Stop = "🛑",
    Pause = "⏸",
    Search = "🔍",
    Process = "🔄",
    Success = "✅",
    Failure = "❌",
    Saved = "💾",
    Loaded = "📂",
    Info = "ℹ️",
    Warning = "⚠️",
    Error = "❌",
    Fatal = "💀",
    Critical = "🚨",
    "📝"
  )

  cli::cat_line(
    glue::glue(
      "{event_sym} [{log_lvl}]: {message}"
    ),
    col = color
  )

  msg <- glue::glue(
    "\n{Sys.time()} [{log_lvl}]: {message}\n"
  )

  if (!is.null(log_file)) {
    cat(
      msg,
      file = log_file,
      append = TRUE,
      sep = "\n"
    )
  }
}

extract_date_from_pdf <- function(pdf_content) {
  hold <- stringr::str_extract(
    pdf_content,
    "(?<=paid on )\\w+ \\d{1,2}, \\d{4}"
  )
  if (is.null(hold) || is.na(hold) || hold == "") {
    hold <- stringr::str_extract(
      pdf_content,
      "(?<=Date paid )[A-Za-z]+ \\d{1,2}, \\d{4}"
    )
  }
  if (is.null(hold) || is.na(hold) || hold == "") {
    hold <- stringr::str_extract(
      pdf_content,
      "(?<=Date: )\\w+ \\d{1,2}, \\d{4}"
    )
  }
}


# test_pdf_receipt <- fs::path("inst/testfiles/Receipt-2217-5755 (2).pdf")
# test_pdf_invoice <- fs::path("inst/testfiles/Invoice-F091D19D-0002 (1).pdf")
#
# renamed_pdf_receipt <- "2024-05-08-Twenty.com-Receipt-2217-5775.pdf"
# renamed_pdf_invoice <- "2024-05-08-Twenty.com-Invoice-F091D19D-0002.pdf"
#
# test_pdf_receipt_text <- pdftools::pdf_text(test_pdf_receipt)
# test_pdf_invoice_text <- pdftools::pdf_text(test_pdf_invoice)
#
# test_pdf_receipt_data <- pdftools::pdf_data(test_pdf_receipt) |> purrr::pluck(1)
# test_pdf_invoice_data <- pdftools::pdf_data(test_pdf_invoice) |> purrr::pluck(1)
#
# test_pdf_receipt_type <- pdf_data$text[1]
# test_pdf_invoice_type <- pdf_data$text[1]
#
# test_pdf_receipt_date <- extract_date_from_pdf(test_pdf_receipt_text)
# test_pdf_invoice_date <- extract_date_from_pdf(test_pdf_invoice_text)






