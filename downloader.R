#we use this script to download our WFS data
#possibly convert it as well?

#Install & load libraries
packages <- c("sf", "httr", "tidyverse", "lubridate", "ows4R", "leaflet")
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
#2 - Air Pollution
#https://daten.berlin.de/datensaetze/durchschnittliche-jahrliche-luftschadstoffbelastung-modelldaten-umweltatlas-wms-d38aed69
wms_air <- "https://gdi.berlin.de/services/wms/ua_luftschadstoffbelastung?REQUEST=GetCapabilities&SERVICE=wms"
#3 - Noise Pollution
#https://daten.berlin.de/datensaetze/umweltgerechtigkeit-2021-2022-umweltatlas-wms-87f1aaf7
wms_noise <- "https://gdi.berlin.de/services/wms/ua_umweltgerechtigkeit_2021?REQUEST=GetCapabilities&SERVICE=wms"

#temporary, to see if it works
leaflet() %>% 
  setView(lng = 13.4, lat = 52.5, zoom = 11) %>%
  addWMSTiles(
    wms_air,
    layers = "a_pollutant_grid_avg_no2_2024",
    options = WMSTileOptions(format = "image/png", transparent = TRUE)
  )