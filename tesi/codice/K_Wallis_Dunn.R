### --- LIBRERIE --- ###
library(readxl)
library(dplyr)
library(rstatix)
library(openxlsx)


### --- CARICAMENTO DATASET --- ###
df <- read_excel("df_completo_per_test_1.xlsx")

### --- IDENTIFICAZIONE INDICI E ANNI --- ###
indici <- unique(df$indice)
anni <- unique(df$year)


### --- CICLO PER INDICE E ANNO --- ###
for (ind in indici) {
for (yr in anni) {

# Selezione dati per indice e anno
dati <- df %>%
filter(indice == ind, year == yr) %>%
mutate(buffer = factor(buffer))

# Salta iterazione se non sono presenti dati
if (nrow(dati) == 0) next


### --- TEST DI KRUSKAL–WALLIS --- ###
kruskal_res <- dati %>%
kruskal_test(valore ~ buffer) %>%
mutate(Significativo = ifelse(p < 0.05, "Sì", "No"))


### --- TEST POST-HOC DI DUNN (Bonferroni) --- ###
dunn_res <- dati %>%
dunn_test(valore ~ buffer, p.adjust.method = "bonferroni") %>%
mutate(Significativo = ifelse(p.adj < 0.05, "Sì", "No"))


### --- CREAZIONE FILE EXCEL --- ###
wb <- createWorkbook()
redStyle <- createStyle(fontColour = "#FF0000", textDecoration = "bold")

# Foglio Kruskal–Wallis
addWorksheet(wb, "Kruskal_Wallis")
writeData(wb, "Kruskal_Wallis", kruskal_res)

sig_rows_kw <- which(kruskal_res$p < 0.05) + 1

if (length(sig_rows_kw) > 0) {
addStyle(
wb,
"Kruskal_Wallis",
redStyle,
rows = sig_rows_kw,
cols = which(names(kruskal_res) == "p"),
gridExpand = TRUE
  )
}

# Foglio Dunn
addWorksheet(wb, "Dunn")
writeData(wb, "Dunn", dunn_res)

sig_rows_dunn <- which(dunn_res$p.adj < 0.05) + 1

if (length(sig_rows_dunn) > 0) {
addStyle(
wb,
"Dunn",
redStyle,
rows = sig_rows_dunn,
cols = which(names(dunn_res) == "p.adj"),
gridExpand = TRUE
  )
}


### --- SALVATAGGIO FILE --- ###
nome_file <- paste0("Risultati_", ind, "_", yr, ".xlsx")
saveWorkbook(wb, nome_file, overwrite = TRUE)
  }
}
