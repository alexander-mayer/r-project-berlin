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
#https://daten.berlin.de/datensaetze/umweltgerechtigkeit-2021-2022-umweltatlas-wms-87f1aaf7
#https://www.berlin.de/umweltatlas/mensch/umweltgerechtigkeit/2022/methode/
wfs_env <- "https://gdi.berlin.de/services/wfs/ua_umweltgerechtigkeit_2021?SERVICE=wfs&REQUEST=GetCapabilities"
layers_env <- c("b_09_01_1UGlaerm2021", #Kernindikator Lärmbelastung
                 "c_09_01_2UGluft2021", #Kernindikator Luftbelastung
                 "d_09_01_3UGgruen2021", #Kernindikator Grünversorung
                 "e_09_01_4UGbioklima2021", #Kernindikator Thermische Belastung
                 "f_09_01_5UGsozial2021", #Kernindikator Soziale Benachteiligung
                 "g_09_01_6UGmehrfach4_2021", #Integrierte Mehrfachbelastungskarte Umwelt
                 "h_09_01_7UGmehrfach5_2021") #Integrierte Mehrfachbelastungskarte Umwelt und Soziale Benachteiligung
#-----------------------------
#SAVING
#-----------------------------

#WFS variables
wfs_crs <- "&srsName=EPSG:32633&"
#wfs_bbox <- "bbox=369950,5799450,415850,5837300&"
#wms_width <- "width=1000&"
#wms_height <- "height=1000&"
wfs_format <- "outputFormat=geopkg"

for (layer in layers_env){
  wms_url <- sub("REQUEST=GetCapabilities", "version=2.0.0&request=GetFeature", wfs_env) #modify WfS URL
  url_gp = paste(wms_url,"&typeNames=ua__umweltgerechtigkeit_2021%3A",layer,wfs_crs,wfs_format, sep="")
  download.file(url_gp, paste("data/1_",layer, ".gpkg", sep=""), mode = "wb")
}