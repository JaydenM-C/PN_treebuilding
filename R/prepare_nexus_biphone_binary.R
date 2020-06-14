# Prepare nexus file of binary phonotactic data
# Jayden Macklin-Cordes
# # # # # # # # # # # # # # # # # # # # # # # #

library(tidyverse)
library(ape)

# Get newest binary phonotactic dataset
datfile <- rev(list.files("../Data/csv", "biphone_binary"))[1]

# Drop variables with all NAs
drop_empty_sites <- function (dat) {
  NAs <- colSums(is.na(dat))
  all_na <- NAs == nrow(dat)
  dat[,!all_na]
}

# Function to drop uninformative variables (where all values are NA or zero)
drop_invariant_sites <- function(dat) {
  uniquelength <- sapply(dat, function(x) length(unique(x[!is.na(x)])))
  df <- subset(dat, select = uniquelength > 1)
  df
}

drop_singleton_sites <- function(dat) {
  # NB assumes first col is lg names
  singletons <- names(colSums(dat[,-1], na.rm = TRUE)[colSums(dat[,-1], na.rm = TRUE) ==1])
  select(dat, !one_of(singletons))
}

bindat <- read_csv(paste0("../Data/csv/", datfile)) %>%
  drop_empty_sites

# Turn dataframe into list
bindat_list <- lapply(split(bindat[,-1], 1:nrow(bindat)), as.list) %>%
  lapply(as.character) %>%
  lapply(function (x) {x[x=="NA"] <- "-"; x})
names(bindat_list) <- bindat$tip_label

write.nexus.data(bindat_list, paste0("../Data/nex/biphone_binary_", Sys.Date(), ".nex"), format = "standard", interleaved = FALSE)

# Change symbols field in nexus file (ape automatically lists all 9 digits instead of just 0 and 1)
nex <- readLines(paste0("../Data/nex/biphone_binary_", Sys.Date(), ".nex"))
nex <- gsub("0123456789", "01", nex)
writeLines(nex, paste0("../Data/nex/biphone_binary_", Sys.Date(), ".nex"))

