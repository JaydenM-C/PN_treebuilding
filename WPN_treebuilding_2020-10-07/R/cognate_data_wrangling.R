########################
# COGNATE DATA WRANGLING
########################

# Jayden Macklin-Cordes
# 12 October 2020

# Filters original cognate data from Bouckaert et al. 2018 to a subset of 
# 44 Western Pama-Nyungan languages.


library(tidyverse)

# Read biphone frequency data and take list of languages to include
lgs <- rev(list.files("../Data", "soundclass_data_raw", full.names = TRUE))[1] %>%
  read_csv() %>% select("tip_label")

# Read raw cognate data from Bouckaert et al and filter to languages to include
cogs <- read_tsv("../Bouckaert_etal/Pny10-Export.tsv", col_names = FALSE)

cogs <- filter(cogs, X4 %in% lgs$tip_label)

write_tsv(cogs, paste0("../Data/WPN_cognates_", Sys.Date(), ".tsv"), col_names = FALSE)
