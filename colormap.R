library(ggplot2)
library(viridis)
library(terra)

create_colormap<-function (r1, r2){
    #filter categories + lenght for 2D-Colormatrix
  r1_min <- global(r1, "min", na.rm = TRUE)[1,1]
  r1_max <- global(r1, "max", na.rm = TRUE)[1,1]
  
  cat1 <- seq(r1_min, r1_max)
  n1 <- length(cat1)
  
  
  r2_min <- global(r2, "min", na.rm = TRUE)[1,1]
  r2_max <- global(r2, "max", na.rm = TRUE)[1,1]
  
  cat2 <- seq(r2_min, r2_max)
  n2 <- length(cat2)
  
  vir_cols <- viridis(n1 * n2)
  
  # create 2D-Color-Matrix
  color_matrix <- matrix(
    vir_cols,
    nrow = n1,
    ncol = n2,
    byrow = TRUE
  )
  
  rownames(color_matrix) <- cat1
  colnames(color_matrix) <- cat2
  
  
  cm_df <- expand.grid(
    df1 = cat1,
    df2 = cat2
  )
  
  cm_df$color <- as.vector(color_matrix)
  
  cm_df
}


combined_id_raster<- function (r1, r2){
  #filter categories + lenght for 2D-Colormatrix
  r1_min <- global(r1, "min", na.rm = TRUE)[1,1]
  r1_max <- global(r1, "max", na.rm = TRUE)[1,1]
  
  cat1 <- seq(r1_min, r1_max)
  n1 <- length(cat1)
  
  
  r2_min <- global(r2, "min", na.rm = TRUE)[1,1]
  r2_max <- global(r2, "max", na.rm = TRUE)[1,1]
  
  cat2 <- seq(r2_min, r2_max)
  n2 <- length(cat2)
  
  vir_cols <- viridis(n1 * n2)
  
  # create 2D-Color-Matrix
  color_matrix <- matrix(
    vir_cols,
    nrow = n1,
    ncol = n2,
    byrow = TRUE
  )
  
  rownames(color_matrix) <- cat1
  colnames(color_matrix) <- cat2
  
  
  cm_df <- expand.grid(
    df1 = cat1,
    df2 = cat2
  )
  
  cm_df$color <- as.vector(color_matrix)
  
  r1 <- round(r1)
  r2 <- round(r2)
  
  r1 <- as.int(r1)
  r2 <- as.int(r2)
  
  
  combined_raster <- terra::app(
    c(r1, r2),
    fun = function(x) {
      if (any(is.na(x))) return(NA_integer_)
      (x[1] - 1) * n2 + x[2]
    }
  )
}


add_colors_to_map<- function (r1, r2){
  #filter categories + lenght for 2D-Colormatrix
  r1_min <- global(r1, "min", na.rm = TRUE)[1,1]
  r1_max <- global(r1, "max", na.rm = TRUE)[1,1]
  
  cat1 <- seq(r1_min, r1_max)
  n1 <- length(cat1)
  
  
  r2_min <- global(r2, "min", na.rm = TRUE)[1,1]
  r2_max <- global(r2, "max", na.rm = TRUE)[1,1]
  
  cat2 <- seq(r2_min, r2_max)
  n2 <- length(cat2)
  
  vir_cols <- viridis(n1 * n2)
  
  # create 2D-Color-Matrix
  color_matrix <- matrix(
    vir_cols,
    nrow = n1,
    ncol = n2,
    byrow = TRUE
  )
  
  rownames(color_matrix) <- cat1
  colnames(color_matrix) <- cat2
  
  
  cm_df <- expand.grid(
    df1 = cat1,
    df2 = cat2
  )
  
  cm_df$color <- as.vector(color_matrix)
  
  r1 <- round(r1)
  r2 <- round(r2)
  
  r1 <- as.int(r1)
  r2 <- as.int(r2)
  
  
  combined_raster <- terra::app(
    c(r1, r2),
    fun = function(x) {
      if (any(is.na(x))) return(NA_integer_)
      (x[1] - 1) * n2 + x[2]
    }
  )
  
  cols <- as.vector(color_matrix)
}  
  
  #final_map <- plot(
   # combined_id_raster,
    #col = cols,
    #axes = FALSE,
    #main = "Bivariates Raster (2D-Colormap)"
  #)
#}



