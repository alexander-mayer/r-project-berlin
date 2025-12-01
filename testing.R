#we use this script to experiment with our data

rm(list=ls()) #clean working environment
print(getwd()) #check if WD is correctly set to source file location

#Install & load libraries
packages <- c("leaflet", "sf")
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
           "data/2_c_pollutant_grid_avg_pm2_5_2024.tiff", #PM2,5 – Partikel < 2,5 µm in µg/m³ 2024
           "data/3_b_09_01_1UGlaerm2021.tiff", #Kernindikator Lärmbelastung
           "data/3_c_09_01_2UGluft2021.tiff", #Kernindikator Luftbelastung
           "data/3_d_09_01_3UGgruen2021.tiff", #Kernindikator Grünversorgung
           "data/3_e_09_01_4UGbioklima2021.tiff", #Kernindikator Thermische Belastung
           "data/3_f_09_01_5UGsozial2021.tiff", #Kernindikator Soziale Benachteiligung
           "data/3_g_09_01_6UGmehrfach4_2021.tiff", #Integrierte Mehrfachbelastungskarte Umwelt
           "data/3_h_09_01_7UGmehrfach5_2021.tiff") #Integrierte Mehrfachbelastungskarte Umwelt und Soziale Benachteiligung

# Load all TIFFs
r_stack <- rast(files)
ext(r_stack) <- ext(369950, 415850, 5799450, 5837300)
crs(r_stack) <- "EPSG:32633"

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
