#we use this script to download our WMS data

rm(list=ls()) #clean working environment
print(getwd()) #check if WD is correctly set to source file location

#Install & load libraries
packages <- c("terra")
new_pkgs <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_pkgs)) install.packages(new_pkgs)
lapply(packages, library, character.only = TRUE)

#terra - raster data

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
#-----------------------------
#SAVING
#-----------------------------

#WMS variables
wms_crs <- "EPSG:32633&"
#wms_bbox <- "bbox=369950,5799450,415850,5837300&"
wms_bbox <- "bbox=369950,415850,5799450,5837300&"
wms_width <- "width=1000&"
wms_height <- "height=1000&"
wms_format <- "format=image%2Fgeotiff"

#health
for (layer in layers_health){
  wms_url <- sub("GetCapabilities", "GetMap&version=1.3.0", wms_health) #modify WMS URL
  url_tiff = paste(wms_url,"&layers=",layer,"&styles=&crs=",wms_crs,wms_bbox,wms_height,wms_width,wms_format, sep="")
  download.file(url_tiff, paste("data/1_",layer, ".tiff", sep=""), mode = "wb")
}

#air
for (layer in layers_air){
  wms_url <- sub("GetCapabilities", "GetMap&version=1.3.0", wms_air) #modify WMS URL
  url_tiff = paste(wms_url,"&layers=",layer,"&styles=&crs=",wms_crs,wms_bbox,wms_height,wms_width,wms_format, sep="")
  download.file(url_tiff, paste("data/2_",layer, ".tiff", sep=""), mode = "wb")
}