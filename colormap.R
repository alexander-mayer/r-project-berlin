library(ggplot2)
library(viridis)

#filter categories + lenght for 2D-Colormatrix
cat1 <- unique(df1$yourColumn)
cat2 <- unique(df2$yourColumn) 

n1 <- length(cat1)
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
  df1 = cats1,
  df2 = cats2
)

cm_df$color <- as.vector(color_matrix)

color_matrix <- ggplot(cm_df, aes(df1, df2, fill = color)) +
  geom_tile() +
  scale_fill_identity() +
  labs(
    x = paste0(name(var_env)),
    y = paste0 (name(var_soc))
  )
theme_minimal()





