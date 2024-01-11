library(shiny)
library(shinyjs)
library(bslib)
library(tidyverse)
library(leaflet)
library(shinycssloaders)

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
          class = 'col-xxl-3',
          id = 'sidebar',
          
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
              p(style = 'font-size:13px;', 'Enter a variant to view global allele frequencies.')
            ),
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
              style = 'text-align:left; margin:30px 0 10px 0;',
              uiOutput('rsid_meta') %>% withSpinner()
            )
          ),
          
          div(
            id = 'contact',
            p(
              id = 'contact_icons',
              style = 'margin:0;',
              a(
                href = 'https://github.com/sanghoonio/navisnp',
                icon(name = 'square-github')
              ),
              a(
                href = 'https://www.linkedin.com/in/sanghoonio/',
                icon(name = 'linkedin')
              )
            ),
            HTML(
              '<p class="credits" style="margin:0; font-size:12px;">Data from <a href="https://gnomad.broadinstitute.org/news/2023-11-gnomad-v4-0/">gnomAD</a>, <a href="https://www.ncbi.nlm.nih.gov/snp/docs/gsr/alfa/">ALFA</a>, <a href="https://www.ncbi.nlm.nih.gov/snp/">dbSNP</a>, and <a href="https://www.snpedia.com/index.php/SNPedia">SNPedia</a>.</p>'
            )
          ),
          
        ),
        
        div(
          class = 'col-xxl-9',
          style = 'text-align:center; padding:0;',
          div(
            leafletOutput('leaflet_map', width = '100%', height = '100vh')
          ),
          
          div(
            id = 'contact_map',
            p(
              id = 'contact_map_icons',
              style = 'margin:0;',
              a(
                href = 'https://github.com/sanghoonio/navisnp',
                icon(name = 'square-github')
              ),
              a(
                href = 'https://www.linkedin.com/in/sanghoonio/',
                icon(name = 'linkedin')
              )
            ),
            HTML(
              '<p class="credits" style="margin:0; font-size:12px;">Data from <a href="https://gnomad.broadinstitute.org/news/2023-11-gnomad-v4-0/">gnomAD</a>, <a href="https://www.ncbi.nlm.nih.gov/snp/docs/gsr/alfa/">ALFA</a>, <a href="https://www.ncbi.nlm.nih.gov/snp/">dbSNP</a>, and <a href="https://www.snpedia.com/index.php/SNPedia">SNPedia</a>.</p>'
            )
          )
        )
      )
    )
  )
)
