# Library 
# if (!require("pacman")) install.packages("pacman") ; library(pacman)
# pacman::p_load(shiny, leaflet, htmlwidgets, htmltools, sf, tidyverse, shinythemes, DT, shinydashboard, shinycssloaders)

library(shiny)
library(leaflet)
library(htmltools)
library(htmlwidgets)
library(sf)
library(tidyverse)
library(shinythemes)
library(DT)
library(shinydashboard)
library(shinycssloaders)

# Add a file to guide decision within the app
organisation <- data.frame(taxa = c("Marine fish","Marine fish","Freshwater fish"), 
                           resolution = c("Provinces", "Ecoregions", "Basins"),
                           data_chosen = c("marine_meow", "marine_ecoreg", "p3"), 
                           geometry = c("marine_meow_geom", "marine_ecoreg_geom", "p3_geom"),
                           stringsAsFactors = F)

# Markers 
choices_marker <- c("12S",  "16S",  "COI",  "CYTB", "18S")

# UI
dashboardPage(
  dashboardHeader(title = "GAPeDNA v1.0"),
  dashboardSidebar(
    fluidRow(
      column(width = 12,align="center",
             # Select taxa
             selectInput("taxon_chosen",label = "Choose a taxon",
                                        choices = unique(organisation$taxa),
                                        selected = "Marine fish"),
             # Select geographic resolution
             uiOutput("control_resolution"),
             # Select marker position
             selectInput("marker_position", 
                                          label = "Choose a mitochondrial position",
                                          choices = choices_marker,
                                          selected = "12S"), 
            # Select primer
            uiOutput("control_marker"),
            # CSS tags for color
            tags$head(tags$style(".butt{color: black !important;} .credit{font-style: italic;}")),
            hr(),
            # Download button
            downloadButton(offset=12,'download',"Download table", class = "butt"),
            hr(),
            # Link for source code
            tags$a("Source code in GitHub", href="https://github.com/virginiemarques/GAPeDNA", target="_blank"),
            # Explanation
            tags$footer(tags$p("This shiny-app is developped by V. Marques and supports the following paper: ")),
            # Link for paper
            tags$a("Link to the paper", href="https://github.com/virginiemarques/GAPeDNA", target="_blank"),
            hr(), 
            # Update info
            tags$footer(tags$p("Last updated in November 2019", class = "credit"))
      ) # end of column
      ) # end of fluidrow
    
  ), # end of sidebar,
  dashboardBody(
    fluidRow(
      # Leaflet map with waiting wheel
      column(width = 12, withSpinner(leafletOutput("map"), type=6)),# Try to put a waiting sign,
      # Explanation text
      column(width = 12,  textOutput("selected_txt")),
      # The table
      column(width = 12, hr(),
             DT::dataTableOutput("tableau"))
    ) # End of fluidRow
  ) # End of body
) # End of all

