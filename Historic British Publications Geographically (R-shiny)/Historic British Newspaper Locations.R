# Dataset : https://bl.iro.bl.uk/concern/datasets/7da47fac-a759-49e2-a95a-26d49004eba8?locale=en
# A title-level list of British, Irish, British Overseas Territories and Crown Dependencies newspapers held by the British Library.

# Dataset2: https://raw.githubusercontent.com/programminghistorian/ph-submissions/gh-pages/assets/shiny-leaflet-newspaper-map-tutorial-data/newspaper_coordinates.csv
# coordinates list of newspaper publications

#Load Libraries
library(tidyverse)
library(shiny)
library(sf)
library(leaflet)

# Reading in the data
title_list = read_csv('BritishAndIrishNewspapersTitleList_20191118.csv')
coordinates_list = read_csv('newspaper_coordinates.csv')

# Setting up shiny

ui <- fluidPage(
  
  titlePanel("Newspaper Map"),
  
  sidebarLayout(
    sidebarPanel = sidebarPanel(sliderInput('years', 
                                            'Years', min = 1621, 
                                            max = 2000, 
                                            value = c(1700, 1750))),
    
    mainPanel = mainPanel(
      leafletOutput(outputId = 'map')
    )
    
  )
)

server <- function(input, output, session) {
  
  # Creating Map dataframe, Cities with their coordinates
  map_df = reactive({
    
    title_list %>%
      # filter the range from input slider
      filter(first_date_held > input$years[1] & first_date_held < input$years[2]) %>%
      count(coverage_city, name = 'titles') %>% # Get each city and no. of times they appear 
      left_join(coordinates_list, by = 'coverage_city') %>% # join with coordinates
      filter(!is.na(lng) & !is.na(lat)) %>% # remove cities with missing coordinates
      st_as_sf(coords = c('lng', 'lat')) %>% # change coords into simple features
      st_set_crs(4326) # coordinate reference system  EPSG:4326
    
  })
  
  # Creating Map with leaflet
  output$map = renderLeaflet({
    
    leaflet() %>%
      addTiles() %>% #Default Tiles
      setView(lng = -5, lat = 54, zoom = 5.2) %>% # Default zoom to UK & Ireland
      addCircleMarkers(data = map_df(), radius = ~sqrt(titles)) # Label coordinates with cirles
    
  })
}

shinyApp(ui, server)
