### --- LIBRERIE --- ###
library(terra)
library(sf)
library(dplyr)
library(openxlsx)

### --- CARICAMENTO BUFFER --- ###
buffer_files <- list(
"5km" = "buffer_5KM.shp",
"10km" = "buffer_10KM.shp",
"20km" = "buffer_20KM.shp"
)

buffers <- lapply(buffer_files, vect)

### --- GENERAZIONE PUNTI RANDOM --- ###
set.seed(123)

n_punti <- c(
"5km" = 1000,
"10km" = 5000,
"20km" = 10000
)

punti_random <- mapply(
function(buffer, n) spatSample(buffer, size = n, method = "random"),
buffers,
n_punti,
SIMPLIFY = FALSE
)

### --- CARICAMENTO RASTER --- ###
raster_files <- list(
NDVI = list("2020" = "NDVI_20_resampled.tif",
"2024" = "NDVI_24_resampled.tif"),
NDWI = list("2020" = "NDWI_2020.tif",
"2024" = "NDWI_2024.tif"),
SAVI = list("2020" = "SAVI_2020.tif",
"2024" = "SAVI_2024.tif"),
LAI = list("2020" = "LAI_20.tif",
"2024" = "LAI_24.tif")
)

rasters <- lapply(raster_files, function(x) lapply(x, rast))




### --- ESTRAZIONE VALORI --- ###
lista_df <- list()

for (indice in names(rasters)) {
for (anno in names(rasters[[indice]])) {
for (buffer_nome in names(punti_random)) {

valori <- extract(
rasters[[indice]][[anno]],
punti_random[[buffer_nome]]
)

colnames(valori)[2] <- "valore"

valori$indice <- indice
valori$year <- as.numeric(anno)
valori$buffer <- as.numeric(gsub("km", "", buffer_nome))

valori$ID <- NULL

lista_df[[paste(indice, anno, buffer_nome, sep = "_")]] <- valori
  }
 }
}


### --- CREAZIONE DATASET FINALE --- ###
df_completo <- bind_rows(lista_df)
df_completo <- na.omit(df_completo)


### --- ESPORTAZIONE --- ###
write.xlsx(
df_completo,
"df_completo_per_test_1.xlsx",
overwrite = TRUE
)

