# ---
# repo: noclocks/noclocksR
# file: standalone-db_connect.R
# last-updated:
# license: https://unlicense.org
# dependencies:
# imports: [cli, DBI, odbc, dplyr, config]
# ---


#' Connect to a Database
#'
#' @description
#' Connect to a database using the either the `DBI` or `pool` packages.
#'
#' This function is a wrapper around `DBI::dbConnect()` and `pool::dbPool()`.
#'
#' It assumes you have a `config.yml` file in the root of your project with
#' the database connection details nested under the value `db` or `database`.
#'
#' #' @details
#' ### Configuration
#'
#' A typical `config.yml` file would look like this:
#'
#' ```yaml
#' default:
#'   db:
#'     driver: "postgres"
#'     host: ""
#'     port: 5432
#'     dbname: ""
#'     user: ""
#'     password: ""
#'     sslmode: "require"
#'     options: ""
#'     url: ""
#' ```
#'
#' ### Connection Methods
#'
#' The `method` argument can be either `DBI` or `pool`. The `DBI` method is
#' used to create a single connection to the database, while the `pool` method
#' is used to create a pool of connections.
#'
#' ### R Option Name
#'
#' The `r_option_name` argument is used to set the connection object as an R
#' option. This provides a smoother developer experience as it allows the
#' developer to re-use the \code{conn} connection throughout various
#' functions, namespaces, or environments.
#'
#' This is useful if you want to access the connection object later
#' without having to pass it around as an argument or between functions, shiny
#' modules, or plumber endpoints by simply accessing `getOption("db.conn")`.
#'
#' @param db_config A list of database connection details. If not provided,
#'   the function will look for a `config.yml` file in the root of your project.
#' @param method The method to use to connect to the database. Either `DBI` or
#'   `pool`.
#' @param schema The schema to connect to. If not provided, the default schema
#'   will be used.
#' @param retries The number of times to retry connecting to the database.
#'   Default is 5.
#' @param rstudio_connection Whether to open the connection in RStudio. Default
#'   is `FALSE`. This only works with the `DBI` method.
#' @param r_option_name The name of the R option to set the connection object
#'   for. Default is `db.conn`. If `NULL`, the connection object will not be
#'   set as an R option. See *details* section for more information.
#' @inheritParams DBI::dbConnect
#'
#' @return A database connection object
#'
#' @export
#'
#' @seealso
#'   - https://db.rstudio.com/dbi/
#'   - [DBI::dbConnect()]
#'   - [pool::dbPool()]
#'   - [RPostgres::Postgres()]
#'   - [config::get()]
#'
#' @keywords internal
#'
#' @importFrom DBI dbConnect
#' @importFrom pool dbPool
#' @importFrom RPostgres Postgres
#' @importFrom rlang abort inform
#' @importFrom usethis ui_done
#' @importFrom config get
#' @importFrom glue glue
#' @importFrom usethis ui_info ui_field ui_done ui_path
#'
#' @examples
#' if (FALSE) {
#'   conn <- db_connect(method = "DBI")
#'   pool <- db_connect(method = "pool")
#' }
#'
db_connect <- function(
  db_config = config::get("db"),
  method = c("DBI", "pool"),
  schema = NULL,
  retries = 5,
  rstudio_connection = FALSE,
  r_option_name = "db.conn",
  ...
) {

  method <- match.arg(method, several.ok = FALSE)

  if (!is.null(db)) {
    db_config$dbname <- db
  }

  if (is.null(db_config)) {
    rlang::abort("No database configuration found.")
  } else {
    stopifnot(
      "host" %in% names(db_config),
      "port" %in% names(db_config),
      "dbname" %in% names(db_config),
      "user" %in% names(db_config),
      "password" %in% names(db_config)
    )
  }

  n <- 1

  repeat {
    conn <- try({
      if (method == "DBI") {
        db_connect.DBI(
          db_config = db_config,
          schema = schema,
          r_option_name = r_option_name,
          ...
        )
      } else {
        db_connect.pool(
          db_config = db_config,
          schema = schema,
          r_option_name = r_option_name,
          ...
        )
      }
    })

    if (inherits(conn, "PqConnection") || inherits(conn, c("Pool", "R6"))) {
      break
    } else {
      if (n > retries) {
        stop("Database connection failed.")
      }
      n <- n + 1
      rlang::inform("Trying to connect: try #{n}")
    }
  }

  usethis::ui_done(
    "Database connection successful."
  )

  if (rstudio_connection && method != "pool") {
    .db_connection_opened(conn)
  }

  return(conn)

}

