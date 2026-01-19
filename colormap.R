library(ggplot2)
library(viridis)


#Dummy df
df <- data.frame(
  df1 = c(1, 2, 4, 1, 5, 3),
  df2 = c(1, 3, 2, 3, 1, 2)
)


# Kategorien bestimmen
cats1 <- seq(min(df$df1), max(df$df1))
cats2 <- seq(min(df$df2), max(df$df2))

n1 <- length(cats1)
n2 <- length(cats2)


##COLORMAP
# 1D-Farbskala (für Kombinationen)
vir_cols <- viridis(n1 * n2)

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

cm_df$color <- as.vector(color_matrix)

ggplot(cm_df, aes(df1, df2, fill = color)) +
  geom_tile() +
  scale_fill_identity() +
  theme_minimal() +
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


