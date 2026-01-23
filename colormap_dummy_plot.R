library(ggplot2)
library(viridis)
library(terra)

#Dummy df
df <- data.frame(
  df1 = c(1, 2, 4, 1, 5, 3),
  df2 = c(1, 3, 4,5, 1, 2)
)

#________________________________
#Test cats
#no2<- "data/no2_2024_aligned.tif"
#learm<-"data/laerm.tif"

#r1 <- rast(no2)
#r2 <- rast(learm)
#_______________________________

##evtl müssen mittel, gering o.ä. noch in num. umgewandelt werden
# Kategorien bestimmen
cats1 <- seq(min(df$df1), max(df$df1))
cats2 <- seq(min(df$df2), max(df$df2))

n1 <- length(cats1)
n2 <- length(cats2)


##COLORMAP
# 1D-Farbskala (für Kombinationen)
#vir_cols <- viridis(n1 * n2)
#install.packages("randomcoloR")
library(randomcoloR)


vir_cols <- distinctColorPalette(n1*n2)


# 2D Color-Matrix
color_matrix <- matrix(
  vir_cols,
  nrow = n1,
  ncol = n2,
  byrow = TRUE
)

rownames(color_matrix) <- cats1
colnames(color_matrix) <- cats2




cm_df <- expand.grid(
  df1 = cats1,
  df2 = cats2
)


x_col <- viridis(n1)[as.numeric(cut(cm_df$df1, n1))]
y_col <- plasma(n2)[as.numeric(cut(cm_df$df2, n2))]

# 2. Kombiniere Farben in RGB
rgb_col <- rgb(
  col2rgb(x_col)[1,]/255,  # R von x_col
  col2rgb(y_col)[2,]/255,  # G von y_col
  col2rgb(y_col)[3,]/255   # B von y_col
)

cm_df$color <- rgb_col
#cm_df$color <- as.vector(color_matrix)

ggplot(cm_df, aes(df1, df2, fill = color)) +
  geom_tile() +
  scale_fill_identity() +
  theme_minimal() +
  theme(
    axis.title.x = element_text(size = 35),
    axis.title.y = element_text(size = 35),
    axis.text.x  = element_text(size = 30),
    axis.text.y  = element_text(size = 30),
    plot.title   = element_text(size = 30,  hjust = 0)
  )+
  labs(title = "Viridis Color Matrix")




#Dummy Plot
df$color <- mapply(
  function(a, b) color_matrix[as.character(a), as.character(b)],
  df$df1,
  df$df2
)

plot(
  seq_len(nrow(df)),
  df$df1,
  col = df$color,
  pch = 16,
  cex = 1.5,
  xlab = "Index",
  ylab = "df1"
)

