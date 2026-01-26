#the next step in our data pipeline - cleaning and transforming
#Currently this file contains a lot of redundant code
#Should be improved for future use

rm(list=ls()) #clean working environment
print(getwd()) #check if WD is correctly set to source file location

#Install & load libraries
packages <- c("terra", "sf", "dplyr")
new_pkgs <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_pkgs)) install.packages(new_pkgs)
lapply(packages, library, character.only = TRUE)

#Load data
gssa <- st_read("data/1_gssa.gpkg")
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
gssa <- laerm %>% filter(unbewofl != "ja" | is.na(unbewofl))
laerm <- laerm %>% filter(unbewofl != "ja" | is.na(unbewofl))
luft <- luft %>% filter(unbewofl != "ja" | is.na(unbewofl))
gruen <- gruen %>% filter(unbewofl != "ja" | is.na(unbewofl))
bio <- bio %>% filter(unbewofl != "ja" | is.na(unbewofl))
sozial <- sozial %>% filter(unbewofl != "ja" | is.na(unbewofl))

#For finding out the categories
sozial %>%
  st_drop_geometry() %>%
  distinct(ekategorie)

#Clean up data
#TODO

#Next step: Encoding as numerical data
bio$ekategorie_num <- dplyr::recode(
  bio$ekategorie,
  "NA" = 0,
  "low"   = 1,
  "medium" = 2,
  "high"   = 3
)

gruen$ekategorie_num <- dplyr::recode(
  gruen$ekategorie,
  "NA" = 0,
  "poor"   = 1,
  "medium" = 2,
  "good"   = 3
)

gssa$ekategorie_num <- dplyr::recode(
  gssa$ekategorie,
  "NA" = 0,
  "low"   = 1,
  "medium" = 2,
  "high"   = 3
)

laerm$ekategorie_num <- dplyr::recode(
  laerm$ekategorie,
  "NA" = 0,
  "low"   = 1,
  "medium" = 2,
  "high"   = 3
)

luft$ekategorie_num <- dplyr::recode(
  luft$ekategorie,
  "NA" = 0,
  "low"   = 1,
  "medium" = 2,
  "high"   = 3
)

sozial$ekategorie_num <- dplyr::recode(
  sozial$ekategorie,
  "NA" = 0,
  "low, very low Status index"   = 1,
  "mean Status index" = 2,
  "high Status index"   = 3
)

bio_v <- vect(bio)
gruen_v <- vect(gruen)
gssa_v <- vect(gssa)
laerm_v <- vect(laerm)
luft_v <- vect(luft)
sozial_v <- vect(sozial)

#Use this template for all conversions
#We set the raster size for all layers here!
r_template <- rast(
  ext(laerm_v),
  resolution = 100,
  crs = target_crs
)

#Rasterize and assign the categorical values back
#bio#######################
bio_raster <- rasterize(
  bio_v,
  r_template,
  field = "ekategorie_num"
)

levels(bio_raster) <- data.frame(
  value = c(1, 2, 3),
  label = c("low", "medium", "high")
)

writeRaster(
  bio_raster,
  "data/R_bio.tif",
  overwrite = TRUE
)

#gruen#######################
gruen_raster <- rasterize(
  gruen_v,
  r_template,
  field = "ekategorie_num"
)

levels(gruen_raster) <- data.frame(
  value = c(1, 2, 3),
  label = c("low", "medium", "high")
)

writeRaster(
  gruen_raster,
  "data/R_gruen.tif",
  overwrite = TRUE
)

#gssa#######################
gssa_raster <- rasterize(
  gssa_v,
  r_template,
  field = "ekategorie_num"
)

levels(gssa_raster) <- data.frame(
  value = c(1, 2, 3),
  label = c("low", "medium", "high")
)

writeRaster(
  gssa_raster,
  "data/R_gssa.tif",
  overwrite = TRUE
)

#laerm#######################
laerm_raster <- rasterize(
  laerm_v,
  r_template,
  field = "ekategorie_num"
)

levels(laerm_raster) <- data.frame(
  value = c(1, 2, 3),
  label = c("low", "medium", "high")
)

writeRaster(
  laerm_raster,
  "data/R_laerm.tif",
  overwrite = TRUE
)

#luft#######################
luft_raster <- rasterize(
  luft_v,
  r_template,
  field = "ekategorie_num"
)

levels(luft_raster) <- data.frame(
  value = c(1, 2, 3),
  label = c("low", "medium", "high")
)

writeRaster(
  luft_raster,
  "data/R_luft.tif",
  overwrite = TRUE
)

#sozial#######################
sozial_raster <- rasterize(
  sozial_v,
  r_template,
  field = "ekategorie_num"
)

levels(sozial_raster) <- data.frame(
  value = c(1, 2, 3),
  label = c("low", "medium", "high")
)

writeRaster(
  sozial_raster,
  "data/R_sozial.tif",
  overwrite = TRUE
)

#Now we load, correct and reproject our existing rasters
#TODO: NAs are currently not handled well

#No2 has 5 levels. We want to reclassify and merge the middle 3
rcl <- matrix(
  c(1, 1,
    2, 2,
    3, 2,
    4, 2,
    5, 3),
  ncol = 2,
  byrow = TRUE
)

no2 <- rast("data/2_a_pollutant_grid_avg_no2_2024.tiff") %>%
  project(laerm_raster,
          method = "near", mask = TRUE
  ) %>% crop(laerm_raster)
no2 <- classify(no2, rcl)

pm2_5 <- rast("data/2_c_pollutant_grid_avg_pm2_5_2024.tiff") %>%
  project(laerm_raster,
          method = "near", mask = TRUE
  ) %>% crop(laerm_raster)

pm10 <- rast("data/2_b_pollutant_grid_avg_pm10_2024.tiff") %>%
  project(laerm_raster,
          method = "near", mask = TRUE
  ) %>% crop(laerm_raster)

writeRaster(
  no2,
  "data/R_NO2.tif",
  filetype = "GTiff",
  overwrite = TRUE
)

writeRaster(
  pm10,
  "data/R_PM10.tif",
  filetype = "GTiff",
  overwrite = TRUE
)

writeRaster(
  pm2_5,
  "data/R_PM2_5.tif",
  filetype = "GTiff",
  overwrite = TRUE
)

