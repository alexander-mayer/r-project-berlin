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

#variables

bio_clim<-"R_bio.tif"
gruen<-"R_gruen.tif"
GESi<-"R_gssa.tif"
laerm<-"R_laerm.tif"
luft<-"R_luft.tif"
NO2<- "R_NO2.tif"
PM2_5<- "R_PM2_5.tif"
PM10<- "R_PM10.tif"
soz_benachteiligung<-"R_sozial.tif"




#############################
# 1. USER INTERFACE
#############################

ui <- page_sidebar(
  title = "Environmental & Social Indicators of Berlin",
  theme = bs_theme(version = 5, bootswatch = "minty"),
  
  sidebar = sidebar(
    h4("Select factors for comparison"),
    
    card(
      card_header("Factor 1"),
      selectInput(
        inputId = "var_env",
        label = "Select option",
        choices = c(
          "NO₂" =NO2,
          "PM10" = PM10,
          "PM2.5" = PM2_5,
          "Noise pollution" = laerm
        )
      )
    ),
    
    card(
      card_header("Factor 2"),
      selectInput(
        inputId = "var_soc",
        label = "Select option",
        choices = c(
          "NO₂" =NO2,
          "PM10" = PM10,
          "PM2.5" = PM2_5,
          "Noise pollution" = laerm
      )
    ),
    
    #card(
     # card_header("Information"),
      #p(
       # "The Health and Social Index (GESIx) is derived from 20 indicators ",
        #"covering employment, social status and health at the planning area level ",
        #"for Berlin (2022)."
      #)
    #)
  ),
  
  navset_tab(
    nav_panel(
      "Info",
      #h3("Welcome"),
      card("This application provides insight into the relationship between environmental pollution factors and social indicators in Berlin."),
      card(
        card_header("Information on selected factors"),
        card_body(
          p(uiOutput("dataset_info"))
        )
      )
    ),
    nav_panel(
      "Map",
      
      card(
        card_header("Map of Berlin"),
        card_body(
          leafletOutput("map", height = 550)
        )
      ),
      
      layout_columns(
        col_widths = c(3,9),
        value_box(
          title = "Selected datasets:",
          value = p(uiOutput("dataset_name")),
          theme = "teal"
        ),
        card(
          card_header("Color Map"),
          card_body(plotOutput("colormap"))
        )
      ),
      
      
      layout_columns(
        col_widths = c(4, 4, 4),
        plotOutput("hist_factor1"),
        plotOutput("hist_factor2"),
        plotOutput("scatter")
      ),
      
      card(
        card_header("Correlation Coefficient Map"),
        card_body(
          leafletOutput("correlation_map", height = 550)
        )
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
  # 2.2 nav_panel INFO (Info on datasets)
  # -----------------------------
  
  env_text <- c(
    "data/no2_2024_aligned.tif"  = "Nitrogen dioxide (NO₂) concentration in µg/m³.",
    "data/2_b_pollutant_grid_avg_pm10_2024.tiff" = "Particulate matter <10 µm (PM10).",
    "data/2_c_pollutant_grid_avg_pm2_5_2024.tiff" = "Fine particulate matter <2.5 µm (PM2.5).",
    "data/laerm.tif"        = "Average environmental noise exposure.",
    "data/gesix_berlin.tiff" = "The Health and Social Index (GESIx) is derived from 20 indicators covering employment, social status and health at the planning area level for Berlin (2022)."
  )
  
  
  output$dataset_info <- renderUI({
    tagList(
      tags$p(env_text[input$var_env]),
      tags$p(env_text[input$var_soc])
    )
  })
  
  # -----------------------------
  # 2.3 nav_panel MAP
  # ----------------------------- 
  
  # -----------------------------
  # 2.3.1 INITIAL LEAFLET MAP
  # -----------------------------
  output$map <- renderLeaflet({
    r1 <- rast(input$var_env)
    r2 <- rast(input$var_soc)
    
    leaflet() %>%
      setView(lng = 13.4, lat = 52.52, zoom = 11)%>%
      addTiles() %>%
      addRasterImage(
        raster(combined_id_raster(r1,r2)),
        color= add_colors_to_map(r1, r2),
        opacity = 0.7)
  })
  
  
  # -----------------------------
  # 2.3.2 VALUE BOX TEXT
  # -----------------------------
  
  value_box_text <- c(
    "data/no2_2024_aligned.tif"  = "Nitrogen dioxide (NO₂) concentration in µg/m³.",
    "data/2_b_pollutant_grid_avg_pm10_2024.tiff" = "Particulate matter <10 µm (PM10).",
    "data/2_c_pollutant_grid_avg_pm2_5_2024.tiff" = "Fine particulate matter <2.5 µm (PM2.5).",
    "data/laerm.tif"        = "Average environmental noise exposure.",
    "data/gesix_berlin.tiff" = "(GESIx)"
  )
  
  
  output$dataset_name <- renderUI({
    tagList(
      tags$p(value_box_text[input$var_env]),
      tags$p(value_box_text[input$var_soc])
    )
  })
  
  
  # -----------------------------
  # 2.3.3 PLOT COLORSCALE
  # -----------------------------
  source("colormap.R")
  
  lab_names = c(
    "data/no2_2024_aligned.tif"= "NO₂",
    "data/2_b_pollutant_grid_avg_pm10_2024.tiff"= "PM10",
    "data/2_c_pollutant_grid_avg_pm2_5_2024.tiff"="PM2.5",
    "data/laerm.tif"= "Noise pollution"
  )
  
  output$colormap <- renderPlot({
    r1 <- rast(input$var_env)
    r2 <- rast(input$var_soc)
    
    # Plot erzeugen
    p <- create_colormap(r1, r2)
    x_lab <- lab_names[input$var_env]
    y_lab <- lab_names[input$var_soc]
    
    plot<- ggplot(p, aes(df1, df2, fill = color)) +
      geom_tile() +
      scale_fill_identity() +
      labs(
        x = x_lab,
        y = y_lab
      )+
      theme_minimal()+
      theme(
        axis.title.x = element_text(size = 35),
        axis.title.y = element_text(size = 35),
        axis.text.x  = element_text(size = 30),
        axis.text.y  = element_text(size = 30),
        plot.title   = element_text(size = 30,  hjust = 0)
      )
    print(plot) 
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