#' Connect to a Database using DBI
#'
#' @description
#' Connect to a database using the `DBI` package.
#'
#' @rdname db_connect
#'
#' @inheritParams db_connect
#'
#' @return A database connection object return via [DBI::dbConnect()]
#' @export
#'
#' @importFrom DBI dbConnect
#' @importFrom RPostgres Postgres
#' @importFrom rlang abort
#' @importFrom config get
db_connect.DBI <- function(
    db_config = NULL,
    schema = NULL,
    r_option_name = "db.conn",
    ...
) {

  if (is.null(db_config)) db_config <- config::get("db")
  opts <- schema
  if (!is.null(opts)) opts <- paste0("-c search_path=", schema)

  conn <- DBI::dbConnect(
    RPostgres::Postgres(),
    dbname = db_config$dbname,
    host = db_config$host,
    port = db_config$port,
    user = db_config$user,
    password = db_config$password,
    options = opts,
    ...
  )

  if (!DBI::dbIsValid(conn)) {
    rlang::abort("Connection is not valid, please try again.")
  }

  if (!is.null(r_option_name)) {
    options(
      r_option_name = conn
    )
  }

  conn

}

#' Connect to a Database using pool
#'
#' @description
#' Connect to a database using the `pool` package.
#'
#' @rdname db_connect
#'
#' @inheritParams db_connect
#'
#' @return A database connection object return via [pool::dbPool()]
#' @export
#'
#' @importFrom pool dbPool
#' @importFrom RPostgres Postgres
#' @importFrom rlang abort
#' @importFrom config get
db_connect.pool <- function(
    db_config = NULL,
    schema = NULL,
    r_option_name = "db.conn",
    ...
) {

  if (is.null(db_config)) db_config <- config::get("db")
  opts <- schema
  if (!is.null(opts)) opts <- paste0("-c search_path=", schema)

  conn <- pool::dbPool(
    drv = RPostgres::Postgres(),
    dbname = db_config$dbname,
    host = db_config$host,
    port = db_config$port,
    user = db_config$user,
    password = db_config$password,
    options = opts,
    ...
  )

  if (!pool::dbIsValid(conn)) {
    rlang::abort("Connection is not valid, please try again.")
  }

  if (!is.null(r_option_name)) {
    options(
      r_option_name = conn
    )
  }

  conn

}

#' Database Connector
#'
#' @description
#' Creates a new `DBIConnector` object with the [RPostgres::Postgres()]
#' driver and connection parameters.
#'
#' @return `DBIConnector`
#' @export
#'
#' @importFrom RPostgres Postgres
#' @importFrom config get
db_connector <- function() {

  req_configs <- c(
    "host",
    "port",
    "dbname",
    "user",
    "password"
  )

  db_config <- config::get("db")
  db_config_params <- setdiff(
    names(db_config),
    req_configs
  )

  new(
    "DBIConnector",
    .drv = RPostgres::Postgres(),
    .conn_args = db_config_params
  )
}

#' @keywords internal
#' @importFrom DBI dbGetInfo
.db_display_name <- function(connection) {
  db_info <- DBI::dbGetInfo(connection)
  return(sprintf("%s - %s@%s", db_info[["dbname"]], db_info[["username"]], db_info[["host"]]))
}

#' @keywords internal
#' @importFrom DBI dbGetInfo
.db_host_name <- function(connection) {
  db_info <- DBI::dbGetInfo(connection)
  return(sprintf("%s_%s_%s", db_info[["dbname"]], db_info[["username"]], db_info[["host"]]))
}

#' @keywords internal
#' @importFrom readr read_file
.db_connection_code_string <- function(db = "postgres", local = FALSE) {

  if (local) {
    file <- system.file("rstudio/connections/local.R", package = "powwaterapi")
  } else {
    file <- system.file(paste0("rstudio/connections/", db, ".R"), package = "powwaterapi")
  }
  if (!file.exists(file)) stop("No file exists for specified db.")
  readr::read_file(file)

}

#' @keywords internal
#' @importFrom DBI dbDisconnect
pow_pg_close_connection <- function(connection) {
  observer <- getOption("connectionObserver")
  if (!is.null(observer)) {
    observer$connectionClosed(type = "PostgreSQL",
                              host = .pow_pg_host_name(connection))
  }
  DBI::dbDisconnect(connection)
}

#' @keywords internal
.pow_pg_list_object_types <- function(connection) {
  list(
    schema = list(
      contains = list(
        table = list(contains = "data"),
        matview = list(contains = "data"),
        view = list(contains = "data")
      )
    )
  )
}

