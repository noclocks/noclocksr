library(shiny)
library(noclocksR)

ui <- function(request) {
  shiny_resume_page(
    app_title = "DEMO",
    nav = shiny_resume_navbar(
      refs = c(
        "about" = "About",
        "experience" = "Experience",
        "education" = "Education",
        "interests" = "Interests",
        "awards" = "Awards"
      ),
      image = "https://github.com/jimbrig/assets/blob/main/images/2020-Headshot-Round%20(Custom).png?raw=true",
      color = "black"
    ),
    body = shiny_resume_body(
      shiny_resume_section(
        id = "about",
        h4("About"),
        p("About me...")
      ),
      shiny_resume_section(
        id = "experience",
        h4("Experience"),
        p("Experience...")
      ),
      shiny_resume_section(
        id = "education",
        h4("Education"),
        p("Education...")
      ),
      shiny_resume_section(
        id = "interests",
        h4("Interests"),
        p("Interests...")
      ),
      shiny_resume_section(
        id = "awards",
        h4("Awards"),
        p("Awards...")
      )
    )
  )
}

server <- function(input, output, session){

}

shinyApp(ui, server)
