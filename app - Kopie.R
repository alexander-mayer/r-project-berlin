###Shiny application r_project_berlin###
#install.packages("shiny")
library(shiny)
library(bslib)
library(leaflet)
library(terra)
library(raster)

# Define UI for app that draws a histogram ----
ui <- page_sidebar(
  # App title ----
  title = "Hello world!",
  # Sidebar panel for inputs ----
  sidebar = sidebar(
    "This is a shiny applicaion",
    # Input: Slider for the number of bins ----
    card(
      card_header("Select environmental factor for comparison"),
      selectInput(
        "var_env",
        label = "Select option",
        choices = list(
          #"NO2" = "data/2_a_pollutant_grid_avg_no2_2024.tiff", #NO2 – Stickstoffdioxid in µg/m³ 2024
          #"PM2.5" = "data/2_b_pollutant_grid_avg_pm10_2024.tiff", #PM10 – Partikel < 10 µm in µg/m³ 2024
          #"PM10" = "data/2_c_pollutant_grid_avg_pm2_5_2024.tiff", #PM2,5 – Partikel < 2,5 µm in µg/m³ 2024
          #"Noise pollution" = "data/3_b_09_01_1UGlaerm2021.tiff", #Kernindikator Lärmbelastung
          "Noise pollution_gpkg"= "data/1_b_09_01_1UGlaerm2021.gpkg"
        )
      )
    ),
    
    card(
      card_header("Select social factor for comparison"),
      selectInput(
        "var_soc",
        label = "Select option",
        choices = list("sozial" = 1, "xx" = 2),
        selected = 1
      )
    )
  ),
  "main content",
  value_box(
  title = "Value box",
  value = 100,
  showcase = "bar-chart",
  theme = "teal"
  ),
  
  card(
    card_header("Map of Berlin"),
    leafletOutput("map", height = 500)
    )
)



# Define server logic required to draw a histogram ----
server <- function(input, output) {
  
  # Histogram of the Old Faithful Geyser Data ----
  # with requested number of bins
  # This expression that generates a histogram is wrapped in a call
  # to renderPlot to indicate that:
  #
  # 1. It is "reactive" and therefore should be automatically
  #    re-executed when inputs (input$bins) change
  # 2. Its output type is a plot
    
    env_raster <- reactive({
      req(input$var_env)
      r_stack <- st_read("data/1_b_09_01_1UGlaerm2021.gpkg")
      r_stack <- st_transform(r_stack, 4326)
      #r_stack<-rast(input$var_env)
      #ext(r_stack) <- ext(369950, 415850, 5799450, 5837300)
      #crs(r_stack) <- "EPSG:32633"
      
      r_stack
    })
    
    output$map <- renderLeaflet({
      leaflet(data=env_raster()) %>%
        setView(lng = 13.4, lat = 52.5, zoom = 11) %>%
        addTiles() %>%
        addPolygons()
        #addRasterImage(
         # raster(env_raster()),
          #opacity = 0.7)
    })
  }
  
shinyApp(ui = ui, server = server)
