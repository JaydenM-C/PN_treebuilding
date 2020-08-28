#################
# DATA WRANGLING
#################

# Jayden Macklin-Cordes
# 13 December 2019
# Revised: 28 August 2020

# This script extracts binary biphone and transition frequency data from Ausphonlex
# NB: Includes hard-coded filepaths
# Requires phonlex and Ausphonlex packages (not publicly released)

#################
# SET UP
#################

library(tidyverse)
library(ape)
library(phonlex)
library(Ausphonlex)

# Load Ausphonlex
aus <- ausphonlex_v0.6.3

# Get wordlist sizes
lex_size <- aus@entries %>%
  filter(str_length(xphon_form) > 0) %>%
  filter(!str_detect(tags, "duplicate|boundary_initial|boundary_final|q_mark")) %>%
  group_by(lex_ID, entry_ID) %>%
  slice(1) %>%
  group_by(lex_ID) %>%
  summarise(n_entries = n())

# Get taxon labels from Map-DB-Wordlists
  # Filter to clean lex_IDs
  # Attach wordlist sizes
  # Filter out wordlists with < 250 entries
metadata <- read_csv("~/Desktop/Github/erichround/Ausphonlex/dbs/Map-DB-Wordlists.csv") %>%
  filter(Vocab_ID %in% as.character(get_clean_lex_IDs())) %>%
  filter(!is.na(Bowern_307_taxon_label)) %>%
  filter(Family == "Pama-Nyungan") %>% # One non-PN language is filtered out (Lardil)
  mutate(lex_ID = as.numeric(Vocab_ID)) %>%
  select(lex_ID, tip_label = Bowern_307_taxon_label) %>%
  left_join(lex_size, by = "lex_ID") %>%
  filter(n_entries >= 250)

write_csv(metadata, paste0("../Data/wordlist_sizes_", Sys.Date(), ".csv"))

# Get biphone forward/backward transition frequencies
set.seed(2020)
biphone_fwd <- as_tibble(extract_freq_dataset("biphone_fwd_clean"))

set.seed(2020)
biphone_bkwd <- as_tibble(extract_freq_dataset("biphone_bkwd_clean"))

#################
# BINARY DATASET
#################

binarize_frequencies <- function(dataset) {
  dataset[, -1][dataset[, -1] > 0] = 1
  dataset
}

phylo_data_binary <- metadata %>% left_join(biphone_fwd, by = "lex_ID") %>%
  select(-lex_ID, -n_entries) %>%
  binarize_frequencies

write_csv(phylo_data_binary, paste0("../Data/biphone_binary_raw_", Sys.Date(), ".csv"))

############################
# BIPHONE FREQUENCY DATASET
############################

phylo_data_biphone_fwd <- metadata %>% left_join(biphone_fwd, by = "lex_ID") %>%
  select(-lex_ID, -n_entries) %>%
  rename_with(paste0, -one_of("tip_label"), "_fwd")

phylo_data_biphone_bkwd <- metadata %>% left_join(biphone_bkwd, by = "lex_ID") %>%
  select(-lex_ID, -n_entries) %>%
  rename_with(paste0, -one_of("tip_label"), "_bkwd")

phylo_data_biphone <- left_join(phylo_data_biphone_fwd, phylo_data_biphone_bkwd, by = "tip_label")

write_csv(phylo_data_biphone, paste0("../Data/biphone_frequency_raw_", Sys.Date(), ".csv"))
