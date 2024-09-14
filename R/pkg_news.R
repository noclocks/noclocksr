# ------------------------------------------------------------------------
#
# Title : Package NEWS.md Management
#    By : Jimmy Briggs
#  Date : 2024-09-14
#
# ------------------------------------------------------------------------

# generate_news -----------------------------------------------------------

#' Generate `NEWS.md`
#'
#' @description
#' These functions generate the R package's `NEWS.md` file.
#'
#' @details
#' - `generate_news()`: Generates a `NEWS.md` file by calling
#'   `generate_news_from_changelog()` with default settings,
#'   and will default to a generic `NEWS.md` file if no `CHANGELOG.md`
#'   file is found.
#'
#' - `generate_news_from_changelog()`: Generates a `NEWS.md` file from a
#'   pre-existing `CHANGELOG.md` file. It parses the Markdown content of
#'   the `CHANGELOG.md` file, extracts version headers, sections, and their
#'   content, and organizes them into a structured format suitable for
#'   a typical R package's `NEWS.md` file.
#'
#' @param input_file Path to the `CHANGELOG.md` file.
#' @param output_file Path to the output `NEWS.md` file.
#' @param include_unreleased Logical indicating whether to include the
#'   `[Unreleased]` section (default: `TRUE`).
#' @param remove_commits Logical indicating whether to remove commit hashes
#'   and authors from the list items (default: `TRUE`).
#' @param version_pattern Regular expression pattern to match version headers
#'   (default: `^\\[(Unreleased|\\d+\\.\\d+\\.\\d+(?:-\\w+)?)\\]`).
#' @param ordered_groups Character vector specifying the ordered groups for
#'   sections in the `NEWS.md` file (default: `.ordered_groups`).
#'   The default order is based on the significance of the groups.
#' @param skip_groups Character vector specifying the groups to skip when
#'   generating the `NEWS.md` file (default: `NULL`).
#' @param section_name_mapping Named character vector to map section names
#'   to custom names in the `NEWS.md` file (default: `NULL`).
#'   The names should match the group names in the `CHANGELOG.md` file.
#' @param verbose Logical indicating whether to display messages (default: `TRUE`).
#' @param overwrite Logical indicating whether to overwrite existing `NEWS.md` file (default: `FALSE`).
#' @param pkg_name Package name (default: `NULL`). If `NULL`, reads from `DESCRIPTION`.
#' @param pkg_version Package version (default: `NULL`). If `NULL`, reads from `DESCRIPTION`.
#' @param pkg_path Path to the package directory containing `DESCRIPTION` (default: `NULL`).
#' @param ... Arguments passed on to `generate_news_from_changelog()` from
#'   `generate_news()`.
#'
#' @return Both functions invisibly return the generated `news_content`
#'   as a character vector.
#'
#' @export
#'
#' @seealso [use_github_action_news()] for implementing this into a GitHub Action
#'   Workflow.
#'
#' @importFrom markdown markdownToHTML
#' @importFrom xml2 read_html xml_children xml_find_first xml_name xml_text xml_find_all
#' @importFrom stringr str_detect str_match str_replace str_trim
#' @importFrom rlang abort
#' @importFrom cli cli_alert_success cli_alert_info cli_alert_warning
#' @importFrom usethis use_news_md
#'
#' @examples
#' if (interactive()) {
#'
#' # Examples of using the `generate_news()` function:
#' generate_news()
#'
#' # Examples of using the `generate_news_from_changelog()` function:
#'
#' # Generate NEWS.md from CHANGELOG.md using all default settings
#' generate_news_from_changelog()
#'
#' # Specify custom input and output files
#' generate_news_from_changelog(
#'   input_file = "path/to/your/CHANGELOG.md",
#'   output_file = "path/to/your/NEWS.md"
#' )
#'
#' # Overwrite the existing NEWS.md file
#' generate_news_from_changelog(overwrite = TRUE)
#'
#' # Exclude the 'Unreleased' section and keep commit hashes in the list items
#' generate_news_from_changelog(include_unreleased = FALSE, remove_commits = FALSE)
#'
#' # Skip certain sections
#' generate_news_from_changelog(skip_groups = c("Miscellaneous Tasks", "Meta"))
#'
#' # Map section names to custom names
#' generate_news_from_changelog(
#'   section_name_mapping = c("Added" = "Features", "Fixed" = "Bug Fixes")
#' )
#'
#' # Use custom ordered groups
#' custom_ordered_groups <- c(
#'   "Breaking Changes", "Features", "Bug Fixes", "Documentation", "Testing"
#' )
#' generate_news_from_changelog(ordered_groups = custom_ordered_groups)
#'
#' }
generate_news <- function(
    output_file = "NEWS.md",
    ...
) {

  if (!file.exists("CHANGELOG.md") && !file.exists("inst/CHANGELOG.md")) {

    cli::cli_alert_info(
      c(
        "No {.code CHANGELOG.md} file found in the package directory.",
        "Using default {.code NEWS.md}."
      )
    )

    usethis::use_news_md(open = FALSE)

    res <- readLines("NEWS.md")

    return(invisible(res))

  }

  clog_path <- if (file.exists("CHANGELOG.md")) {
    "CHANGELOG.md"
  } else {
    "inst/CHANGELOG.md"
  }

  cli::cli_alert_info(
    c(
      "Generating {.code NEWS.md} from {.code CHANGELOG.md}."
    )
  )

  res <- generate_news_from_changelog(
    input_file = clog_path,
    output_file = output_file,
    ...
  )

  return(invisible(res))

}

