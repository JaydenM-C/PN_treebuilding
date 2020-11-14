# Data filtering
# Jayden Macklin-Cordes
# 30 October 2020
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

freq <- rev(list.files("../Data", "soundclass_data_raw", full.names = TRUE))[1] %>%
  read_csv

# SOUND CLASS TRANSITION FREQUENCY DATA
# Convert 0s and 1s to NAs, filter out invariant sites, logit transform frequencies and re-write as tsv with "-" (gap) as NA symbol

mins <- sapply (2:ncol(freq), function (i) min(freq[,i], na.rm = T))
maxs <- sapply (2:ncol(freq), function (i) max(freq[,i], na.rm = T))

freq[freq == 0] <- (min(mins[mins > 0]) / 2)
freq[freq == 1] <- (0.5 * (1 + max(maxs[maxs < 1])))

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

write_tsv(freq_filtered, paste0("../Data/soundclass_data_filtered_", Sys.Date(), ".tsv"))
