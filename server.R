library(shiny)
library(shinyjs)
library(tidyverse)
library(data.table)
library(httr)
library(leaflet)
library(leaflet.minicharts)
library(shinycssloaders)

source('R/rsid.R')
source('R/views.R')

server <- function(input, output, session) {
  
  ## prerender blank for metadata ui ----
  output$rsid_meta <- renderUI(NULL)
  
  ## observe when rsid input chagnges ----
  observeEvent(input$rsid, {
    rsid <- input$rsid
    
    tryCatch({
      data <- get_rsid(rsid)
      
      if (!is.null(data)) {
        showSpinner('rsid_meta')
        
        leafletProxy('leaflet_map', session) %>% 
          clearMinicharts()
        
        ### get data ----
        meta <- data$meta
        freq <- data$freq
        wiki <- get_wiki(rsid)
        
        ### update metadata ui ----
        output$rsid_meta <- renderUI(
          rsid_meta(rsid = rsid, meta = meta, freq = freq, wiki = wiki)
        )
        
        ### add minichart ----
        leafletProxy('leaflet_map', session) %>%
          addMinicharts(
            lng = freq$long, 
            lat = freq$lat,
            type = 'pie',
            chartdata = freq[, c('ref', 'alt')],
            colorPalette = c('#1f77b4', '#ff7f0e'),
            layerId = freq$name,
            showLabels = FALSE,
            legend = FALSE,
            popupOptions = list(
              closeButton = FALSE
            ),
            popup = popupArgs(
              html = paste0(
                '<div class="popup">',
                '<h6>', freq$name, '</h6>',
                '<p>Ref Allele (', freq$ref_al[[1]], '): <strong style="color:#1f77b4;">', (freq$ref*100) %>% round(2), '%</strong></p>',
                '<p>Alt Allele (', freq$alt_al[[1]], '): <strong style="color:#ff7f0e;">', (freq$alt*100) %>% round(2), '%</strong></p>',
                '<p>Total Samples: <strong>', freq$tot, '</strong></p>',
                '</div>'
              )
            )
          )
      } else {
        showNotification('Error: rsID is invalid.', duration = 3, type = 'error')
      }
    },
    error = function(e) {
      print(e)
      showNotification('Error: try again later.', duration = 3, type = 'error')
    })
    
  })
  
  ## render blank map ----
  output$leaflet_map <- renderLeaflet({
    leaflet(
      options = leafletOptions(zoomSnap = 0.5, zoomDelta=0.5, minZoom = 2)
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
      setView(lng = 4, lat = 22, zoom = 2.5) %>% 
      setMaxBounds(
        lng1 = -180,
        lat1 = -90,
        lng2 = 180,
        lat2 = 90
      )
  })
  
}
