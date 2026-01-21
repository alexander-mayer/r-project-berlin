#the next step in our data pipeline - cleaning and transforming

rm(list=ls()) #clean working environment
print(getwd()) #check if WD is correctly set to source file location

#Install & load libraries
packages <- c("terra", "sf", "dplyr")
new_pkgs <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_pkgs)) install.packages(new_pkgs)
lapply(packages, library, character.only = TRUE)

#Load data
laerm <- st_read("data/3_b_09_01_1UGlaerm2021.gpkg")
luft <- st_read("data/3_c_09_01_2UGluft2021.gpkg")
gruen <- st_read("data/3_d_09_01_3UGgruen2021.gpkg")
bio <- st_read("data/3_e_09_01_4UGbioklima2021.gpkg")
sozial <- st_read("data/3_f_09_01_5UGsozial2021.gpkg")

#All vectors are in UTM33N
st_crs(laerm) <- "EPSG: 25833"
target_crs <- "EPSG: 25833"

#All layers have the same attributes:
names(laerm)

#The data contains two types of polygons:
#Three mutually exclusive ratings, i.e. high/mid/low
#And uninhabitated spaces, where unbewofl = "ja". We want to drop those, as it intersects the others
laerm <- laerm %>% filter(unbewofl != "ja" | is.na(unbewofl))
luft <- luft %>% filter(unbewofl != "ja" | is.na(unbewofl))
gruen <- gruen %>% filter(unbewofl != "ja" | is.na(unbewofl))
bio <- bio %>% filter(unbewofl != "ja" | is.na(unbewofl))
sozial <- sozial %>% filter(unbewofl != "ja" | is.na(unbewofl))

laerm %>%
  st_drop_geometry() %>%
  distinct(ekategorie)



#Clean up data

#Either normalise or get min/max values from all layers

laerm$ekategorie_num <- dplyr::recode(
  laerm$ekategorie,
  "NA" = 0,
  "low"   = 1,
  "medium" = 2,
  "high"   = 3
)

laerm_v <- vect(laerm)

#Use this template for all conversions
r_template <- rast(
  ext(laerm_v),
  resolution = 50,
  crs = target_crs
)

laerm_raster <- rasterize(
  laerm_v,
  r_template,
  field = "ekategorie_num"
)

writeRaster(
  laerm_raster,
  "data/laerm.tif",
  overwrite = TRUE
)



#Now we load, correct and reproject our existing rasters
no2 <- rast("data/2_a_pollutant_grid_avg_no2_2024.tiff")
no2 <- project(
  no2,
  laerm_raster,
  method = "bilinear"   # use "near" if NO2 were categorical
)
no2 <- crop(no2, laerm_raster)
compareGeom(laerm_raster, no2, stopOnError = FALSE)

library(terra)

writeRaster(
  no2,
  "data/no2_2024_aligned.tif",
  filetype = "GTiff",
  overwrite = TRUE
)

