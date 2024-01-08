library(shiny)
library(shinyjs)
library(tidyverse)
library(data.table)
library(httr)
library(leaflet)

source('R/rsid.R')

server <- function(input, output, session) {

  observeEvent(input$rsid, {
    rsid <- input$rsid
    data <- get_freq(rsid) %>% filter(!(short_name %in% c('tot', 'oth', 'afr', 'aas')))

    print(data)
    output$rsid_table <- renderTable(data$alt_af)
    
    leafletProxy('leaflet_map', session) %>%
      addMinicharts(
        lng = data$long, 
        lat = data$lat,
        type = 'pie',
        chartdata = data[, c('alt', 'ref')],
        showLabels = TRUE,
        layerId = data$full_name,
        labelText = data$short_name
      )
    
    
  })
  
  states <- geojsonio::geojson_read('https://rstudio.github.io/leaflet/json/us-states.geojson', what = 'sp')
  
  bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
  pal <- colorBin('YlOrRd', domain = states$density, bins = bins)
  
  labels <- sprintf(
    '<strong>%s</strong><br/>%g people / mi<sup>2</sup>',
    states$name, states$density
  ) %>% lapply(htmltools::HTML)
  
  output$leaflet_map <- renderLeaflet({
    leaflet(
      # states,
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
      # addPolygons(
      #   options = providerTileOptions(pane = 'polygons'),
      #   group = 'polygons_g',
      #   fillColor = ~pal(density),
      #   weight = 2,
      #   color = '#fff',
      #   opacity = 1,
      #   dashArray = '',
      #   fillOpacity = 0.5,
      #   highlightOptions = highlightOptions(
      #     weight = 4,
      #     color = '#666',
      #     opacity = 1,
      #     dashArray = '',
      #     fillOpacity = 0.5,
      #     bringToFront = TRUE
      #   ),
      #   label = labels,
      #   labelOptions = labelOptions(
      #     style = list('font-weight' = 'normal', padding = '3px 8px'),
      #     textsize = '15px',
      #     direction = 'auto'
      #   )
      # ) %>%
      # addLegend(
      #   pal = pal,
      #   values = ~density,
      #   opacity = 0.8,
      #   title = NULL,
      #   position = 'bottomright'
      # ) %>% 
      setView(lng = -5, lat = 22, zoom = 2.5)
  })
  
}
