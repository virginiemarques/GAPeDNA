# Library 
if (!require("pacman")) install.packages("pacman") ; library(pacman)
pacman::p_load(shiny, leaflet, htmlwidgets, htmltools, sf, tidyverse, viridis, shinythemes, DT, shinydashboard)

# Load data
load("data/data_for_shiny.Rdata")

# UI
dashboardPage(
  dashboardHeader(title = "Global gaps for fishes eDNA metabarcoding", 
                  titleWidth=400),
  dashboardSidebar(
    
    fluidRow(
      
      column(width = 12,align="center",
             tags$footer(tags$p("Click on a polygon to display the list of species \n \n")),
             
             column(width=12, selectInput("dataset", 
                                          label = "Choose a region type",
                                          choices = c("Marine realms", "Marine provinces", "Marine ecoregions", "Freshwater")),
                    selected = "Marine provinces"),
             hr(), 
             column(width=12, selectInput("marker_position", 
                                          label = "Choose a mitochondrial position",
                                          choices = unique(primers_type$marker_position),
                                          selected = "12S"))), 
      column(width=12, align="center", uiOutput("control_marker")),
      hr(),
      column(width = 12, align="center",
             
             hr(),
             downloadButton(offset=12,'download',"Download table"),
             tags$style(".skin-blue .sidebar a { color: #444; }"),
             hr(),
             tags$footer(tags$p("This application is developped by V. Marques, available in github (link)")),
             tags$footer(tags$p("Support the following paper (Paper name & hyperlink)")),
             hr(), 
             tags$footer(tags$p("Last updated in June 2019"))
             
      ))
    
  ), #end of sidebar,
  dashboardBody(
    
    fluidRow(
      #verbatimTextOutput("datasettt"),
      column(width = 12, leafletOutput("map"), 
             
             hr()),
      
      column(width = 12, DT::dataTableOutput("tableau"))
      
    ) # End of fluidRow
  ) # End of body
) # End of all
