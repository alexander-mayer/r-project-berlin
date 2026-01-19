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

gruen %>%
  st_drop_geometry() %>%
  distinct(ekategorie)



#Clean up data

#todo: Remove all entries where unbewofl = "ja"

#Either normalise or get min/max values from all layers


#What to do with raster files? Convert all to raster? All to vector?