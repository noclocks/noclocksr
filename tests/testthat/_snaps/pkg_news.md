# generate_news_from_changelog handles missing DESCRIPTION

    Code
      generate_news_from_changelog(input_file = file.path(tmp_dir, "CHANGELOG.md"),
      output_file = output_file, verbose = FALSE, pkg_path = tmp_dir)
    Condition
      Error in `generate_news_from_changelog()`:
      ! Output file already exists: {.path {output_file}}.
      * Use `overwrite = TRUE` to overwrite.

