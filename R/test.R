library(tidyverse)
library(data.table)
library(httr)
library(leaflet)
library(leaflet.minicharts)

source('R/rsid.R')

rsid <- 'rs17822931'
data_all <- get_freq(rsid)

data <- data_all %>% filter(short_name != 'tot') %>% filter(short_name != 'oth') %>% filter(short_name != 'afr') %>% filter(short_name != 'aas')

leaflet(
  options = leafletOptions(zoomSnap = 0.5, zoomDelta=0.5)
) %>% 
  addMapPane(name = 'base', zIndex = 0) %>% 
  addMapPane(name = 'labels', zIndex = 2) %>%
  addMapPane(name = 'polygons', zIndex = 1) %>% 
  addProviderTiles(
    provider = 'CartoDB.VoyagerNoLabels',
    options = providerTileOptions(pane = 'base'),
    group = 'base_g'
  ) %>% 
  addProviderTiles(
    provider = 'CartoDB.VoyagerOnlyLabels',
    options = providerTileOptions(pane = 'labels', opacity = 0.8),
    group = 'labels_g'
  ) %>% 
  addMinicharts(
    lng = data$long, 
    lat = data$lat,
    type = 'pie',
    chartdata = data[, c('alt', 'ref')],
    showLabels = TRUE,
    layerId = data$full_name,
    labelText = data$short_name
    
    
    # colorPalette = colors, 
  ) %>% 
  setView(lng = -5, lat = 22, zoom = 2.5)

