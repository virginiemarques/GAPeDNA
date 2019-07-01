# Trial 1
# Shiny app 

getwd()

# Library 
library(shiny)
library(leaflet)
library(htmlwidgets)
library(htmltools)
library(sf)
library(tidyverse)
library(viridis)
library(shinythemes)
library(DT)
library(shinydashboard)

# Theme
theme_set(theme_minimal()) 

#----------------------- # Load data
# IUCN
load("data/04_all_iucn.Rdata")

#----------------------- Genetics
load("data/all_primers.Rdata")

# Freshwater
load("data/freshwater_by_basin_separated.Rdata")

p3 <- merge(p, all_occurence, by='BasinName')
p3 <- p3 %>%
  mutate(pourcent_seq = pourcent_seq*100)

# Marine
marine_grid <- readRDS("data/grid_ID.RDS") %>%
  mutate(BasinName = ID_pair) %>%
  mutate(pourcent_seq = pourcent_seq*100)

marine_region <- readRDS("data/grid_reg.RDS") %>%
  mutate(BasinName = V2) %>%
  filter(!BasinName == "Other") %>%
  mutate(pourcent_seq = pourcent_seq*100)

marine_meow <- readRDS("data/grid_meow.RDS") %>%
  mutate(BasinName = PROVINC) %>%
  mutate(pourcent_seq = pourcent_seq*100)

marine_ecoreg <- readRDS("data/grid_ecoreg.RDS") %>%
  mutate(BasinName = ECOREGION) %>%
  mutate(pourcent_seq = pourcent_seq*100)

class(marine_meow)
class(marine_ecoreg)

# List of species for the table
load("data/sp_present_realms_grid.Rdata")

marine_sp5 <- marine_sp5 %>%
  mutate(BasinName = V2) %>%
  dplyr::select(BasinName, Species_name)

marine_sp6 <- marine_sp6 %>%
  mutate(BasinName = ID_pair) %>%
  filter(!is.na(Presence)) %>%
  dplyr::select(BasinName, Species_name) 

marine_sp7 <- marine_sp7 %>%
  mutate(BasinName = PROVINC) %>% 
  dplyr::select(BasinName, Species_name) 

marine_sp8 <- marine_sp8 %>%
  mutate(BasinName = ECOREGION) %>% 
  dplyr::select(BasinName, Species_name) 


# Prepare the data for the list of species 
# Make a list that we will be used later to make the dataframe 
# List avec names=BasinName, will be click$id. Link both  

# ----- Freshwaer 
occurence <- read.csv("data/Occurrence_Table.csv", h=TRUE, sep=";", stringsAsFactors = F) %>%
  mutate(X6.Fishbase.Valid.Species.Name = gsub("\\.", "_", X6.Fishbase.Valid.Species.Name)) %>%
  rename(BasinName = X1.Basin.Name) %>%
  mutate(Species_name = X6.Fishbase.Valid.Species.Name) %>%
  dplyr::select(BasinName, Species_name)


# Combine all 
fresh_and_marine <- rbind(occurence, marine_sp5, marine_sp6, marine_sp7, marine_sp8)

# Add IUCN 
fresh_and_marine <- fresh_and_marine %>%
  left_join(.,  all_iucn[, c("Species_name", "category")]) %>%
  mutate(category2 = case_when(
    is.na(category) ~ "Not evaluated", 
    category == "LR/nt" ~ "NT", 
    category == "LR/cd" ~ "NT", # old cassif, CD is NT now https://en.wikipedia.org/wiki/IUCN_Red_List
    category == "LR/lc" ~ "LC", 
    category %in% unique(category) ~ category
  )) %>%
  mutate(IUCN = as.factor(category2)) # Need to ordonate the factors 


# Save all data for quick deployment: doesnt work (too large, > 100MB)
#save.image(file='/Volumes/LaCie/These/Gaps_shiny_quicktest/data/data_for_shiny.Rdata')