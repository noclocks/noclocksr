library(sass)
library(bslib)
library(fresh)
library(shinythemes)
library(shiny)

source("R/brandfetch.R")

api_key <- config::get("brandfetch_api_key")
Sys.setenv("BRANDFETCH_API_KEY" = api_key)

brand <- fetch_brand("r-project.org")

