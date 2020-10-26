# Data filtering
# Jayden Macklin-Cordes
# 12 October 2020
# # # # # # # # # # # #

# Takes raw sound class frequency transition dataset extracted from Ausphonlex 
# and raw cognate dataset from Bouckaert et al. (2018) and performs some 
# filtering and minimal wrangling for use with BEAST.

# Input:
#   - Data/biphone_binary_raw_{date}.csv
#   - Data/soundclass_data_raw_{date}.csv

# Output:
#   - Data/biphone_binary_filtered_{date}.csv
#   - Data/biphone_frequency_filtered_{date}.csv

library(tidyverse)
library(ape)
library(car)

bin <- rev(list.files("../Data", "biphone_binary_raw", full.names = TRUE))[1] %>%
  read_csv

# BIPHONE BINARY DATA
# Remove empty sites (all NAs), convert to nexus with "-" (gap) as NA symbol

bin_filtered <- bin %>%
  select_if(c(TRUE, sapply(2:ncol(bin), function (i) grepl("0|1", bin[,i]))))

# (The sapply function selects cols containing at least one 0 or 1 value. We also 
#  need to retain the 'tip_label' column (which obviously doesn't contain 0 or 1)
#  so sapply gets wrapped in `c(TRUE, sapply(...))` to retain that first column)

# Turn dataframe into list
bin_list <- lapply(split(bin[,-1], 1:nrow(bin)), as.list) %>%
  lapply(as.character) %>%
  lapply(function (x) {x[x=="NA"] <- "-"; x})
names(bin_list) <- bin$tip_label

write.nexus.data(bin_list, paste0("../Data/biphone_binary_", Sys.Date(), ".nex"), format = "standard", interleaved = FALSE)

# Change symbols field in nexus file (ape automatically lists all 9 digits instead of just 0 and 1)
nex <- readLines(paste0("../Data/biphone_binary_", Sys.Date(), ".nex"))
nex <- gsub("0123456789", "01", nex)
writeLines(nex, paste0("../Data/biphone_binary_", Sys.Date(), ".nex"))
