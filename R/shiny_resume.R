
#' @importFrom htmltools htmlDependency
shiny_resume_deps <- function() {
  htmltools::htmlDependency(
    "shiny_resume",
    "5.0.6",
    src = system.file(
      "shiny/startbootstrap-resume-gh-pages/",
      package = "noclocksR"
    ),
    stylesheet = list.files(
      system.file(
        "shiny/startbootstrap-resume-gh-pages/",
        package = "noclocksR"
      ),
      pattern = "\\.css$",
      recursive = TRUE
    ),
    script = list.files(
      system.file(
        "shiny/startbootstrap-resume-gh-pages/",
        package = "noclocksR"
      ),
      pattern = "\\.js$",
      recursive = TRUE
    )
  )
}

#' @importFrom htmltools HTML
shiny_resume_head <- function(
    title = "Shiny Resume"
) {

  htmltools::HTML(
    sprintf(
      '
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="">
  <meta name="author" content="">

  <title>%s</title>

  <!-- Bootstrap core CSS -->
  <link href="resume-5.0.6/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">

  <!-- Custom fonts for this template -->
  <link href="https://fonts.googleapis.com/css?family=Saira+Extra+Condensed:500,700" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css?family=Muli:400,400i,800,800i" rel="stylesheet">
  <link href="resume-5.0.6/vendor/fontawesome-free/css/all.min.css" rel="stylesheet">

  <!-- Custom styles for this template -->
  <link href="resume-5.0.6/css/resume.min.css" rel="stylesheet">

</head>',
      title
    )
  )
}

#' @importFrom htmltools HTML
shiny_resume_scripts <- function() {
  htmltools::HTML(
    '  <!-- Bootstrap core JavaScript -->
  <script src="resume-5.0.6/vendor/jquery/jquery.min.js"></script>
  <script src="resume-5.0.6/vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

  <!-- Plugin JavaScript -->
  <script src="resume-5.0.6/vendor/jquery-easing/jquery.easing.min.js"></script>

  <!-- Custom scripts for this template -->
  <script src="resume-5.0.6/js/resume.min.js"></script>'
  )
}

#' Shiny Resume Body
#'
#' @description
#' Produce the body of the shiny resume page.
#'
#' @param ... A series of [shiny_resume_section()] elements
#'
#' @return HTML via [htmltools::tagList()]
#' @export
#'
#' @importFrom htmltools tagList tags
shiny_resume_body <- function(...) {
  htmltools::tagList(
    htmltools::tags$div(
      class = "container-fluid p-0",
      ...,
      shiny_resume_scripts()
    )
  )
}

shiny_resume_section <- function(id, ...){
  htmltools::tagList(
    htmltools::tags$section(
      class = "resume-section p-3 p-lg-5 d-flex align-items-center",
      id = id,
      htmltools::tags$div(
        class = "w-100",
        ...
      )
    )
  )
}


#' @importFrom htmltools tags
make_navbar <- function(nav) {
  if (is.null(names(nav))) {
    names(nav) <- nav
  }

  mapply(
    function(x, y) {
      htmltools::tags$li(
        class = "nav-item",
        htmltools::tags$a(
          class = "nav-link js-scroll-trigger",
          href = sprintf("#%s", x),
          y
        )
      )
    },
    names(nav),
    nav,
    SIMPLIFY = FALSE
  )
}


#' Shiny Resume Navigation Bar
#'
#' @description
#' Produce a navigation bar for a shiny resume
#'
#' @param refs Named list with names being IDs and elements being text displayed.
#' @param image Image to place in navbar
#' @param color Color of the sidebar
#'
#' @return HTML via [htmltools::tagList()]
#' @export
#'
#' @importFrom htmltools tags tagList
shiny_resume_navbar <- function(
    refs = c("a" = "A"),
    image = "img/profile.jpg",
    color = "#bd5d38"
) {
  htmltools::tagList(
    htmltools::tags$style(
      sprintf(".navbar { background-color: %s!important;}", color)
    ),
    htmltools::tags$nav(
      class = "navbar navbar-expand-lg navbar-dark bg-primary fixed-top",
      id = "sideNav",
      htmltools::tags$a(
        class = "navbar-brand js-scroll-trigger",
        href = "#page-top",
        htmltools::tags$span(
          class = "d-block d-lg-none", "nav_title"
        ),
        htmltools::tags$span(
          class = "d-none d-lg-block",
          tags$img(
            class = "img-fluid img-profile rounded-circle mx-auto mb-2",
            src = image,
            alt = NA
          )
        )
      ),
      htmltools::tags$button(
        class = "navbar-toggler",
        type = "button",
        "data-toggle" = "collapse",
        "data-target" = "#navbarSupportedContent",
        "aria-controls" = "navbarSupportedContent",
        "aria-expanded" = "false",
        "aria-label" = "Toggle navigation",
        htmltools::tags$span(class = "navbar-toggler-icon")
      ),
      htmltools::tags$div(
        class = "collapse navbar-collapse",
        id = "navbarSupportedContent",
        htmltools::tags$ul(
          class = "navbar-nav",
          make_navbar(refs)
        )
      )
    )
  )
}


#' Shiny Resume Page
#'
#' @description
#' Shiny App with Bootstrap Resume Template
#'
#' @param app_title Title to use for the app
#' @param nav Navbar, constructed with [shiny_resume_navbar()]
#' @param body Body, constructed with [shiny_resume_body()] & [shiny_resume_section()]
#'
#' @return HTML via [htmltools::tagList()]
#' @export
#'
#' @importFrom htmltools tagList tags
shiny_resume_page <- function(
  app_title,
  nav,
  body
) {

  htmltools::tagList(
    htmltools::tags$html(
      shiny_resume_deps(),
      shiny_resume_head(title = app_title),
      htmltools::tags$body(
        id = "page-top",
        nav,
        body
      )
    )
  )
}