# generate_news_from_changelog --------------------------------------------

#' @rdname generate_news
#'
#' @export
generate_news_from_changelog <- function(
    input_file = "CHANGELOG.md",
    output_file = "NEWS.md",
    include_unreleased = TRUE,
    remove_commits = TRUE,
    version_pattern = "^\\[(Unreleased|\\d+\\.\\d+\\.\\d+(?:-\\w+)?)\\]",
    ordered_groups = .ordered_groups,
    skip_groups = NULL,
    section_name_mapping = NULL,
    verbose = TRUE,
    overwrite = FALSE,
    pkg_name = NULL,
    pkg_version = NULL,
    pkg_path = NULL
) {

  # Check if input file exists and read content
  if (!file.exists(input_file)) {
    rlang::abort("Input file does not exist: {.path {input_file}}.")
  }
  if (verbose) {
    cli::cli_alert_info("Reading {.path {input_file}}")
  }

  changelog_content <- readLines(input_file)
  if (length(changelog_content) == 0) {
    rlang::abort("The {.code CHANGELOG.md} file is empty.")
  }

  # Convert Markdown to HTML
  if (verbose) {
    cli::cli_alert_info("Converting Markdown to HTML")
  }
  changelog_html <- markdown::markdownToHTML(
    text = changelog_content,
    fragment.only = TRUE
  )
  if (length(changelog_html) == 0) {
    rlang::abort("Failed to convert CHANGELOG.md to HTML. The resulting HTML is empty.")
  }


  # Parse HTML content
  if (verbose) {
    cli::cli_alert_info("Parsing HTML content")
  }
  changelog_xml <- xml2::read_html(changelog_html)

  # Get all nodes under the body
  body_nodes <- xml2::xml_children(
    xml2::xml_find_first(
      changelog_xml,
      ".//body"
    )
  )

  # Initialize variables to store versions and their sections
  versions <- list()
  current_version <- NULL
  current_section <- NULL

  heading_levels <- c("h2", "h3", "h4", "h5", "h6")

  # Loop through the body nodes to collect content under each version and section
  for (node in body_nodes) {
    node_name <- xml2::xml_name(node)
    node_text <- xml2::xml_text(node)

    if (stringr::str_detect(node_text, version_pattern)) {
      # New version header found
      current_version <- node_text
      versions[[current_version]] <- list()
      current_section <- NULL
      if (verbose) {
        cli::cli_alert_info("Found version: {current_version}")
      }
    } else if (node_name %in% heading_levels && !is.null(current_version)) {
      # New section under the current version
      current_section <- node_text
      versions[[current_version]][[current_section]] <- list()
      if (verbose) {
        cli::cli_alert_info("  Found section: {current_section}")
      }
    } else {
      # Add node to the current section of the current version
      if (!is.null(current_version) && !is.null(current_section)) {
        versions[[current_version]][[current_section]] <- c(
          versions[[current_version]][[current_section]], list(node)
        )
      }
    }
  }

  # Read package name and version from DESCRIPTION or use provided values
  if (is.null(pkg_name) || is.null(pkg_version)) {
    if (is.null(pkg_path)) {
      pkg_path <- "."
    }
    description_file <- file.path(pkg_path, "DESCRIPTION")
    if (!file.exists(description_file)) {
      rlang::abort(
        c(
          "{.code DESCRIPTION} file not found at {.path {description_file}}.",
          "Please provide the {.arg pkg_name} and {.arg pkg_version} arguments, or specify the {.arg pkg_path}."
        )
      )
    }
    if (verbose) {
      cli::cli_alert_info("Reading package info from {.path {description_file}}")
    }
    description_content <- read.dcf(description_file)
    if (is.null(pkg_name)) {
      pkg_name <- description_content[1, "Package"]
      if (verbose) {
        cli::cli_alert_info("Using package name from DESCRIPTION: {pkg_name}")
      }
    }
    if (is.null(pkg_version)) {
      pkg_version <- description_content[1, "Version"]
      if (verbose) {
        cli::cli_alert_info("Using package version from DESCRIPTION: {pkg_version}")
      }
    }
  } else {
    if (verbose) {
      cli::cli_alert_info("Using provided package name: {pkg_name}")
      cli::cli_alert_info("Using provided package version: {pkg_version}")
    }
  }

  # Initialize NEWS.md content
  news_content <- character()

  # Process versions in order, placing '[Unreleased]' first if included
  version_names <- names(versions)

  # Extract version numbers
  version_numbers <- sapply(version_names, function(vn) {
    vm <- stringr::str_match(
      vn,
      "^\\[(Unreleased|\\d+\\.\\d+\\.\\d+(?:-\\w+)?)\\]\\s*-?\\s*(.*)$"
    )
    vm[1, 2]
  })

  # Identify 'Unreleased' and other versions
  is_unreleased <- version_numbers == "Unreleased"
  unreleased_versions <- version_names[is_unreleased]
  other_versions <- version_names[!is_unreleased]

  # Convert other version numbers to package_version for sorting
  other_version_numbers <- version_numbers[!is_unreleased]
  parsed_versions <- package_version(other_version_numbers)

  # Order other versions in decreasing order
  order_indices <- order(parsed_versions, decreasing = TRUE)
  other_versions <- other_versions[order_indices]

  # Combine versions based on include_unreleased flag
  if (include_unreleased && length(unreleased_versions) > 0) {
    version_names_ordered <- c(unreleased_versions, other_versions)
  } else {
    version_names_ordered <- other_versions
  }

  # Now process versions in order
  for (version_name in version_names_ordered) {
    # Extract version number and date if available
    version_header <- version_name
    version_match <- stringr::str_match(
      version_name,
      "^\\[(Unreleased|\\d+\\.\\d+\\.\\d+(?:-\\w+)?)\\]\\s*-?\\s*(.*)$"
    )
    version_number <- version_match[1, 2]
    version_date <- version_match[1, 3]

    # Skip 'Unreleased' if not included
    if (!include_unreleased && version_number == "Unreleased") next

    # Build version header
    if (!is.na(version_number)) {
      version_header <- sprintf("# %s %s", pkg_name, version_number)
      if (version_date != "") {
        version_header <- sprintf("%s (%s)", version_header, version_date)
      }
    } else {
      # If version header doesn't match expected pattern, use it as is
      version_header <- sprintf("# %s %s", pkg_name, version_name)
    }

    # Add version header to NEWS.md
    news_content <- c(news_content, version_header, "")

    # Get the sections under the current version
    sections <- versions[[version_name]]

    # Process sections in the order of significance
    for (group_name in ordered_groups) {
      # Skip groups if specified
      if (!is.null(skip_groups) && group_name %in% skip_groups) next

      if (group_name %in% names(sections)) {
        # Map section name if mapping is provided
        mapped_name <- if (!is.null(section_name_mapping) && group_name %in% names(section_name_mapping)) {
          section_name_mapping[[group_name]]
        } else {
          group_name
        }

        # Add the section heading with appropriate heading level
        news_section_header <- sprintf("## %s", mapped_name)
        news_content <- c(news_content, news_section_header, "")

        # Process the nodes in sections[[group_name]]
        for (node in sections[[group_name]]) {
          node_name <- xml2::xml_name(node)
          if (node_name %in% c("ul", "ol")) {
            # List items
            items <- xml2::xml_find_all(node, ".//li")
            for (item in items) {
              item_text <- xml2::xml_text(item)
              # Optionally clean up item_text to remove commit hashes and authors
              if (remove_commits) {
                item_text <- stringr::str_replace(
                  item_text,
                  "\\s*\\(\\w{7}\\)\\s*-\\s*\\(.*?\\)\\s*$",
                  ""
                )
              }
              news_item <- paste0("* ", item_text)
              news_content <- c(news_content, news_item)
            }
          } else {
            # Other text, add as is if not empty
            item_text <- stringr::str_trim(xml2::xml_text(node))
            if (item_text != "") {
              news_item <- paste0("* ", item_text)
              news_content <- c(news_content, news_item)
            }
          }
        }

        # Add an empty line after each section
        news_content <- c(news_content, "")
      }
    }

    # Process any remaining sections not in ordered_groups
    remaining_sections <- setdiff(names(sections), ordered_groups)
    for (section_name in remaining_sections) {
      # Skip groups if specified
      if (!is.null(skip_groups) && section_name %in% skip_groups) next

      # Map section name if mapping is provided
      mapped_name <- if (!is.null(section_name_mapping) && section_name %in% names(section_name_mapping)) {
        section_name_mapping[[section_name]]
      } else {
        section_name
      }

      # Add the section heading
      news_section_header <- sprintf("## %s", mapped_name)
      news_content <- c(news_content, news_section_header, "")

      # Process the nodes in sections[[section_name]]
      for (node in sections[[section_name]]) {
        node_name <- xml2::xml_name(node)
        if (node_name %in% c("ul", "ol")) {
          items <- xml2::xml_find_all(node, ".//li")
          for (item in items) {
            item_text <- xml2::xml_text(item)
            # Optionally clean up item_text to remove commit hashes and authors
            if (remove_commits) {
              item_text <- stringr::str_replace(
                item_text,
                "\\s*\\(\\w{7}\\)\\s*-\\s*\\(.*?\\)\\s*$",
                ""
              )
            }
            news_item <- paste0("* ", item_text)
            news_content <- c(news_content, news_item)
          }
        } else {
          item_text <- stringr::str_trim(xml2::xml_text(node))
          if (item_text != "") {
            news_item <- paste0("* ", item_text)
            news_content <- c(news_content, news_item)
          }
        }
      }

      # Add an empty line after each section
      news_content <- c(news_content, "")
    }
  }

  # Print the news content if verbose
  if (verbose) {
    cli::cli_alert_info("Generated NEWS.md content:")
    cat(news_content, sep = "\n")
  }

  # Write the NEWS.md content to the output file
  if (file.exists(output_file) && !overwrite) {
    rlang::abort(
      c(
        "Output file already exists: {.path {output_file}}.",
        "Use `overwrite = TRUE` to overwrite."
      )
    )
  }

  writeLines(news_content, output_file)
  if (verbose) {
    cli::cli_alert_success("{.path {output_file}} file generated successfully.")
  }

  return(invisible(news_content))
}


