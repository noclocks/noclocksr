pkg_name <- read.dcf("DESCRIPTION")[, "Package"]
pkg_version <- read.dcf("DESCRIPTION")[, "Version"]

test_results <- tibble::as_tibble(devtools::test())

