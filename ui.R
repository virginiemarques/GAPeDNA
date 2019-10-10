# Library 
if (!require("pacman")) install.packages("pacman") ; library(pacman)
pacman::p_load(shiny, leaflet, htmlwidgets, htmltools, sf, tidyverse, viridis, shinythemes, DT, shinydashboard, shinycssloaders)

# Load data
load("data/data_for_shiny.Rdata")

# UI
dashboardPage(
  dashboardHeader(title = "Global gaps for fishes eDNA metabarcoding", 
                  titleWidth=410),
  dashboardSidebar(
    
    fluidRow(
      
      column(width = 12,align="center",
             tags$footer(tags$p("Click on a polygon to display the list of species \n \n")),
             
             column(width=12, selectInput("taxon_chosen", 
                                          label = "Choose a taxon",
                                          choices = c("Marine fish", "Freshwater fish")),
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
             tags$a("Code in GitHub", href="https://github.com/virginiemarques/Gaps_shiny_quicktest", target="_blank"),
             tags$footer(tags$p("This application is developped by V. Marques and supports the following paper: (Paper name & hyperlink)")),
             tags$a("Paper link", href="https://github.com/virginiemarques/Gaps_shiny_quicktest", target="_blank"),
             hr(), 
             tags$footer(tags$p("Last updated in July 2019", class = "credit"))
             
      ))
    
  ), #end of sidebar,
  dashboardBody(
    
    fluidRow(
      #verbatimTextOutput("datasettt"),
      column(width = 12, withSpinner(leafletOutput("map"), type=6),# Try to put a waiting sign
             
             hr()),
      
      column(width = 12, DT::dataTableOutput("tableau"))
      
    ) # End of fluidRow
  ) # End of body
) # End of all

