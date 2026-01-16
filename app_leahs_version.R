#Raster wird nicht angezeigt, eventuelle Gründe:
 #1. Koordinatensystem (CRS)
    #Leaflet erwartet WGS84 / EPSG:4326 oder Web Mercator (EPSG:3857).
    #Dein Raster liegt in UTM (EPSG:25833).
    #project = TRUE funktioniert nur, wenn das Raster eine gültige CRS hat und terra richtig projizieren kann. Manche TIFFs haben allerdings keine CRS oder fehlerhafte CRS-Metadaten.
 #2. Extent / Georeferenzierung
    #Wenn das Raster außerhalb des Karten-Ausschnitts liegt, sieht man es nicht.
    #Beispiel: Raster in Meterkoordinaten (UTM) vs. Leaflet in Längen-/Breitengraden (Grad).
 #3. Rasterwerte außerhalb von 0–1 / Farbskala fehlt
    #Leaflet färbt Raster über Farbskalen.
    #Wenn Werte sehr groß oder NA sind, kann der Layer „unsichtbar“ erscheinen

############################################################
### Shiny application: Environmental & Social Berlin App ###
############################################################

library(shiny)
library(bslib)
library(leaflet)
library(terra)
library(raster)
library(ggplot2)
#############################
# 1. USER INTERFACE
#############################

ui <- page_sidebar(
  title = "Environmental & Social Indicators of Berlin",
  theme = bs_theme(version = 5, bootswatch = "minty"),
  
  sidebar = sidebar(
    h4("Explore!"),
    
    card(
      card_header("Environmental factor"),
      selectInput(
        inputId = "var_env",
        label = "Select option",
        choices = c(
          "NO2" = "data/2_a_pollutant_grid_avg_no2_2024.tiff",
          "PM10" = "data/2_b_pollutant_grid_avg_pm10_2024.tiff",
          "PM2.5" = "data/2_c_pollutant_grid_avg_pm2_5_2024.tiff",
          "Noise pollution" = "data/3_b_09_01_1UGlaerm2021.tiff"
        )
      )
    ),
    
    card(
      card_header("Social factor"),
      selectInput(
        inputId = "var_soc",
        label = "Select option",
        choices = c("GESIx" = "data/gesix_berlin.tiff")
      )
    ),
    
    card(
      card_header("Information"),
      p(
        "The Health and Social Index (GESIx) is derived from 20 indicators ",
        "covering employment, social status and health at the planning area level ",
        "for Berlin (2022)."
      )
    )
  ),
  
  navset_tab(
    nav_panel(
      "Info",
      h3("Welcome"),
      p("This application provides insight into the relationship between environmental pollution and social indicators in Berlin.")
    ),
    nav_panel(
      "Map",
      value_box(
        title = "Selected dataset",
        value = textOutput("dataset_name"),
        theme = "teal"
      ),
      card(
        card_header("Map of Berlin"),
        leafletOutput("map", height = 550)
      ),
      card(
        card_header("Scatterplot: Environmental vs Social indicator"),
        plotOutput("scatter", height = 400)
      )
    )
  )
)

#############################
# 2. SERVER LOGIC
#############################

server <- function(input, output, session) {
  
  # -----------------------------
  # 2.1 REACTIVE RASTER LOADING
  # -----------------------------
  # Environmental raster
  env_raster <- reactive({
    req(input$var_env)
    validate(need(file.exists(input$var_env), "Raster file not found."))
    
    r <- rast(input$var_env)
    
    # Set CRS if not available
    if (is.na(crs(r))) crs(r) <- "EPSG:25833"
    
    # Project raster to WGS84 for Leaflet
    r_proj <- project(r, "EPSG:4326")
    
    r_proj
  })
  
  # Social raster
  soc_raster <- reactive({
    req(input$var_soc)
    validate(need(file.exists(input$var_soc), "Raster file not found."))
    
    r <- rast(input$var_soc)
    if (is.na(crs(r))) crs(r) <- "EPSG:25833"
    r <- project(r, "EPSG:4326")  # Leaflet-compatible
    r
  })
  
  # -----------------------------
  # 2.2 VALUE BOX TEXT
  # -----------------------------
  output$dataset_name <- renderText({
    datasets <- c(
      "NO2 (µg/m³, 2024)" = "data/2_a_pollutant_grid_avg_no2_2024.tiff",
      "PM10 (µg/m³, 2024)" = "data/2_b_pollutant_grid_avg_pm10_2024.tiff",
      "PM2.5 (µg/m³, 2024)" = "data/2_c_pollutant_grid_avg_pm2_5_2024.tiff",
      "Noise pollution (2021)" = "data/3_b_09_01_1UGlaerm2021.tiff"
    )
    names(datasets[datasets == input$var_env])
  })
  
  # -----------------------------
  # 2.3 INITIAL LEAFLET MAP
  # -----------------------------
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = 13.4, lat = 52.52, zoom = 11)
  })
  
  # -----------------------------
  # 2.4 REACTIVE RASTER OVERLAY
  # -----------------------------
  observeEvent(env_raster(), {
    
    # Color scale automatically based on raster values
    pal <- colorNumeric("viridis", values(env_raster()), na.color = "transparent")
    
    leafletProxy("map") %>%
      clearImages() %>%
      addRasterImage(
        env_raster(),
        colors = pal,
        opacity = 0.7
      ) %>%
      addLegend(
        pal = pal,
        values = values(env_raster()),
        title = "Raster values",
        position = "bottomright"
      )
  })
  
  # -----------------------------
  # 2.6 SCATTERPLOT: Environmental vs Social
  # -----------------------------
  output$scatter <- renderPlot({
    req(env_raster(), soc_raster())
    
    # Extract values and use only cells that are not NA in both rasters
    env_vals <- values(env_raster())
    soc_vals <- values(soc_raster())
    
    valid <- !is.na(env_vals) & !is.na(soc_vals)
    env_vals <- env_vals[valid]
    soc_vals <- soc_vals[valid]
    
    # Scatterplot
    df <- data.frame(Environmental = env_vals, Social = soc_vals)
    ggplot(df, aes(x = Environmental, y = Social)) +
      geom_point(alpha = 0.5, color = "blue") +
      geom_smooth(method = "lm", col = "red") +
      labs(
        x = "Environmental indicator",
        y = "Social indicator",
        title = "Relation between environmental and social indicator"
      ) +
      theme_minimal()
  })
  
}

#############################
# 3. RUN THE APP
#############################
shinyApp(ui = ui, server = server)

