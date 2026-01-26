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

ids <- c("NO2", "PM10", "PM2_5", "laerm", "gruen", "soz_benachteiligung", "GESi")

raster_files <- c(
  NO2 = "data/R_NO2.tif",
  PM10 = "data/R_PM10.tif",
  PM2_5 = "data/R_PM2_5.tif",
  laerm = "data/R_laerm.tif",
  gruen = "data/R_gruen.tif",
  soz_benachteiligung = "data/R_sozial.tif",
  GESi = "data/R_gssa.tif"
)

lab_names = c(
  gruen = "Green spaces",
  GESi = "GESi",
  laerm = "Noise exposure",
  NO2 = "NO₂",
  PM2_5 = "PM2.5",
  PM10 = "PM10",
  soz_benachteiligung = "Social disadvantage"
)

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
        choices = setNames(ids, lab_names[ids])
      )
    ),

    card(
      card_header("Factor 2"),
      selectInput(
        inputId = "var_soc",
        label = "Select option",
        choices = setNames(ids, lab_names[ids])
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
          title = "Spearman correlation coefficient:",
          value = tagList(
            uiOutput("spearman_correlation")
            #uiOutput("dataset_name")
          ),
          theme = "teal"
        ),
        
        card(
          card_header("Color scale"),
          card_body(plotOutput("colormap"))
        )
      ),
      
      
      layout_columns(
        col_widths = c(6,6),
        plotOutput("hist_factor2"),
        plotOutput("hist_factor1")
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
    #req(input$var_env)
    #validate(need(file.exists(input$var_env), "Raster file not found."))
    
    
    
    r <- rast(raster_files[input$var_env])
    
    # Set CRS if not available
    if (is.na(crs(r))) crs(r) <- "EPSG:25833"
    
    # Project raster to WGS84 for Leaflet
    r_proj <- project(r, "EPSG:4326")
    
    r_proj
  })
  
  # Social raster
  soc_raster <- reactive({
    r <- rast(raster_files[input$var_soc])
    if (is.na(crs(r))) crs(r) <- "EPSG:25833"
    r_proj <- project(r, "EPSG:4326")  # Leaflet-compatible
    r_proj
  })

  # -----------------------------
  # 2.2 nav_panel INFO (Info on datasets)
  # -----------------------------
  env_text <- c(
    gruen = "Green spaces: This indicator is based on the 2020 Green Provision Analysis and aggregates block-level urgency ratings to planning areas using population-weighting and considering only available green space and population size.",
    GESi = "GESI: The Health and Social Index (GESIx) is derived from 20 indicators covering employment, social status and health at the planning area level for Berlin (2022).",
    laerm = "Noise pollution: The noise exposure dataset is based on Berlin’s 2017 Strategic Noise Maps and provides a population-weighted assessment of nighttime traffic noise (22:00–06:00) for planning areas.",
    NO2 = "Nitrogen dioxide (NO₂): This is the annual mean NO₂ concentration in µg/m³ presented on a 50 × 50 meter grid across the Berlin metropolitan area.",
    PM2_5 = "Fine particulate matter <2.5 µm (PM2.5): This is the annual mean PM2.5 concentration in µg/m³ presented on a 50 × 50 meter grid across the Berlin metropolitan area.",
    PM10 = "Particulate matter <10 µm (PM10): This is the annual mean PM10 concentration in µg/m³ presented on a 50 × 50 meter grid across the Berlin metropolitan area.",
    soz_benachteiligung = "Social disadvantage: This indicator is based on the 2021 results of Berlin’s citywide Monitoring of Social Urban Development (MSS) and assesses the social status and dynamics of planning areas using indices on unemployment, welfare dependency among non-employed persons, and child poverty"
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
    r1 <- rast(raster_files[input$var_env])
    r2 <- rast(raster_files[input$var_soc])
    
    leaflet() %>%
      setView(lng = 13.4, lat = 52.52, zoom = 10.4)%>%
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
    gruen = "green spaces",
    GESi = "GESi",
    laerm = "Noise exposure.",
    NO2 = "NO₂",
    PM2_5 = "PM2.5",
    PM10 = "PM10",
    soz_benachteiligung = "social disadvantage measured by the factors..."
  )
  
  output$spearman_correlation <- renderUI({
    r1 <- rast(raster_files[input$var_env])
    r2 <- rast(raster_files[input$var_soc])
    
    
    # Extract values and use only cells that are not NA in both rasters
    env_vals <- values(r1)
    soc_vals <- values(r2)
    
    valid <- !is.na(env_vals) & !is.na(soc_vals)
    env_vals <- env_vals[valid]
    soc_vals <- soc_vals[valid]
    
    
    cor<- round(cor(env_vals, soc_vals, method = "spearman"),2)
    
    
  })
  
 # output$dataset_name <- renderUI({
  #  tagList(
   #   tags$p(value_box_text[input$var_env]),
    #  tags$p(value_box_text[input$var_soc])
    #)
  #})
  
  
  # -----------------------------
  # 2.3.3 PLOT COLORSCALE
  # -----------------------------
  source("colormap.R")
  
  output$colormap <- renderPlot({
    r1 <- rast(raster_files[input$var_env])
    r2 <- rast(raster_files[input$var_soc])
    
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
  # 2.3.4 frequency plots
  # -----------------------------
  
  output$hist_factor1 <- renderPlot({
    r1 <- rast(raster_files[input$var_env])
    f<-freq(r1)
    barplot(
      f$count,
      names.arg = f$value,
      xlab = "Category",
      ylab = "Frequency",
      main = lab_names[input$var_env]
    )
  })
  
  
  output$hist_factor2 <- renderPlot({
    r1 <- rast(raster_files[input$var_soc])
    f<-freq(r1)
    barplot(
      f$count,
      names.arg = f$value,
      xlab = "Category",
      ylab = "Frequency",
      main = lab_names[input$var_soc]
    )
  })
  

  
  # -----------------------------
  # 2.4 REACTIVE RASTER OVERLAY
  # -----------------------------
 #observeEvent(env_raster(), {
    
    # Color scale automatically based on raster values
  #  pal <- colorNumeric("viridis", values(env_raster()), na.color = "transparent")
   # 
    #leafletProxy("map") %>%
     # clearImages() %>%
      #addRasterImage(
       # env_raster(),
        #colors = pal,
        #opacity = 0.7
      #) %>%
      #addLegend(
      #  pal = pal,
       # values = values(env_raster()),
        #title = "Raster values",
        #position = "bottomright"
      #)
  #})
  
}

#############################
# 3. RUN THE APP
#############################
shinyApp(ui = ui, server = server)