#' @keywords internal
#' @importFrom DBI dbReadTable
#' @importFrom dplyr filter select mutate bind_rows
pow_pg_catalog <- function(connection) {

  matviews <- DBI::dbReadTable(connection, "pg_matviews") %>%
    dplyr::filter(schemaname != "pg_catalog", schemaname != "information_schema") %>%
    dplyr::select(schemas = schemaname, name = matviewname) %>%
    dplyr::mutate(type = "matview")

  views <- DBI::dbReadTable(connection, "pg_views") %>%
    dplyr::filter(schemaname != "pg_catalog", schemaname != "information_schema") %>%
    dplyr::select(schemas = schemaname, name = viewname) %>%
    dplyr::mutate(type = "view")

  tables <- DBI::dbReadTable(connection, "pg_tables") %>%
    dplyr::filter(schemaname != "pg_catalog", schemaname != "information_schema") %>%
    dplyr::select(schemas = schemaname, name = tablename) %>%
    dplyr::mutate(type = "table")

  out <- dplyr::bind_rows(matviews, views, tables) %>%
    as.data.frame(stringsAsFactors = FALSE)

  out
}

#' @keywords internal
#' @importFrom dplyr select mutate
.pow_pg_list_objects <- function(connection, catalog = NULL, schema = NULL,
                                 name = NULL, type = NULL, ...) {

  database_structure <- pow_pg_catalog(connection)

  save(catalog, schema, name, type, file = "~/list_objects.Rdata")

  if (is.null(schema)) {
    schemas <- database_structure %>%
      dplyr::select(name = schemas) %>%
      unique() %>%
      dplyr::mutate(type = "schema")

    save(schemas, file = "~/schemas.Rdata")

    return(as.data.frame(schemas, stringsAsFactors = FALSE))

  }

  return(subset(database_structure, select = name:type, subset = schemas == schema))

}

#' @keywords internal
#' @importFrom DBI dbSendQuery dbColumnInfo dbClearResult
#' @importFrom dplyr select
.pow_pg_list_columns <- function(connection, table = NULL, view = NULL,
                                 matview = NULL, catalog = NULL, schema = NULL,
                                 ...) {

  if (!is.null(table)) {
    item <- table
  } else if (!is.null(view)) {
    item <- view
  } else if (!is.null(matview)) {
    item <- matview
  } else {
    stop("at least one data item - table, view or matview - must be specified")
  }

  item <- ifelse(is.null(schema), item, sprintf("%s.%s", schema, item))

  rs <- DBI::dbSendQuery(connection,
                         sprintf("SELECT * FROM %s LIMIT 1", item))

  columns <- DBI::dbColumnInfo(rs) %>%
    dplyr::select(.data$name, .data$type) %>% as.data.frame()

  DBI::dbClearResult(rs)

  return(columns)
}

#' @keywords internal
#' @importFrom DBI dbGetQuery
.pow_pg_preview_object <- function(connection, rowLimit, table = NULL,
                                   view = NULL, matview = NULL, schema = NULL,
                                   catalog = NULL, ...) {

  if (!is.null(table)) {
    item <- table
  } else if (!is.null(view)) {
    item <- view
  } else if (!is.null(matview)) {
    item <- matview
  } else {
    stop("at least one data item - table, view or matview - must be specified")
  }

  item <- ifelse(is.null(schema), item, sprintf("%s.%s", schema, item))

  DBI::dbGetQuery(connection, sprintf("SELECT * FROM %s", item), n = min(100, rowLimit))

}

#' @keywords internal
#' @importFrom utils browseURL
.pow_pg_actions_list <- function() {
  actions <- list(
    Help = list(
      icon = system.file("images/help.png", package = "powwaterapi"),
      callback = function() {
        utils::browseURL("https://powapidocs.powwater.org/articles/database.html")
      }
    )
  )
}

#' @keywords internal
#' @importFrom DBI dbGetInfo
.pow_pg_connection_opened <- function(connection) {

  observer <- getOption("connectionObserver")

  if (is.null(observer)) {
    return(invisible(NULL))
  }

  db_info <- DBI::dbGetInfo(connection)
  dbname <- db_info$dbname
  is_local <- db_info$host == "localhost"

  observer$connectionOpened(
    type = "PostgreSQL",
    displayName = .pow_pg_display_name(connection),
    host = .pow_pg_host_name(connection),
    icon = system.file("images/postgresql.png", package = "powwaterapi"),
    connectCode = .pow_pg_connection_code_string(db = dbname, local = is_local),
    disconnect = function() {
      pow_pg_close_connection(connection)
    },
    listObjectTypes = function() {
      .pow_pg_list_object_types()
    },
    listObjects = function(...) {
      .pow_pg_list_objects(connection, ...)
    },
    listColumns = function(...) {
      .pow_pg_list_columns(connection, ...)
    },
    previewObject = function(rowLimit, ...) {
      .pow_pg_preview_object(connection, rowLimit, ...)
    },
    actions = .pow_pg_actions_list(),
    connectionObject = connection
  )

}
