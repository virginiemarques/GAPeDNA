# Library 
# update.packages(c("shiny", "leaflet", "htmlwidgets", "htmltools", "sf", "tidyverse", "viridis", "shinythemes", "DT", "shinydashboard"), ask=F)
# if (!require("pacman")) install.packages("pacman") ; library(pacman)
# pacman::p_load(shiny, leaflet, htmlwidgets, htmltools, sf, tidyverse, shinythemes, DT, shinydashboard)

library(shiny)
library(leaflet)
library(htmltools)
library(sf)
library(dplyr)
library(DT)
library(purrr)

# Load data
# load("data/all_data_shiny.Rdata")
#load("data/data_for_GAPeDNA_old.Rdata")
load("data/data_for_GAPeDNA.Rdata")

marine_province <- st_make_valid(marine_province)
st_is_valid(marine_province)
# Add a file to guide decision within the app
organisation <- data.frame(taxa = c("Marine fish","Marine fish", "Marine fish", "Freshwater fish", "Freshwater fish"), 
                           resolution = c("Provinces", "Ecoregions", "World", "Basins", "World"),
                           data_chosen = c("occurence_marine_province", "occurence_marine_ecoregion", "occurence_marine_world", "occurence_freshwater_basin", "occurence_freshwater_world"), # name of file with information
                           geometry = c("marine_province", "marine_ecoregion", "marine_world", "freshwater_basin", "freshwater_world"), # names of geometry file 
                           stringsAsFactors = F)

# SERVER
function(input, output){
  
  # ----------------------------------------------------------------------------------------------------------- # 
  # PANEL 1 
  # ----------------------------------------------------------------------------------------------------------- # 
  
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
      dplyr::filter(marker == input$the_marker) %>%
      left_join(., dataset_geometry()) %>%
      st_as_sf()
    # st_crs(datasetInput1()) <- st_crs(datasetInput1())
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
      datasetInput()$RegionName,  datasetInput()$pourcent_seq, datasetInput()$nombre_seq, datasetInput()$nombre_tot) %>% 
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
      addPolygons(layerId=~RegionName, group = "continuous",
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
 # table_display <- reactive(fresh_and_marine %>%
 #                             # Choose among the correct dataset for the resolution 
 #                             # filter(dataset_resolution == input$resolution_chosen) %>%
 #                             filter(RegionName %in% SelectedID()) %>% # select polygon ID
 #                             dplyr::select(RegionName, Species_name, IUCN) %>%
 #                             mutate(Sequenced = ifelse(test = Species_name %in% all_primers[[input$the_marker]], yes="Yes", no="No")) %>%
 #                             mutate(Marker = input$the_marker) %>%
 #                             mutate(Sequenced = as.factor(Sequenced)) %>%                              
 #                             dplyr::select(RegionName, Marker, Species_name, IUCN, Sequenced) %>%
 #                             arrange(Species_name))
 # 
  table_display <- reactive(all_occurences_list %>%
                              # Choose among the correct dataset for resolution & target group
                              filter(taxa == input$taxon_chosen) %>%
                              filter(spatial_resolution == input$resolution_chosen) %>%
                              # select polygon ID
                              filter(RegionName %in% SelectedID())%>% 
                              # Link to IUCN 
                              left_join(., all_iucn_tab[, c("Family", "Species_name", "IUCN")]) %>%
                              mutate(IUCN = case_when(
                                is.na(IUCN) ~ "Not evaluated", 
                                TRUE ~ IUCN
                              )) %>%
                              mutate(IUCN = as.factor(IUCN)) %>%
                              rename(Species = Species_name) %>%
                              # Select data
                              dplyr::select(RegionName, Species, IUCN) %>%
                              mutate(Sequenced = ifelse(test = Species %in% list_species_name[[input$the_marker]], yes="Yes", no="No")) %>%
                              mutate(Marker = input$the_marker) %>%
                              mutate(Sequenced = as.factor(Sequenced)) %>%                              
                              dplyr::select(RegionName, Marker, Species, IUCN, Sequenced) %>%
                              arrange(Species)
                            )
  
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
  
  # ----------------------------------------------------------------------------------------------------------- # 
  # PANEL 2
  # ----------------------------------------------------------------------------------------------------------- # 
  
  # Read the dataframe
  dataframe_sequence <-reactive({
    if (is.null(input$datafile_forseq))
      return(NULL)                
    data<-read.csv(input$datafile_forseq$datapath, stringsAsFactors = F)
    data
  })
  
  # Print the table - for debug only 
  output$table_input <- shiny::renderTable({
    head(dataframe_sequence(), n=2)
  })
  
  # Merge species with sequence data - needs to specify the marker -- add a selection thing? 
  # Isolate the marker chosen
  marker_sequences <- reactive(
    dataframe_sequence() %>%
    select(Marker) %>% distinct(Marker) %>% pull() 
  )
  
  # Select sequences within the list corresponding to the marker of interest
  ecopcr_for_marker <- reactive({
    list_ecopcr_df[[marker_sequences()]]
})
  
  # Merge sequence and occurrence data for download
  data_seq_download <- reactive({
    # Check input exists
    req(input$datafile_forseq)
    # Proceed to add sequences
    dataframe_sequence() %>%
      as.data.frame() %>%
    left_join(., as.data.frame(ecopcr_for_marker()), by=c("Species" = "species_name")) %>%
    # Clean columns
    select(-taxid, -genus_name, -family_name, -marker_name,-taxa_group) %>%
      mutate(IUCN = as.factor(IUCN),
             Sequenced = as.factor(Sequenced))
  })
  
  #  Print the table w/ sequences
  # Print it with DT - cleaner
  output$table_output_sequences <- DT::renderDataTable({
    datatable(data_seq_download(),
    class = 'cell-border stripe', 
    options = list(columnDefs = list(list(className = 'dt-center', targets = "_all"))),
    rownames = FALSE,
    filter='top')%>%
      formatStyle('Sequenced',
                  backgroundColor = styleEqual(c("No","Yes"), c('#F7FBFF', '#abf9bc'))) %>% 
      formatStyle('IUCN',
                  backgroundColor = styleEqual(c("CR", "EN", "VU", "NT", "LC","Not evaluated", "DD"), c('#f7c283', '#f7d383', '#f7e183', '#f7ef83', '#abf9bc', '#F7FBFF', '#F7FBFF')))
  })
  
  # Download the sequence table
  # Check the name -- input thing but before the .csv
  output$download_sequences <- downloadHandler(
    filename = function() {
      paste(strsplit(as.character(input$datafile_forseq), ".csv")[[1]], "_with_sequences", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(data_seq_download(), file, row.names = FALSE)
    }
  )
  
}

# Debug 
# dataframe_sequence <- read.csv("/Users/virginiemarques/Downloads/Marine fish_Bylemans_12S_Tropical Northwestern # Atlantic.csv", stringsAsFactors = F)
# marker_sequences<- "Bylemans_12S"
# ecopcr_for_marker <- list_ecopcr_df[[marker_sequences]]
# data_seq_download <- dataframe_sequence %>%
#   left_join(., ecopcr_for_marker, by=c("Species" = "species_name")) %>%
#   # Clean columns
#   select(-taxid, -genus_name, -family_name, -marker_name,-taxa_group)
# 

