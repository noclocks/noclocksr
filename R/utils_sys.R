get_sys_path <- function() {
  Sys.getenv("PATH") |> stringr::str_split(";") |> unlist()
}

test_sys_path <- function(value) {

  if (Sys.which(value) == "") {
    return(FALSE)
  }

  return(TRUE)

}
