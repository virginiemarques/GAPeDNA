# Library 
update.packages(c("shiny", "leaflet", "htmlwidgets", "htmltools", "sf", "tidyverse", "viridis", "shinythemes", "DT", "shinydashboard"), ask=F)
if (!require("pacman")) install.packages("pacman") ; library(pacman)
pacman::p_load(shiny, leaflet, htmlwidgets, htmltools, sf, tidyverse, viridis, shinythemes, DT, shinydashboard)

# Load data
load("data/data_for_shiny.Rdata")
load("data/freshwater_by_basin_separated.Rdata")

# Format data
p3 <- p %>%
  mutate(BasinName = as.character(BasinName)) %>%
  left_join(., all_occurence, by='BasinName') %>%
  mutate(pourcent_seq = pourcent_seq*100)

# Add a file to guide decision within the app
# Incorporate in data_for_shiny later if kept
organisation <- as.data.frame(matrix(NA, ncol=2, nrow=4))
colnames(organisation) <- c("taxa", "resolution")

# Set the organisation
organisation$taxa <- c("Marine fish", "Marine fish","Marine fish","Freshwater fish")
organisation$resolution <- c("Realms", "Provinces", "Ecoregions", "Basins")
organisation$data_chosen <- c("marine_region", "marine_meow", "marine_ecoreg", "p3")

# SERVER
function(input, output){
  
  output$control_resolution <- renderUI({
    selectInput("resolution_chosen", label = "Choose a geographic resolution", 
                choices = organisation %>% dplyr::filter(taxa == input$taxon_chosen) %>% dplyr::select(resolution) %>% pull())
  })
  
  output$control_marker <- renderUI({
    selectInput("the_marker", label = "Choose a primer pair", 
                choices = primers_type %>% dplyr::filter(marker_position == input$marker_position) %>% dplyr::select(marker_single) %>% pull())
  })
  
  
  # Select the chosen dataset 
  # Put it in reactive mode to make lighter calculations 
  
  
  datasetInput1 <- reactive({
    
    req(input$taxon_chosen)
    req(input$resolution_chosen)

    organisation %>%
      dplyr::filter(taxa == input$taxon_chosen) %>% 
      dplyr::filter(resolution == input$resolution_chosen) %>% 
      dplyr::select(data_chosen) %>%
      pull(data_chosen) %>%
      get()
    
  })
  
  datasetInput <- reactive({      
    req(input$the_marker)
    
    datasetInput1() %>%
      dplyr::filter(Marker == input$the_marker) 
  })
  
  
  #output$datasettt <- renderPrint({
  #  paste(input$dataset, 
  #        datasetInput1())
  #})
  
  # The leaflet map
  output$map <- renderLeaflet({
    
    req(datasetInput1())
    req(datasetInput())
    
    # Do personalizations depending on the dataset in input 
    # Can be speed up using do.call (maybe)
    # Labels en pourcent
    labels <- sprintf(
      "<strong>%s</strong><br/>%g %% sequenced <br/> %g / %g sequenced species",
      datasetInput()$BasinName,  datasetInput()$pourcent_seq, datasetInput()$nombre_seq, datasetInput()$nombre_tot) %>% 
      lapply(htmltools::HTML)
    
    # Deak with colors and bins
    # bins <- c(0, 20,40,60,80,100)
    #bins <- seq(0,100, 20)
    #pal <- colorBin("YlOrRd", domain = datasetInput()$pourcent_seq, bins = bins)
    
    #conpal <- colorNumeric(palette = "YlOrRd", domain = datasetInput()$pourcent_seq)
    conpal <- colorNumeric(palette = "YlOrRd", domain = c(0,100))
    
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
                title = NULL,
                position = "bottomright") %>%
      # Polygons
      addPolygons(layerId=~BasinName, group = "continuous",
                  smoothFactor = 0.2, fillOpacity = 1,
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
    
    
  })
  
  # Clickable object 
  # Create a null reactive value to store the ID of the layer
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
                              mutate(Sequenced = ifelse(test = Species_name %in% all_primers[[input$the_marker]], yes="yes", no="no")) %>%
                              mutate(Marker = input$the_marker) %>%
                              mutate(Sequenced = as.factor(Sequenced)) %>%                              
                              dplyr::select(BasinName, Marker, Species_name, IUCN, Sequenced) %>%
                              arrange(Species_name))
  
  output$tableau = DT::renderDataTable({
    req(SelectedID())
    datatable(table_display(), 
              class = 'cell-border stripe', 
              options = list(columnDefs = list(list(className = 'dt-center', targets = "_all"))),
              rownames = FALSE,
              filter='top', 
              caption = htmltools::tags$caption(
                style = 'caption-side: bottom; text-align: center;',
                'UICN categories: ', 
                htmltools::em('DD: Data Deficient, EX: extinct, EW: extinct in wild, CR: Critically endangered, EN: Engangered, VU: Vulnerable, NT: Near Threatened, LC: Least Concern'))) %>%
      
      formatStyle('Sequenced',
                  backgroundColor = styleEqual(c(0,1), c('#F7FBFF', '#abf9bc'))) %>% # Or lightgreen also is fine
      
      formatStyle('IUCN',
                  backgroundColor = styleEqual(c("EX", "EW", "CR", "EN", "VU", "NT", "LC","Not evaluated", "DD"), c('#f7a883', '#f7b583', '#f7c283', '#f7d383', '#f7e183', '#f7ef83', '#abf9bc', '#F7FBFF', '#F7FBFF')))
    
  })
  
  # the download
  
  output$download <- downloadHandler(
    filename = function() {
      paste(input$dataset, "_", input$the_marker, "_", SelectedID(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv( table_display(), file, row.names = FALSE)
    }
  )
  
  
}
