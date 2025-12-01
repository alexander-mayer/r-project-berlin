#we use this script to experiment with our data

rm(list=ls()) #clean working environment
print(getwd()) #check if WD is correctly set to source file location

#Install & load libraries
packages <- c("leaflet")
new_pkgs <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_pkgs)) install.packages(new_pkgs)
lapply(packages, library, character.only = TRUE)

#-----------------------------
#TESTING
#-----------------------------
# Load all TIFFs
tiff_health <- rast("data/1_gssa_gesix2022.tiff") #Gesundheits- und Sozialindex 2022 (GESIx)
tiff_air_no2 <- rast("data/2_a_pollutant_grid_avg_no2_2024.tiff") #NO2 – Stickstoffdioxid in µg/m³ 2024
tiff_air_pm2.5 <- rast("data/2_c_pollutant_grid_avg_pm2_5_2024.tiff") #PM2,5 – Partikel < 2,5 µm in µg/m³ 2024
tiff_air_pm10 <- rast("data/2_b_pollutant_grid_avg_pm10_2024.tiff") #PM10 – Partikel < 10 µm in µg/m³ 2024
tiff_justice_noise <- rast("data/3_b_09_01_1UGlaerm2021.tiff") #Kernindikator Lärmbelastung
tiff_justice_air <- rast("data/3_c_09_01_2UGluft2021.tiff") #Kernindikator Luftbelastung
tiff_justice_green <- rast("data/3_d_09_01_3UGgruen2021.tiff") #Kernindikator Grünversorgung
tiff_justice_bio <- rast("data/3_e_09_01_4UGbioklima2021.tiff") #Kernindikator Thermische Belastung
tiff_justice_social <- rast("data/3_f_09_01_5UGsozial2021.tiff") #Kernindikator Soziale Benachteiligung
tiff_justice_multiple4 <- rast("data/3_g_09_01_6UGmehrfach4_2021.tiff")  #Integrierte Mehrfachbelastungskarte Umwelt
tiff_justice_multiple5 <- rast("data/3_h_09_01_7UGmehrfach5_2021.tiff") #Integrierte Mehrfachbelastungskarte Umwelt und Soziale Benachteiligung



#img_png <- rast("data/no2.png")
#ext(img_png) <- ext(369950, 415850, 5799450, 5837300)
#crs(img_png) <- "EPSG:32633"

img_tiff <- rast("data/no2.tiff")

#temporary, to see if it works

leaflet() %>% 
  setView(lng = 13.4, lat = 52.5, zoom = 11) %>%
  addTiles() %>%
  addRasterImage(img_tiff)

#Try reading a value
p <- vect(
  cbind(405950, 5807300),
  type = "points",
  crs = "EPSG:32633"
)
extract(img_png, p)
