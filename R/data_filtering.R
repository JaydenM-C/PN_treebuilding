# Data filtering
# Jayden Macklin-Cordes
# 20 August 2020
# # # # # # # # # # # #

# Takes raw biphone datasets extracted from Ausphonlex database and raw cognate 
# dataset from Bouckaert et al. (2018) and performs some filtering and minimal 
# wrangling for use with BEAST.

# Input:
#   - Data/biphone_binary_{date}.csv
#   - Data/biphone_frequency_{date}.csv
#   - Bouckaert_etal/Pny10-Export.tsv

# Output:
#   - Data/biphone_binary_filtered_{date}.csv
#   - Data/biphone_frequency_filtered_{date}.csv
#   - Data/PN_cognates_filtered_{date}.tsv

library(tidyverse)
library(ape)
library(car)

bin <- rev(list.files("../Data", "biphone_binary_raw", full.names = TRUE))[1] %>%
  read_csv

freq <- rev(list.files("../Data", "biphone_frequency_raw", full.names = TRUE))[1] %>%
  read_csv

cogs <- read_tsv("../Bouckaert_etal/Pny10-Export.tsv", col_names = FALSE)

# BIPHONE BINARY DATA
# Remove empty sites (all NAs), convert to nexus with "-" as NA symbol

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

# BIPHONE TRANSITION FREQUENCY DATA
# Convert 0s and 1s to NAs, filter out invariant sites, logit transform frequencies and re-write as tsv with "-" as NA symbol

freq[freq == 0] <- NA
freq[freq == 1] <- NA

freq_filtered <- freq %>%
  # Selects columns with at least one digit (i.e. not all NAs)
  select_if(c(TRUE, sapply(2:ncol(freq), function (i) grepl("[0-9]", freq[,i]))))

# Select columns with at least two unique values
unique_vals <- function (i) {
  length(
    unique(freq_filtered[,i])[!is.na(unique(freq_filtered[,i]))]
  )
}

freq_filtered <- select_if(freq_filtered, c(TRUE, sapply(2:ncol(freq_filtered), function (i) {unique_vals(i) > 1})))

freq_filtered[,-1] <- apply(freq_filtered[,-1], 2, logit, adjust = 0)

write_tsv(freq_filtered, paste0("../Data/biphone_frequency_", Sys.Date(), ".tsv"))
