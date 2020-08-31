########################
# COGNATE DATA WRANGLING
########################

# Jayden Macklin-Cordes

#################
# SET UP
#################

library(tidyverse)

# Read biphone frequency data and take list of languages to include
lgs <- read_tsv("../Data/biphone_frequency_2020-08-28.tsv") %>%
  select(tip_label)

# Read raw cognate data from Bouckaert et al and filter to languages to include
cogs <- read_tsv("../Bouckaert_etal/Pny10-Export.tsv", col_names = FALSE)

cogs[cogs == "KuukuYa’u"] <- "KuukuYau"

cogs <- filter(cogs, X4 %in% lgs$tip_label)

write_tsv(cogs, paste0("../Data/PN_cognates_", Sys.Date(), ".tsv"), col_names = FALSE)
