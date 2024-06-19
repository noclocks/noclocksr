library(noclocksR)

noclocksR::set_config_file()
noclocksR::set_r_config("local")

db_config <- noclocksR::get_config("db")

connection <- noclocksR::db_connect(
  db_config = db_config,
  method = "DBI",
  rstudio_connection = TRUE
)
