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
organisation <- data.frame(
  taxa = c(
    "Marine fish", "Marine fish", "Marine fish",
    "Freshwater fish", "Freshwater fish",
    "Elasmobranches", "Elasmobranches", "Elasmobranches", "Elasmobranches"
  ),
  resolution = c(
    "Provinces", "Ecoregions", "World",
    "Basins", "World",
    "Ecoregions", "Provinces", "Basins", "World"
  ),
  data_chosen = c(
    "occurence_marine_province", "occurence_marine_ecoregion", "occurence_marine_world",
    "occurence_freshwater_basin", "occurence_freshwater_world",
    "occurence_shark_ecoregion", "occurence_shark_province", "occurence_shark_basin", "occurence_shark_world"
  ),
  geometry = c(
    "marine_province", "marine_ecoregion", "marine_world",
    "freshwater_basin", "freshwater_world",
    "marine_ecoregion", "marine_province", "freshwater_basin", "marine_world"
  ),
  stringsAsFactors = FALSE
)

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
                       
                       tags$footer(tags$p("Reference database version: MIDORI2 GB269 2025-12-09"))

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
panel3 <- tabPanel("About", fluid = TRUE, icon = icon("info-circle"),

  includeCSS("www/mode.css"),

  div(class = "info-page",

    # --- Hero ---
    div(style = "text-align: center; padding: 20px 0 10px;",
      h2("Welcome to GAPeDNA"),
      tags$p(class = "hero-subtitle",
        "GAPeDNA lets you explore taxonomic coverage gaps in eDNA metabarcoding
        reference databases. Select a taxon group, spatial resolution, and primer
        pair to visualise the proportion of species represented in the reference
        database — and download species lists with their sequences."
      )
    ),

    hr(),

    # --- How it works ---
    div(class = "info-section",
      h3(class = "section-title", icon("gear"), " How it works"),
      img(src = "schema_method2.png",
          style = "max-width: 520px; width: 65%; margin: 16px auto 20px;"),
      div(class = "note-box",
        tags$b("Important: "),
        "Reference sequences can now be recovered even in the absence of the 
        binding site in silico. A maximum of 3 mismatches per primer is tolerated."
      )
    ),

    hr(),

    # --- Data sources ---
    div(class = "info-section",
      h3(class = "section-title", icon("database"), " Occurrence data sources"),

      div(class = "source-card",
        tags$span(class = "taxa-label", icon("fish"), " Marine fish"),
        tags$p("Species-presence matrix derived from a global marine food web
               dataset, resolved to 1° grid cells."),
        tags$a("Albouy et al. (2019) — The marine fish food web is globally connected",
               href = "https://www.nature.com/articles/s41559-019-0950-y",
               target = "_blank")
      ),

      div(class = "source-card",
        tags$span(class = "taxa-label", icon("water"), " Freshwater fish"),
        tags$p("Species occurrences in global freshwater drainage basins.
               Species names verified against FishBase taxonomy."),
        tags$a("Tedesco et al. (2017) — A global database on freshwater fish
               species occurrence in drainage basins",
               href = "https://www.nature.com/articles/sdata2017141",
               target = "_blank")
      ),

      div(class = "source-card",
        tags$span(class = "taxa-label", icon("circle-dot"), " Elasmobranchs (sharks & rays)"),
        tags$p("Species distribution range polygons from the IUCN Red List.
               Freshwater-tolerant species identified via FishBase ecology data
               (", tags$em("Fresh"), " flag)."),
        tags$a("IUCN Red List — Spatial data download",
               href = "https://www.iucnredlist.org/resources/spatial-data-download",
               target = "_blank")
      )
    ),

    hr(),

    # --- Contribute ---
    div(class = "info-section",
      h3(class = "section-title", icon("handshake"), " Contribute"),
      tags$p(
        "GAPeDNA can be extended to additional taxonomic groups. If you have
        spatialised species checklists and/or metabarcoding primer pairs for a
        group not yet covered, please get in touch — I can integrate it into
        the app."
      ),
      tags$p(icon("envelope"), " ",
        tags$a("virginie[.]marques[at]usys[.]ethz[.]ch",
               href = "mailto:virginie.marques@usys.ethz.ch")
      )
    ),

    hr(),

    # --- Citation & Credits ---
    div(class = "info-section",
      h3(class = "section-title", icon("book-open"), " Citation & Credits"),

      tags$p("If you use GAPeDNA in your work, please cite:"),
      div(class = "citation-box",
        tags$a(
          "Marques et al. (2021) — GAPeDNA: Assessing and mapping global species
          gaps in genetic databases for eDNA metabarcoding",
          href = "https://onlinelibrary.wiley.com/doi/10.1111/ddi.13142?af=R",
          target = "_blank"
        ),
        tags$p(style = "margin: 6px 0 0; font-style: italic; color: #777;
                        font-size: 13px;",
               "Diversity and Distributions, 2021")
      ),

      div(class = "credit-block",
        tags$p(tags$b("Development & maintenance: "), "Virginie Marques"),
        tags$p(tags$b("Illustration: "), "P. Lopez"),
        tags$p(tags$b("Server infrastructure: "), "M. Q. Quidoz (CEFE)"),
        tags$p(
          tags$a(icon("github"), " Source code on GitHub",
                 href = "https://github.com/virginiemarques/GAPeDNA",
                 target = "_blank")
        )
      )
    ),

    tags$p(class = "info-footer", "Last updated March 2026")

  ) # end info-page
) # End panel3

#### UI ----
navbarPage(title = "GAPeDNA v1.2.0",
                 theme = shinytheme("flatly"),
                 header = tags$style(
                   # Match Esri.WorldStreetMap ocean colour so tile edges are invisible
                   ".leaflet-container { background: #aadaff; }"
                 ),

                 ## ------ PANEL 1 ----- ##
                 panel1,
                 ## ------ PANEL 2 ----- ## 
                 panel2,
                 ## ------ PANEL 3 ----- ## 
                 panel3
                 
) # End navbarPage
