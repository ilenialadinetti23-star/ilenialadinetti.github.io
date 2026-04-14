### --- LIBRERIE --- ###
library(dplyr)
library(readxl)
library(openxlsx)

### --- CARICAMENTO DATASET --- ###
df <- read_excel("df_completo_per_test_1.xlsx")

### --- IDENTIFICAZIONE INDICI E BUFFER --- ###
indici <- unique(df$indice)
buffers <- sort(unique(df$buffer))

t_test_results <- data.frame()

### --- CICLO PER BUFFER E INDICE --- ###
for (b in buffers) {
for (i in indici) {

dati <- df %>%
filter(buffer == b, indice == i)

# Calcolo delle medie per anno
media_2020 <- mean(dati$valore[dati$year == 2020], na.rm = TRUE)
media_2024 <- mean(dati$valore[dati$year == 2024], na.rm = TRUE)

delta <- media_2024 - media_2020

# Test t per confronto tra anni
t_res <- t.test(valore ~ year, data = dati)

# Salvataggio risultati
t_test_results <- rbind(
t_test_results,
data.frame(
indice = i,
buffer = b,
media_2020 = media_2020,
media_2024 = media_2024,
delta = delta,
t_value = t_res$statistic,
p_value = t_res$p.value,
significant = ifelse(t_res$p.value < 0.05, "Sì", "No")
       )
     )
  }
}



### --- CREAZIONE FILE EXCEL --- ###
wb <- createWorkbook()
addWorksheet(wb, "T-test")
writeData(wb, "T-test", t_test_results)


# Evidenziazione p-value significativi
red_style <- createStyle(fontColour = "#FF0000", textDecoration = "bold")

p_col <- which(names(t_test_results) == "p_value")

conditionalFormatting(
wb, "T-test",
cols = p_col,
rows = 2:(nrow(t_test_results) + 1),
rule = "<0.05",
style = red_style)


# Evidenziazione colonna significant
sig_col <- which(names(t_test_results) == "significant")
si_rows <- which(t_test_results$significant == "Sì") + 1

if (length(si_rows) > 0) {
addStyle(
wb,
sheet = "T-test",
style = red_style,
rows = si_rows,
cols = sig_col,
gridExpand = TRUE
  )
}


### --- SALVATAGGIO FILE --- ###
saveWorkbook(wb, "Ttest_results.xlsx", overwrite = TRUE)
