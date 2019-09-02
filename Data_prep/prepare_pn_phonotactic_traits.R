### EXTRACT BIPHONE DATA #############
#   Name:      Jayden Macklin-Cordes #
#   Created:   2019-07-15            #
#   Last edit: 2019-07-22            #
#   Last run:  2019-07-15            #
######################################

# INITIAL SETUP

# Private Github repositories fetched locally on 2019-07-15:
#   - erichround/phonex
#   - erichround/Ausphonlex

# FIRST:  Open phonex.Rproj in RStudio. Select Build > Install and Restart.
# SECOND: Open Ausphonlex.Rproj in Rstudio. Build > Install and Restart.
# THEN:   Run script below. (runtime: ~25 mins)

# NB: There is a hard-coded filepath to an Ausphonlex file on/around line 71: Ausphonlex/dbs/Maps-DB-wordlists.tsv

library(Ausphonlex)
library(tidyverse)

# Load latest official version of Ausphonlex database as object 'aus'
aus <- ausphonlex_v0.5

# Get a list of lex IDs for lexicons that are:
#   a) clean
#   b) contain at least 250 lexical items (cf. Dockum & Bowern, 2019)
# https://www.researchgate.net/publication/332751956_Swadesh_lists_are_not_long_enough_Drawing_phonological_generalizations_from_limited_data
aus_size <- get_aus_size(id = get_clean_lex_IDs()) %>%
  filter(n_forms >= 250)

# Get biphone dataset (forward and backward)
b_fwd  <- extract_freq_dataset("biphone_fwd_clean")
b_bkwd <- extract_freq_dataset("biphone_bkwd_clean")

names(b_fwd)[2:ncol(b_fwd)]   <- paste0(names(b_fwd)[2:ncol(b_fwd)], "_fwd")
names(b_bkwd)[2:ncol(b_bkwd)] <- paste0(names(b_bkwd)[2:ncol(b_bkwd)], "_bkwd")

biphones <- full_join(b_fwd, b_bkwd, by = "lex_ID") %>%
  filter(lex_ID %in% aus_size$lex_ID)

# Get soundclass dataset (place, manner, forward and back. NB: Not major place)
p_fwd   <- extract_freq_dataset("place_bigram_fwd_clean")
p_bkwd  <- extract_freq_dataset("place_bigram_bkwd_clean")
m_fwd  <- extract_freq_dataset("manner_bigram_fwd_clean")
m_bkwd <- extract_freq_dataset("manner_bigram_bkwd_clean")

names(p_fwd)[2:ncol(p_fwd)]   <- paste0(names(p_fwd)[2:ncol(p_fwd)], "_fwd")
names(p_bkwd)[2:ncol(p_bkwd)] <- paste0(names(p_bkwd)[2:ncol(p_bkwd)], "_bkwd")
names(m_fwd)[2:ncol(m_fwd)]   <- paste0(names(m_fwd)[2:ncol(m_fwd)], "_fwd")
names(m_bkwd)[2:ncol(m_bkwd)] <- paste0(names(m_bkwd)[2:ncol(m_bkwd)], "_bkwd")

sound_classes <- full_join(p_fwd, p_bkwd, by = "lex_ID") %>%
  full_join(m_fwd, by = "lex_ID") %>%
  full_join(m_bkwd, by = "lex_ID") %>%
  filter(lex_ID %in% aus_size$lex_ID)

### Matching language varieties between phonotactic and cognate datasets ###
# Get list of all languages for which we have data
our_IDs <- unique(c(biphones$lex_ID, sound_classes$lex_ID))
our_lgs <- get_aus_varname(our_IDs)

# Get list of all languages in the cognate data
cogs    <- read_tsv("Bouckaert_etal/Pny10-Export.tsv", col_names = FALSE)
CBs_lgs <- unique(cogs$X4)

# Get into Ausphonlex metatdata and make a table showing lex IDs,
# language variety names and taxon names from the Pama-Nyungan phylogeny in Bouckaert et al (2018)

Map_DB_Wordlists <- read_csv("~/Desktop/Github/erichround/Ausphonlex/dbs/Map-DB-Wordlists.csv") %>%
  mutate(lex_ID = as.numeric(Vocab_ID), tax_label = Bowern_307_taxon_label) %>%
  select(one_of(c("lex_ID","Name", "tax_label")))

# Of the languages for which we have clean data, there is one (Waanyi) for which 
# there is also cognate data in Pny10-Export.tsv but isn't included in Bouckaert et al.'s
# subsequent phylogenetic analysis.

missing_lgs <- filter(Map_DB_Wordlists, (lex_ID %in% biphones$lex_ID) & is.na(Map_DB_Wordlists$tax_label))$Name
missing_lgs[missing_lgs %in% CBs_lgs]

# I include Waanyi in my analysis
# UPDATE: Waanyi has NOT been included since, in addition to areal borrowing reasons described in Bouckaert et al, there is also a substantial difference in analysis of its contrastive segmental inventory between old and new sources, the choice of which may affect phonotactic stats. We only have access to the old source here.
# Map_DB_Wordlists[match("Waanyi",Map_DB_Wordlists$Name), "tax_label"] <- "Waanyi"

# Add taxon labels to phonotactic datasets
biphones      <- left_join(biphones, Map_DB_Wordlists, by = "lex_ID")
sound_classes <- left_join(sound_classes, Map_DB_Wordlists, by = "lex_ID")

### Filter phonotactic data and cognate data to the same set of languages

# Filter phonotactic data to only languages for which we also have cognate data
# Select only traits with at least 4 non-missing values 
# Write results to tsv file

biphone_traits <- filter(biphones, !is.na(biphones$tax_label)) %>%
  select(-c("lex_ID", "Name")) %>%
  select(tax_label, everything())

biphone_traits <- biphone_traits[, colSums(!is.na(biphone_traits)) >= 4]

soundclass_traits <- filter(sound_classes, !is.na(sound_classes$tax_label)) %>%
  select(-lex_ID, -Name) %>%
  select(tax_label, everything())

soundclass_traits <- soundclass_traits[, colSums(!is.na(soundclass_traits)) >= 4]

write_tsv(biphone_traits, paste0("Data/biphone_traits_", Sys.Date(), ".tsv"), na = "?", col_names = FALSE)
write_tsv(soundclass_traits, paste0("Data/soundclass_traits_", Sys.Date(), ".tsv"), na = "?", col_names = FALSE)

# Filter cognate data to languages for which we also have phonotactic data
# and save output
cog_data <- filter(cogs, X4 %in% unique(c(biphone_traits$tax_label, soundclass_traits$tax_label)))
write_tsv(cog_data, paste0("Data_prep/Pny10-Export_filtered_", Sys.Date(), ".tsv"), col_names = FALSE)
