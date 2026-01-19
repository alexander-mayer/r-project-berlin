#we use this script to experiment with our data

rm(list=ls()) #clean working environment
print(getwd()) #check if WD is correctly set to source file location

#Install & load libraries
packages <- c("leaflet", "sf","terra")
new_pkgs <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_pkgs)) install.packages(new_pkgs)
lapply(packages, library, character.only = TRUE)

#-----------------------------
#TESTING
#-----------------------------
#vector of our file names
#Hardcoding these works for now, but should be created dynamically in the future
files <- c("data/1_gssa_gesix2022.tiff", #Gesundheits- und Sozialindex 2022 (GESIx)
           "data/2_a_pollutant_grid_avg_no2_2024.tiff", #NO2 – Stickstoffdioxid in µg/m³ 2024
           "data/2_b_pollutant_grid_avg_pm10_2024.tiff", #PM10 – Partikel < 10 µm in µg/m³ 2024
           "data/2_c_pollutant_grid_avg_pm2_5_2024.tiff" #PM2,5 – Partikel < 2,5 µm in µg/m³ 2024
           #"data/3_b_09_01_1UGlaerm2021.tiff", #Kernindikator Lärmbelastung
           #"data/3_c_09_01_2UGluft2021.tiff", #Kernindikator Luftbelastung
           #"data/3_d_09_01_3UGgruen2021.tiff", #Kernindikator Grünversorgung
           #"data/3_e_09_01_4UGbioklima2021.tiff", #Kernindikator Thermische Belastung
           #"data/3_f_09_01_5UGsozial2021.tiff", #Kernindikator Soziale Benachteiligung
           #"data/3_g_09_01_6UGmehrfach4_2021.tiff", #Integrierte Mehrfachbelastungskarte Umwelt
           #"data/3_h_09_01_7UGmehrfach5_2021.tiff" #Integrierte Mehrfachbelastungskarte Umwelt und Soziale Benachteiligung
            )
# Load all TIFFs
r_stack <- rast(files)
ext(r_stack) <- ext(369950, 415850, 5799450, 5837300)
crs(r_stack) <- "EPSG:32633"

#GPKGs
gpkg_files <- c("data/1_b_09_01_1UGlaerm2021.gpkg", #Kernindikator Lärmbelastung
  "data/1_c_09_01_2UGluft2021.gpkg", #Kernindikator Luftbelastung
  "data/1_d_09_01_3UGgruen2021.gpkg", #Kernindikator Grünversorgung
  "data/1_e_09_01_4UGbioklima2021.gpkg", #Kernindikator Thermische Belastung
  "data/1_f_09_01_5UGsozial2021.gpkg" #Kernindikator Soziale Benachteiligung
)
layer_names <- c("Lärmbelastung", "Luftbelastung", "Grünversorgung", "Thermische Belastung",
                 "Soziale Benachteiligung")

#temporary, to see if it works

leaflet() %>% 
  setView(lng = 13.4, lat = 52.5, zoom = 11) %>%
  addTiles() %>%
  addRasterImage(r_stack)

#Try reading a value
p <- vect(
  cbind(405950, 5807300),
  type = "points",
  crs = "EPSG:32633"
)
extract(r_stack, p)


#More testing
# ------------------------------------------------------------------
# 2. Read GeoPackages (EPSG:32633)
# ------------------------------------------------------------------
gpkgs_32633 <- vector("list", length(gpkg_files))

for (i in seq_along(gpkg_files)) {
  gpkgs_32633[[i]] <- st_read(gpkg_files[i], quiet = TRUE)
}

# ------------------------------------------------------------------
# 3. Transform for Leaflet (EPSG:4326)
# ------------------------------------------------------------------
gpkgs_ll <- vector("list", length(gpkg_files))

for (i in seq_along(gpkgs_32633)) {
  gpkgs_ll[[i]] <- st_transform(gpkgs_32633[[i]], 4326)
}

# ------------------------------------------------------------------
# 4. Define popup content
#    (adjust field names if needed)
# ------------------------------------------------------------------
make_popup <- function(x) {
  paste0(
    "<b>Noise level (Lden):</b> ", x$L_DEN, " dB<br>",
    "<b>Source:</b> ", x$QUELLE
  )
}

# ------------------------------------------------------------------
# 5. Build Leaflet map
# ------------------------------------------------------------------
m <- leaflet() |>
  addProviderTiles(providers$CartoDB.Positron)

for (i in seq_along(gpkgs_ll)) {
  m <- m |>
    addPolygons(
      data = gpkgs_ll[[i]],
      group = layer_names[i],
      fillOpacity = 0.6,
      weight = 0.4,
      color = "#333333",
      popup = make_popup(gpkgs_ll[[i]]),
      highlightOptions = highlightOptions(
        weight = 2,
        color = "#000000",
        bringToFront = TRUE
      )
    )
}

# ------------------------------------------------------------------
# 6. Layer control
# ------------------------------------------------------------------
m |>
  addLayersControl(
    overlayGroups = layer_names,
    options = layersControlOptions(collapsed = FALSE)
  )