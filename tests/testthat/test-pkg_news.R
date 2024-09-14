test_that("generate_news_from_changelog works with default parameters", {
  # Create a temporary directory
  tmp_dir <- tempdir()

  # Write a sample CHANGELOG.md
  changelog_content <- c(
    "# Changelog",
    "",
    "All notable changes to this project will be documented in this file.",
    "",
    "## [Unreleased]",
    "",
    "### Added",
    "- New feature A",
    "- New feature B",
    "",
    "### Fixed",
    "- Bug fix 1",
    "- Bug fix 2",
    "",
    "## [1.0.1] - 2023-09-14",
    "",
    "### Fixed",
    "- Minor bug fix",
    "",
    "## [1.0.0] - 2023-09-13",
    "",
    "### Added",
    "- Initial release",
    ""
  )
  writeLines(changelog_content, file.path(tmp_dir, "CHANGELOG.md"))

  # Write a sample DESCRIPTION file
  description_content <- c(
    "Package: testpackage",
    "Type: Package",
    "Title: Test Package",
    "Version: 1.0.0",
    "Authors@R: person('First', 'Last', email = 'first.last@example.com', role = c('aut', 'cre'))",
    "Description: A test package.",
    "License: MIT"
  )
  writeLines(description_content, file.path(tmp_dir, "DESCRIPTION"))

  # Call the function
  output_file <- file.path(tmp_dir, "NEWS.md")
  generate_news_from_changelog(
    input_file = file.path(tmp_dir, "CHANGELOG.md"),
    output_file = output_file,
    verbose = FALSE,
    pkg_path = tmp_dir,
    overwrite = TRUE
  )

  # Check that the NEWS.md file was created
  expect_true(file.exists(output_file))

  # Read the NEWS.md content
  news_content <- readLines(output_file)

  # Check that the content contains expected entries
  expect_true(any(grepl("# testpackage Unreleased", news_content)))
  expect_true(any(grepl("## Added", news_content)))
  expect_true(any(grepl("\\* New feature A", news_content)))

  # Clean up
  unlink(tmp_dir)
})

test_that("generate_news_from_changelog handles missing DESCRIPTION", {
  # Create a temporary directory
  tmp_dir <- tempdir()

  # Write a sample CHANGELOG.md
  changelog_content <- c(
    "## [1.0.0] - 2023-09-13",
    "",
    "### Added",
    "- Initial release",
    ""
  )
  writeLines(changelog_content, file.path(tmp_dir, "CHANGELOG.md"))

  # Call the function without a DESCRIPTION file
  output_file <- file.path(tmp_dir, "NEWS.md")

  expect_snapshot(
    x = {
      generate_news_from_changelog(
        input_file = file.path(tmp_dir, "CHANGELOG.md"),
        output_file = output_file,
        verbose = FALSE,
        pkg_path = tmp_dir
      )
    },
    error = TRUE
  )

  # Clean up
  unlink(tmp_dir)
})
