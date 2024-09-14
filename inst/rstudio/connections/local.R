library(noclocksr)

noclocksr::set_config_file()
noclocksr::set_r_config("local")

db_config <- noclocksr::get_config("db")

connection <- noclocksr::db_connect(
  db_config = db_config,
  method = "DBI",
  rstudio_connection = TRUE
)
