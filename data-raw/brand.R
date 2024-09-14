brandfetch_response_tspec <- tibblify::tspec_object(
  tibblify::tib_chr("id", required = FALSE),
  tibblify::tib_chr("name", required = FALSE),
  tibblify::tib_chr("domain", required = FALSE),
  tibblify::tib_lgl("claimed", required = FALSE),
  tibblify::tib_chr("description", required = FALSE),
  tibblify::tib_chr("longDescription", required = FALSE),
  tibblify::tib_dbl("qualityScore", required = FALSE),
  tibblify::tib_unspecified("images"),

  tibblify::tib_df(
    "links",
    tibblify::tib_chr("name", required = FALSE),
    tibblify::tib_chr("url", required = FALSE)
  ),

  tibblify::tib_df(
    "logos",
    tibblify::tib_chr("theme", required = FALSE),
    tibblify::tib_df(
      "formats",
      tibblify::tib_chr("src", required = FALSE),
      tibblify::tib_unspecified("background", required = FALSE),
      tibblify::tib_chr("format", required = FALSE),
      tibblify::tib_int("height", required = FALSE),
      tibblify::tib_int("width", required = FALSE),
      tibblify::tib_int("size", required = FALSE),
    ),
    tibblify::tib_unspecified("tags", required = FALSE),
    tibblify::tib_chr("type", required = FALSE)
  ),

  tibblify::tib_df(
    "colors",
    tibblify::tib_chr("hex", required = FALSE),
    tibblify::tib_chr("type", required = FALSE),
    tibblify::tib_int("brightness", required = FALSE),
  ),

  tibblify::tib_df(
    "fonts",
    tibblify::tib_chr("name", required = FALSE),
    tibblify::tib_chr("type", required = FALSE),
    tibblify::tib_chr("origin", required = FALSE),
    tibblify::tib_chr("originId", required = FALSE),
    tibblify::tib_unspecified("weights", required = FALSE),
  ),

  tibblify::tib_row(
    "company",
    tibblify::tib_unspecified("employees"),
    tibblify::tib_unspecified("foundedYear"),
    tibblify::tib_unspecified("kind"),
    tibblify::tib_unspecified("location"),
    tibblify::tib_df(
      "industries",
      tibblify::tib_unspecified("id", required = FALSE),
      tibblify::tib_unspecified("parent"),
      tibblify::tib_dbl("score", required = FALSE),
      tibblify::tib_chr("name", required = FALSE),
      tibblify::tib_chr("emoji", required = FALSE),
      tibblify::tib_chr("slug", required = FALSE)
    )
  )
)

usethis::use_data(
  brandfetch_response_tspec,
  overwrite = FALSE,
  internal = TRUE
)
