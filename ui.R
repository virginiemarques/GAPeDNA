# Library 
# if (!require("pacman")) install.packages("pacman") ; library(pacman)
# pacman::p_load(shiny, leaflet, htmlwidgets, htmltools, sf, tidyverse, shinythemes, DT, shinydashboard, shinycssloaders)

library(shiny)
library(leaflet)
library(htmltools)
library(shinythemes)
library(DT)
library(shinycssloaders)

# Add a file to guide decision within the app
organisation <- data.frame(taxa = c("Marine fish","Marine fish","Freshwater fish"), 
                           resolution = c("Provinces", "Ecoregions", "Basins"),
                           data_chosen = c("marine_meow", "marine_ecoreg", "p3"), 
                           geometry = c("marine_meow_geom", "marine_ecoreg_geom", "p3_geom"),
                           stringsAsFactors = F)

# Markers 
choices_marker <- c("12S",  "16S",  "COI",  "CYTB", "18S")

# Panels

#### PANEL 1 ----
panel1 <- tabPanel(title = "World maps",fluid = TRUE, icon = icon("globe-africa"),
                   
                   # ----------- Sidebar ------------- # 
                   sidebarLayout(
                     sidebarPanel(
                       
                       # Fix width
                       width=2,
                       
                       # Inputs 
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
                       
                       # Download button
                       downloadButton('download',"Download table", class = "butt"),
                       
                       hr(), 
                       
                       tags$footer(tags$p("Reference database version: ENA release 138 (January 2019)"))

                     ), # End sidebarpanel
                     
                     # ----------- Main  ------------- # 
                     mainPanel(
                       
                       h5("Click on a polygon to display the list of corresponding species"),
                       
                       # Leaflet map with waiting wheel
                       column(width = 12, withSpinner(leafletOutput("map"), type=6)),# Try to put a waiting sign,
                       # Explanation text
                       column(width = 12,  textOutput("selected_txt")),
                       # The table
                       column(width = 12, hr(),
                              DT::dataTableOutput("tableau"))
                       
                     )
                   )
)

#### PANEL 2 ----
panel2 <- tabPanel("Extract sequences",fluid = TRUE, icon = icon("dna"),
                   
                   br(),
                   # Presentation
                   h2("Coming soon")

) # End panel2

#### PANEL 3 ----
panel3 <- tabPanel("Infos",fluid = TRUE, icon = icon("info-circle"),
                   
                   br(),
                   
                   # Presentation
                   h2("Welcome to GAPeDNA !"),
                   
                   # Explanations
                   h4("The app is designed to browse taxonomic coverage of online genetic database for designated metabarcoding primers."),
                   h4("At the moment, only freshwater and marine fish primers are available within the app"),
                   
                   # Data generation
                   h4("Here is how the data is generated:"),
                   img(src="schema_method2.png", height="30%", width="50%"),
                   h4("In order to be correctly amplified by the in-silico PCR, sequences present in genetic databases must have the primer sequences and not less than 3 mismatches within them. Sequences uploaded without their primers sequences will fail to be amplified and might result in an under-estimation of taxonomic coverage."),
                   
                   # Addition of taxa 
                   hr(), 
                   h4("If you wish to contribute to GAPeDNA:"),
                   h4("You can provide primer pairs sequences and spatialized checklists for another taxonomic group, and I will update the app to include them."),
                   tags$a("Contact link", href="https://github.com/virginiemarques/GAPeDNA", target="_blank"),
                   h4("Or via e-mail: virginie[.]marques[at]umontpellier.fr"),
                   
                   # Data sources 
                   br(),
                   hr(),
                   h4("The source data for the checklists are freely available"),
                   h4("- For marine fish, with a 100*100 km2 resolution:"),
                   tags$a("The marine fish foodweb is globally connected", href="https://www.nature.com/articles/s41559-019-0950-y", target="_blank"),
                   br(),
                   h4("- For freshwater fish, with a basin resolution:"),
                   tags$a("A global database on freshwater fish species occurrence in drainage basins", href="https://www.nature.com/articles/sdata2017141", target="_blank"),
                   br(),
                   h4("Fish name were verified using the fishbase taxonomy"),
                   
                   # Info on dev. team
                   br(),
                   hr(),
                   h4("GAPeDNA was developped by Virginie Marques and supports the following paper:"),
                   # Link for paper
                   tags$a("GAPeDNA: Assessing and mapping global species gaps in genetic databases for eDNA metabarcoding", href="https://github.com/virginiemarques/GAPeDNA", target="_blank"),
                   br(), 
                   tags$a("The source code for the app in available in GitHub", href="https://github.com/virginiemarques/GAPeDNA", target="_blank"),
                   
                   # Update info
                   br(),
                   tags$footer(tags$p("Last updated in August 2020", class = "credit")),
                   br(),br(),br(),br()
                   
) # End panel3

#### UI ----
navbarPage(title = "GAPeDNA v1.0.1",
                 theme = shinytheme("flatly"),
                 
                 ## ------ PANEL 1 ----- ## 
                 panel1,
                 ## ------ PANEL 2 ----- ## 
                 panel2,
                 ## ------ PANEL 3 ----- ## 
                 panel3
                 
) # End navbarPage
