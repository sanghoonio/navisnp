library(shiny)
library(shinyjs)
library(bslib)
library(tidyverse)
library(leaflet)

ui <- fluidPage(
  
  useShinyjs(),
  theme = bs_theme(version = 5),
  
  extendShinyjs(script = 'script.js', functions = c()),
  
  tags$head(
    tags$title('naviSNP'),
    tags$link(rel = 'stylesheet', type = 'text/css', href = 'style.css'),
    tags$link(rel = 'icon', type = 'image/x-icon', href = '/favicon.ico'),
    tags$link(rel = 'apple-touch-icon', sizes='180x180', href = '/apple-touch-icon.png'),
    tags$link(rel = 'manifest', href = '/site.webmanifest')
  ),
  
  tags$meta(name = 'theme-color', content = '#fff'),
  
  
  div(
    class = 'row',
    style = 'background-color:#fff; min-height:100vh;',
    div(
      class = 'col-12',
      
      ## body ----
      div(
        class = 'row',
        div(
          class = 'col-md-3',
          id = 'sidebar',
          style = 'background-color:#fff; padding:20px;',
          
          div(
            style = 'text-align:center; padding: 10px 0; margin-bottom:15px;',
            h4(
              id = 'page_title', 
              'naviSNP'
            ),
          ),
          
          div(
            style = 'text-align:center;',
            div(
              id = 'rsid_div',
              
              tags$input(
                class = 'rsid_input',
                id = 'rsid_input',
                style = 'margin-right:0;',
                placeholder = 'rsID',
              ),
              tags$button(
                class = 'rsid_button',
                id = 'random_rsid',
                style = 'margin-left:-5px;',
                # icon('magnifying-glass')
                'Random'
              ),
              tags$button(
                class = 'rsid_button',
                id = 'submit_rsid',
                style = 'background-color:#ddd;',
                'Go!'
              )
            ),
            br(),
            div(
              tableOutput('rsid_table')
            )
          )
          
        ),
        
        div(
          class = 'col-md-9',
          style = 'text-align:center; padding:0;',
          div(
            leafletOutput('leaflet_map', width = '100%', height = '100vh')
          )
        )

      )
    )
  )
)