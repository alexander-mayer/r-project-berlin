#we use this script to experiment with our data

rm(list=ls()) #clean working environment

#Install & load libraries
packages <- c("leaflet")
new_pkgs <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_pkgs)) install.packages(new_pkgs)
lapply(packages, library, character.only = TRUE)

#-----------------------------
#TESTING
#-----------------------------
# Load image
img_png <- rast("data/no2.png")
ext(img_png) <- ext(369950, 415850, 5799450, 5837300)
crs(img_png) <- "EPSG:32633"

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