# use_github_action_news ----------------------------------------

#' Generate GitHub Action Workflow for NEWS.md Generation
#'
#' @description
#' This function generates a GitHub Action workflow YAML file that automates
#' the generation of `NEWS.md` from `CHANGELOG.md` whenever changes are pushed
#' to the repository.
#'
#' @param file_name Name of the output workflow file (default: `news.yml`).
#' @param changelog_path Path to the `CHANGELOG.md` file (default: `CHANGELOG.md`).
#' @param config_path Path to the `cliff.toml` configuration file (default: `.github/cliff.toml`).
#' @param overwrite Logical indicating whether to overwrite the existing workflow file (default: `TRUE`).
#' @param verbose Logical indicating whether to display messages (default: `TRUE`).
#'
#' @return Invisibly returns `NULL`.
#'
#' @export
#'
#' @importFrom rlang abort
#' @importFrom cli cli_alert_success cli_alert_info
#'
#' @examples
#' if (interactive()) {
#'   generate_github_action_workflow()
#' }
use_github_action_news <- function(
    file_name = "news.yml",
    news_md_path = "NEWS.md",
    changelog_path = "CHANGELOG.md",
    overwrite = TRUE,
    verbose = TRUE
) {

  output_file <- file.path(".github", "workflows", file_name)

  if (file.exists(output_file) && !overwrite) {
    rlang::abort(
      c(
        "Output file already exists: {.path {output_file}}.",
        "Use `overwrite = TRUE` to overwrite."
      )
    )
  }

  if (verbose) {
    cli::cli_alert_info("Generating GitHub Action workflow at {.path {output_file}}")
  }

  workflow_template <- "github-workflows/news.yml.template"

  workflow_template_params <- list(
    changelog_path = changelog_path,
    news_md_path = news_md_path,
    token = "${{ secrets.GITHUB_TOKEN }}"
  )

  usethis::use_template(
    workflow_template,
    output_file,
    data = workflow_template_params,
    package = "noclocksr"
  )

  if (verbose) {
    cli::cli_alert_success("GitHub Action workflow file created at {.path {output_file}}")
  }

  return(invisible(NULL))
}

# Internal ----------------------------------------------------------------

.ordered_groups <- c(
  "Features",
  "Added",
  "Bug Fixes",
  "Fixed",
  "Changed",
  "Performance",
  "Security",
  "Refactoring",
  "Testing",
  "Documentation",
  "Configuration",
  "Design",
  "Cleanup",
  "Infrastructure",
  "DevOps",
  "Deployment",
  "Application",
  "API",
  "Data",
  "Database",
  "Setup",
  "Styling",
  "Miscellaneous Tasks",
  "Meta"
)
