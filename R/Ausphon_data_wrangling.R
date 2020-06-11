# Data wrangling
# Jayden Macklin-Cordes
# # # # # # # # # # # # #

library(tidyverse)
library(phonlex)
library(Ausphonlex)

# Load Ausphonlex
aus <- ausphonlex_v0.6.2

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
  mutate(lex_ID = as.numeric(Vocab_ID)) %>%
  select(lex_ID, tip_label = Bowern_307_taxon_label) %>%
  left_join(lex_size, by = "lex_ID") %>%
  filter(n_entries >= 250)

write_csv(metadata, paste0("../Data/wordlist_sizes_", Sys.Date(), ".csv"))

# Get wordlist data (NB INCLUDES PRIVATE DATA)
set.seed(2020)
biphone_fwd <- as_tibble(extract_freq_dataset("biphone_fwd_clean"))

set.seed(2020)
biphone_bkwd <- as_tibble(extract_freq_dataset("biphone_bkwd_clean"))

#################
# BINARY DATASET
#################

binarize_frequencies <- function(dataset) {
  dataset[, -c(1:2)][dataset[, -c(1:2)] > 0] = 1
  dataset
}

phylo_data_binary <- metadata %>% left_join(biphone_fwd, by = "lex_ID") %>%
  binarize_frequencies %>%
  select(-lex_ID, -n_entries)

write_csv(phylo_data_binary, paste0("../data/biphone_binary_", Sys.Date(), ".csv"))

############################
# BIPHONE FREQUENCY DATASET
############################

# Forward transition probabilities and backward transition probabilities for biphones:
phylo_data_biphone_fwd <- metadata %>% left_join(biphone_fwd, by = "lex_ID") %>%
  select(-lex_ID, -n_entries)

phylo_data_biphone_bkwd <- metadata %>% left_join(biphone_bkwd, by = "lex_ID") %>%
  select(-lex_ID, -n_entries)

write_csv(phylo_data_biphone_fwd, paste0("../data/biphone_fwd_", Sys.Date(), ".csv"))
write_csv(phylo_data_biphone_bkwd, paste0("../data/biphone_bkwd_", Sys.Date(), ".csv"))

