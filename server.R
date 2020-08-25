# Library 
# update.packages(c("shiny", "leaflet", "htmlwidgets", "htmltools", "sf", "tidyverse", "viridis", "shinythemes", "DT", "shinydashboard"), ask=F)
# if (!require("pacman")) install.packages("pacman") ; library(pacman)
# pacman::p_load(shiny, leaflet, htmlwidgets, htmltools, sf, tidyverse, shinythemes, DT, shinydashboard)

library(shiny)
library(leaflet)
library(htmlwidgets)
library(htmltools)
library(sf)
library(tidyverse)
library(shinythemes)
library(DT)
library(shinydashboard)

# Load data
load("data/all_data_shiny.Rdata")

# Add a file to guide decision within the app
organisation <- data.frame(taxa = c("Marine fish","Marine fish","Freshwater fish"), 
                           resolution = c("Provinces", "Ecoregions", "Basins"),
                           data_chosen = c("marine_meow", "marine_ecoreg", "p3"), 
                           geometry = c("marine_meow_geom", "marine_ecoreg_geom", "p3_geom"),
                           stringsAsFactors = F)

# SERVER
function(input, output){
  
  # ------- UI dynamic choices --------- # 
  
  # Geo choice
  output$control_resolution <- renderUI({
    selectInput("resolution_chosen", label = "Choose a geographic resolution", 
                choices = organisation %>% dplyr::filter(taxa == input$taxon_chosen) %>% dplyr::select(resolution) %>% pull())
  })
  
  # Marker choice
  output$control_marker <- renderUI({
    selectInput("the_marker", label = "Choose a primer pair", 
                choices = primers_type %>% dplyr::filter(marker_position == input$marker_position) %>% dplyr::select(marker_single) %>% pull())
  })
  
  # ------- Dataset --------- # 
  
  # Select the chosen dataset & put it in reactive mode 
  datasetInput1 <- reactive({
    # Verify the input or not null before selection
    req(input$taxon_chosen)
    req(input$resolution_chosen)
    # Get the dataset
    organisation %>%
      dplyr::filter(taxa == input$taxon_chosen) %>% 
      dplyr::filter(resolution == input$resolution_chosen) %>% 
      dplyr::select(data_chosen) %>%
      pull(data_chosen) %>%
      get()
  })
  
  # Store the geometry corresponding to the chosen dataset
  dataset_geometry <- reactive({
    # Verify the input or not null before selection
    req(input$taxon_chosen)
    req(input$resolution_chosen)
    # Get the dataset
    organisation %>%
      dplyr::filter(taxa == input$taxon_chosen) %>% 
      dplyr::filter(resolution == input$resolution_chosen) %>% 
      dplyr::select(geometry) %>%
      pull(geometry) %>%
      get()
  })
  
  # Filter by the chosen primer and transform as spatial object
  datasetInput <- reactive({ 
    # Verification 
    req(input$the_marker)
    # Get dataset
    datasetInput1() %>%
      dplyr::filter(Marker == input$the_marker) %>%
      left_join(., dataset_geometry()) %>%
      st_as_sf()
  })
  
  # -------- Map Leaflet ------ # 
  
  # The leaflet map
  output$map <- renderLeaflet({
    # Verif
    req(datasetInput1())
    req(datasetInput())
    # Labels in %
    labels <- sprintf(
      "<strong>%s</strong><br/>%g %% sequenced <br/> %g / %g sequenced species",
      datasetInput()$BasinName,  datasetInput()$pourcent_seq, datasetInput()$nombre_seq, datasetInput()$nombre_tot) %>% 
      lapply(htmltools::HTML)
    # Color palette
    conpal <- colorNumeric(palette = "YlOrRd", domain = c(0,100))
    # Print map
    map <- leaflet(datasetInput()) %>%
      # Background
      addTiles() %>%
      # Background
      addProviderTiles(providers$Hydda.Base,
                       options = providerTileOptions(minZoom = 1, maxZoom = 500)) %>%
      clearBounds() %>%
      # View
      setView( lat=10, lng=0 , zoom=2) %>%
      # Legend
      addLegend(conpal, 
                c(0,100),
                opacity = 1, 
                title = "Percentage of <br>species sequenced",
                position = "bottomright") %>%
      # Polygons
      addPolygons(layerId=~BasinName, group = "continuous",
                  smoothFactor = 1, fillOpacity = 1,
                  fillColor = ~conpal(datasetInput()$pourcent_seq),
                  weight = 1,
                  opacity = 1,
                  color = "grey",
                  dashArray = "1",
                  highlight = highlightOptions(
                    weight = 5,
                    color = "#666",
                    dashArray = "",
                    fillOpacity = 1,
                    bringToFront = TRUE),
                  label = labels,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto"))
  }) # End of leaflet
  
  
  # ------- The reactive table ------ # 
  
  # Clickable object: create a null reactive value to store the ID of the layer
  SelectedID <- reactiveVal(NULL)
  
  # Observe statement
  observe({
    event <- input$map_shape_click
    req(event)
    SelectedID(event$id)
    #print(event$id) # Verification
  })
  
  # The table
  table_display <- reactive(fresh_and_marine %>%
                              filter(BasinName %in% SelectedID()) %>% # select polygon ID
                              dplyr::select(BasinName, Species_name, IUCN) %>%
                              mutate(Sequenced = ifelse(test = Species_name %in% all_primers[[input$the_marker]], yes="Yes", no="No")) %>%
                              mutate(Primer = input$the_marker) %>%
                              mutate(Sequenced = as.factor(Sequenced)) %>%                              
                              dplyr::select(BasinName, Primer, Species_name, IUCN, Sequenced) %>%
                              arrange(Species_name))
  # Print the DT table
  output$tableau = DT::renderDataTable({
    # Verif
    req(SelectedID())
    
    # Table
    datatable(table_display(), 
              class = 'cell-border stripe', 
              options = list(columnDefs = list(list(className = 'dt-center', targets = "_all"))),
              rownames = FALSE,
              filter='top', 
              caption = htmltools::tags$caption(
                style = 'caption-side: bottom; text-align: center;',
                'UICN categories: ', 
                htmltools::em('DD: Data Deficient, CR: Critically endangered, EN: Engangered, VU: Vulnerable, NT: Near Threatened, LC: Least Concern'))) %>%
      formatStyle('Sequenced',
                  backgroundColor = styleEqual(c("No","Yes"), c('#F7FBFF', '#abf9bc'))) %>% 
      formatStyle('IUCN',
                  backgroundColor = styleEqual(c("CR", "EN", "VU", "NT", "LC","Not evaluated", "DD"), c('#f7c283', '#f7d383', '#f7e183', '#f7ef83', '#abf9bc', '#F7FBFF', '#F7FBFF')))
    
  })
  
  
  # ------ The download button ----- # 
  
  # Download options
  output$download <- downloadHandler(
    filename = function() {
      paste(input$taxon_chosen, "_", input$the_marker, "_", SelectedID(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv( table_display(), file, row.names = FALSE)
    }
  )
}
  
  