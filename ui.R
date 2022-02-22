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
organisation <- data.frame(taxa = c("Marine fish","Marine fish", "Marine fish", "Freshwater fish", "Freshwater fish"), 
                           resolution = c("Provinces", "Ecoregions", "World", "Basins", "World"),
                           data_chosen = c("occurence_marine_province", "occurence_marine_ecoregion", "occurence_marine_world", "occurence_freshwater_basin", "occurence_freshwater_world"), # name of file with information
                           geometry = c("marine_province", "marine_ecoregion", "marine_world", "freshwater_basin", "freshwater_world"), # names of geometry file 
                           stringsAsFactors = F)

# Markers 
choices_marker <- c("12S",  "16S",  "COI",  "CytB", "18S")

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
                       
                       tags$footer(tags$p("Reference database version: ENA December 2021"))

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
                   
                   sidebarLayout(
                     sidebarPanel(
                       
                       # ------------------------------ # 
                       # Sidebar 1
                       
                       # Fix width
                       width=4,
                       
                       # Specify somewhere: sep = "," and the name of species_ column
                       fileInput('datafile_forseq', 'Choose a CSV file (generated from the World maps pane)',
                                 accept=c('csv', 'comma-separated-values','.csv')), 
                       
                       br(),
                       
                       downloadButton(outputId = 'download_sequences',"Download table with sequences", class = "butt")
                       
                     ), # end sidebar
                     
                       # ------------------------------ # 
                       # Main 
                     
                       mainPanel(
                         h5("Open a .csv file for the World maps panel to display a table with their sequences and number of mismatches on each primer"),
                         h5("You can search species name as well as sequences on the search box, and download the full table"),
                         h5("A high number of mismatches can lead to decrease chances of amplification"),
                         br(),br(),
                         column(width = 10, DT::dataTableOutput("table_output_sequences"))
                       ))
                       
) # End panel2

#### PANEL 3 ----
panel3 <- tabPanel("Infos",fluid = TRUE, icon = icon("info-circle"),
                   
                   includeCSS("www/mode.css"),
                   br(),
                   
                   # Presentation
                   h2("Welcome to GAPeDNA !"),
                   br(),
                   
                   # Explanations
                   h4("The app is designed to browse taxonomic coverage of online genetic database for designated metabarcoding primers, and download the sequences."),
                   h4("Taxa covered include freshwater and marine fish at the moment."),
                   
                   # Data generation
                   h4("Here is how the data is generated:"),
                   img(src="schema_method2.png", height="20%", width="40%"),
                   # img(src="schema_method2.png", height="30%", width="50%"),
                   h5( span("Important:", style = "font-weight: bold"), "Sequences in online databases must have the primer sequences, otherwise they will fail to be in-silico PCR amplified.", style="text-align: center"),
                   h5(style="text-align: center", "This might lead to under-estimated taxonomic coverage if many sequences are present but lack primers. Sequences are amplified if primer sequences have less than 3 mismatches on each primer."),
                   
                   # Addition of taxa 
                   hr(), 
                   h4("Contributions to GAPeDNA:", style = "font-weight: bold"),
                   h5("We can expand the taxonomic breath covered by GAPeDNA with your help."),
                   h5("If you have spatialized checklists and/or a list of metabarcoding primer pairs for additional taxonomic groups freely available, please contact me, I can update the app and include it."),
                   h5("E-mail: virginie[.]marques[at]cefe.cnrs.fr"),
                   
                   # Data sources 
                   br(),
                   hr(),
                   h4("Checklist source data:", style="font-weight: bold"),
                   h5("- Marine fish:"),
                   tags$a("The marine fish foodweb is globally connected", href="https://www.nature.com/articles/s41559-019-0950-y", target="_blank"),
                   br(),
                   h5("- Freshwater fish:"),
                   tags$a("A global database on freshwater fish species occurrence in drainage basins", href="https://www.nature.com/articles/sdata2017141", target="_blank"),
                   br(),
                   h5("Fish name were verified using the fishbase taxonomy"),
                   
                   # Info on dev. team
                   br(),
                   hr(),
                   h4("References", style="font-weight: bold"),
                   h5("Developer and maintainer: Virginie Marques."),
                   br(),
                   h5("GAPeDNA supports the following paper:"),
                   # Link for paper
                   tags$a("GAPeDNA: Assessing and mapping global species gaps in genetic databases for eDNA metabarcoding", 
                          href="https://onlinelibrary.wiley.com/doi/10.1111/ddi.13142?af=R", target="_blank"),
                   br(), 
                   tags$a("Source code", href="https://github.com/virginiemarques/GAPeDNA", target="_blank"),
                   
                   # Update info
                   br(),
                   tags$footer(tags$p("Last updated in February 2022", class = "credit", style="text-align: left; font-style: italic; margin: 1% 5%")),
                   br(),br(),br(),br()
                   
) # End panel3

#### UI ----
navbarPage(title = "GAPeDNA v1.1.1",
                 theme = shinytheme("flatly"),
                 
                 ## ------ PANEL 1 ----- ## 
                 panel1,
                 ## ------ PANEL 2 ----- ## 
                 panel2,
                 ## ------ PANEL 3 ----- ## 
                 panel3
                 
) # End navbarPage
