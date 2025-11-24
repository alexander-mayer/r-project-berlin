#we use this script to download our WFS data
#possibly convert it as well?

rm(list=ls()) #clean working environment

#Install & load libraries
#packages <- c("sf", "httr", "tidyverse", "lubridate", "ows4R", "leaflet")
packages <- c("terra", "leaflet")
new_pkgs <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_pkgs)) install.packages(new_pkgs)
lapply(packages, library, character.only = TRUE)

#sf - simple features packages for handling vector GIS data
#httr - generic webservice package
#tidyverse - a suite of packages for data wrangling, transformation, plotting, ...
#ows4R - interface for OGC webservices
#leaflet - interactive visualisation. We use this to test view the WMS data


#https://tutorials.inbo.be/tutorials/spatial_wfs_services/
#https://tutorials.inbo.be/tutorials/spatial_wms_services/
#https://andyarthur.org/how-to-access-wms-servers-in-r-programming-language.html


#-----------------------------
#DATA
#-----------------------------
#1 - Health and Social Factors
#https://daten.berlin.de/datensaetze/gesundheits-und-sozialstrukturatlas-gesundheits-und-sozialindex-2022-gesix-wms-44ab83fa
wms_health <- "https://gdi.berlin.de/services/wms/gssa_gesix2022?REQUEST=GetCapabilities&SERVICE=wms"
layers_health <- c("gssa_gesix2022") #Gesundheits- und Sozialindex 2022 (GESIx)
#2 - Air Pollution
#https://daten.berlin.de/datensaetze/durchschnittliche-jahrliche-luftschadstoffbelastung-modelldaten-umweltatlas-wms-d38aed69
wms_air <- "https://gdi.berlin.de/services/wms/ua_luftschadstoffbelastung?REQUEST=GetCapabilities&SERVICE=wms"
layers_air <- c("a_pollutant_grid_avg_no2_2024", #NO2 – Stickstoffdioxid in µg/m³ 2024
                "b_pollutant_grid_avg_pm10_2024", #PM10 – Partikel < 10 µm in µg/m³ 2024
                "c_pollutant_grid_avg_pm2_5_2024") #PM2,5 – Partikel < 2,5 µm in µg/m³ 2024
#3 - Noise Pollution
#https://daten.berlin.de/datensaetze/umweltgerechtigkeit-2021-2022-umweltatlas-wms-87f1aaf7
wms_noise <- "https://gdi.berlin.de/services/wms/ua_umweltgerechtigkeit_2021?REQUEST=GetCapabilities&SERVICE=wms"
layers_noise <- c("b_09_01_1UGlaerm2021", #Kernindikator Lärmbelastung
                 "c_09_01_2UGluft2021", #Kernindikator Luftbelastung
                 "d_09_01_3UGgruen2021", #Kernindikator Grünversorung
                 "e_09_01_4UGbioklima2021", #Kernindikator Thermische Belastung
                 "f_09_01_5UGsozial2021", #Kernindikator Soziale Benachteiligung
                 "g_09_01_6UGmehrfach4_2021", #Integrierte Mehrfachbelastungskarte Umwelt
                 "h_09_01_7UGmehrfach5_2021") #Integrierte Mehrfachbelastungskarte Umwelt und Soziale Benachteiligung

#-----------------------------
#SAVING
#-----------------------------

#WMS is online and can break, we want offline files


#Example WMS-Request, we try to get a PNG and probably need to georeference it again
url_png="https://gdi.berlin.de/services/wms/ua_luftschadstoffbelastung?service=WMS&version=1.3.0&request=GetMap&layers=a_pollutant_grid_avg_no2_2024&styles=&crs=EPSG:32633&bbox=369950,5799450,415850,5837300&width=500&height=500&format=image%2Fpng"
url_tiff="https://gdi.berlin.de/services/wms/ua_luftschadstoffbelastung?service=WMS&version=1.3.0&request=GetMap&layers=a_pollutant_grid_avg_no2_2024&styles=&crs=EPSG:32633&bbox=369950,5799450,415850,5837300&width=1000&height=1000&format=image%2Fgeotiff"
download.file(url_png, "data/no2.png", mode = "wb") #change this as needed

#TODO: Write code to build the request URLs

#-----------------------------
# Load image
img_png <- rast("data/no2.png")
ext(img_png) <- ext(369950, 415850, 5799450, 5837300)
crs(img_png) <- "EPSG:32633"

img_tiff <- rast("data/no2.tiff")

#-----------------------------
#TESTING
#-----------------------------

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
