# Install necessary packages
if (!require("shiny")) install.packages("shiny")
if (!require("leaflet")) install.packages("leaflet")
if (!require("geojsonsf")) install.packages("geojsonsf")
if (!require("dplyr")) install.packages("dplyr")
if (!require("sf")) install.packages("sf")
if (!require("here")) install.packages("here")

library(shiny)
library(leaflet)
library(geojsonsf)
library(dplyr)
library(sf)
library(here)

# Read and process the data using here() for proper path resolution
# 1. Read GeoJSON data and convert to SF object
collision_data <- st_read(here("data", "02-analysis_data", "collision.geojson"))

# 2. Read risk index data
risk_data <- read.csv(here("data", "02-analysis_data", "final_risk_index.csv")) %>%
  distinct(hood_158, risk_index) %>%  # Remove duplicates to get unique hood/risk pairs
  filter(!is.na(risk_index))  # Remove NA values

# 3. Create neighborhood centroids from collision data
neighborhood_data <- collision_data %>%
  group_by(HOOD_158, NEIGHBOURHOOD_158) %>%
  summarise(
    collision_count = n(),
    # Convert to centroid, ensuring point geometry
    geometry = st_centroid(st_union(geometry))
  ) %>%
  ungroup() %>%
  # Ensure geometry is properly set
  st_cast("POINT")

# 4. Merge with risk data
merged_data <- neighborhood_data %>%
  left_join(risk_data, by = c("HOOD_158" = "hood_158")) %>%
  filter(!is.na(risk_index))  # Remove any remaining NA values

# Define UI with background image, dark brown title, and Georgia font
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {
        background-image: url('1.jpg');
        background-size: cover;
        background-repeat: no-repeat;
        background-attachment: fixed;
        font-family: Georgia, serif;
      }
      .container-fluid {
        background-color: rgba(255, 255, 255, 0.3);  /* Reduced opacity from 0.9 to 0.6 */
        padding: 20px;
        border-radius: 10px;
        font-family: Georgia, serif;
      }
      h2 {
        color: black;
        font-weight: bold;
        font-family: Georgia, serif;
      }
      .selectize-input, .selectize-dropdown, .slider-animate-container {
        font-family: Georgia, serif;
      }
      .leaflet-container {
        font-family: Georgia, serif !important;
      }
    "))
  ),
  titlePanel(
    h2("Toronto Motor Vehicle Risk Index by Neighborhood", 
       style = "color: black; font-weight: bold; font-family: Georgia, serif;")
  ),
  sidebarLayout(
    sidebarPanel(
      style = "background-color: rgba(255, 255, 255, 0.7); font-family: Georgia, serif;",  # Reduced opacity
      selectInput("neighborhood", "Select Neighborhood:", 
                  choices = unique(merged_data$NEIGHBOURHOOD_158),
                  selected = NULL,
                  multiple = TRUE),
      sliderInput("risk_range", "Collision Risk Index Range:",
                  min = round(min(merged_data$risk_index, na.rm = TRUE), 2),
                  max = round(max(merged_data$risk_index, na.rm = TRUE), 2),
                  value = c(round(min(merged_data$risk_index, na.rm = TRUE), 2),
                           round(max(merged_data$risk_index, na.rm = TRUE), 2)),
                  step = 0.001,
                  width = "100%",
                  ticks = TRUE,
                  sep = ""),
      hr(),
      HTML("<strong style='font-family: Georgia, serif;'>How to Use This Map:</strong><br><br>
           • Click and drag to pan around the map<br>
           • Use mouse wheel or '+/-' buttons to zoom<br>
           • Click on circles to see detailed information<br>
           • Use dropdown to select specific neighborhoods<br>
           • Adjust slider to filter by risk index range<br>
           • Circle size indicates number of collisions<br>
           • Color intensity shows risk level (yellow=lower, red=higher)")
    ),
    mainPanel(
      style = "background-color: rgba(255, 255, 255, 0.7); font-family: Georgia, serif;",  # Reduced opacity
      leafletOutput("riskMap", height = "800px")
    )
  )
)

# Define server
server <- function(input, output, session) {
  
  # Create filtered reactive dataset
  filtered_data <- reactive({
    data <- merged_data
    
    if (!is.null(input$neighborhood) && length(input$neighborhood) > 0) {
      data <- data[data$NEIGHBOURHOOD_158 %in% input$neighborhood, ]
    }
    
    data <- data[data$risk_index >= input$risk_range[1] & 
                 data$risk_index <= input$risk_range[2], ]
    
    return(data)
  })
  
  # Create the map
  output$riskMap <- renderLeaflet({
    # Create color palette
    pal <- colorNumeric(
      palette = "YlOrRd",
      domain = merged_data$risk_index
    )
    
    # Get coordinates for filtered data
    data <- filtered_data()
    coords <- st_coordinates(data)
    
    # Create base map
    leaflet(data) %>%
      addTiles() %>%
      setView(lng = -79.3832, lat = 43.6532, zoom = 11) %>%  # Toronto coordinates
      addCircleMarkers(
        lng = coords[,1],
        lat = coords[,2],
        radius = ~sqrt(collision_count),
        fillColor = ~pal(risk_index),
        color = "white",
        weight = 1,
        opacity = 1,
        fillOpacity = 0.7,
        popup = ~paste0(
          "<div style='font-family: Georgia, serif;'>",
          "<strong>", NEIGHBOURHOOD_158, "</strong><br>",
          "Motor Vehicle Collision Risk Index: <span style='color:", pal(risk_index), "'>", 
          round(risk_index, 2), "</span><br>",
          "Total Collisions: <span style='color:", pal(risk_index), "'>",
          collision_count, "</span>",
          "</div>"
        )
      ) %>%
      addLegend(
        position = "bottomright",
        pal = pal,
        values = ~risk_index,
        title = "Motor Vehicle Collision Risk Index",
        opacity = 0.7,
        labFormat = labelFormat(digits = 2)
      )
  })
}

# Run the app
shinyApp(ui, server)
