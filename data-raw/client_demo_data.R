# pak::pak("ThinkR-open/fakir")
require(fakir)
require(tibble)
require(dplyr)

client_db <- fakir::fake_base_clients(5, local = c("en_US"))
client_tickets <- fakir::fake_ticket_client(vol = 1500, n = 500, seed = 4321, split = TRUE, local = c("en_US"))

clients <- client_tickets$clients |>
  dplyr::rename(department = departement) |>
  dplyr::arrange(id_dpt, department) |>
  tidyr::fill(department) |>
  dplyr::mutate(
    entry_year = lubridate::year(entry_date),
    age_class = cut(age, breaks = c(18, 25, 40, 55, 70, 100), include.lowest = TRUE)
  )

usethis::use_data(clients, overwrite = TRUE)
