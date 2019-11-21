# Library 
if (!require("pacman")) install.packages("pacman") ; library(pacman)
pacman::p_load(shiny, leaflet, htmlwidgets, htmltools, sf, tidyverse, viridis, shinythemes, DT, shinydashboard, shinycssloaders)

# Load data
load("data/all_data_shiny.Rdata")

# Add a file to guide decision within the app
organisation <- data.frame(taxa = c("Marine fish","Marine fish","Freshwater fish", "Freshwater_test"), 
                           resolution = c("Provinces", "Ecoregions", "Basins", "Test"),
                           data_chosen = c("marine_meow", "marine_ecoreg", "p3", "p3_small"), 
                           geometry = c("marine_meow_geom", "marine_ecoreg_geom", "p3_geom", "p3_geom"),
                           stringsAsFactors = F)

# UI
dashboardPage(
  dashboardHeader(title = "GAPeDNA"),
  dashboardSidebar(
    
    fluidRow(
      
      column(width = 12,align="center",
             column(width=12, selectInput("taxon_chosen", 
                                          label = "Choose a taxon",
                                          choices = unique(organisation$taxa)),
                    selected = "Marine fish"),
             
             column(width=12, align="center", uiOutput("control_resolution")),
             
             hr(), 
             column(width=12, selectInput("marker_position", 
                                          label = "Choose a mitochondrial position",
                                          choices = unique(primers_type$marker_position),
                                          selected = "12S"))), 
      
      column(width=12, align="center", uiOutput("control_marker")),
      hr(),
      column(width = 12, align="center",
             
             # CSS tags
             tags$head(tags$style(".butt{color: black !important;} .credit{font-style: italic;}")),
             
             hr(),
             downloadButton(offset=12,'download',"Download table", class = "butt"),
             
             hr(),
             tags$a("Source code in GitHub", href="https://github.com/virginiemarques/Gaps_shiny_quicktest", target="_blank"),
             tags$footer(tags$p("This shiny-app is developped by V. Marques and supports the following paper: ")),
             tags$a("Paper link", href="https://github.com/virginiemarques/Gaps_shiny_quicktest", target="_blank"),
             hr(), 
             tags$footer(tags$p("Last updated in November 2019", class = "credit"))
             
      ))
    
  ), #end of sidebar,
  dashboardBody(
    
    fluidRow(
      #verbatimTextOutput("datasettt"),
      column(width = 12, withSpinner(leafletOutput("map"), type=6)),# Try to put a waiting sign,
      
      column(width = 12,  textOutput("selected_txt")),
      
      column(width = 12, hr(),
             DT::dataTableOutput("tableau"))
      
    ) # End of fluidRow
  ) # End of body
) # End of all

