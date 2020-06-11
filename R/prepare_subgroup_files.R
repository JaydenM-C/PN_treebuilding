# Prepare subgroup files to import into Beauti
# Jayden Macklin-Cordes
# # # # # # # # # # # # # # # # # # # # # # # #

# This script generates a simple text file for each Pama-Nyungan subgroup
# for importing clade priors into Beauti.
# Each taxon in our dataset is allocated to its corresponding subgroup in 
# Bouckaert, Bowern and Atkinson 2018.
# This is done by matching taxa to subgroups in the "Languages-StandardLangs.csv" 
# spreadsheet then making some manual adjustments to match Bouckaert, Bowern and 
# Atkinson 2018.
# Note that several subgroups contain only one language. These don't need to be 
# imported into Beauti (they're uninformative without ages) but 
# the script generates them anyway for ease of reproducibility if more languages
# are added in the future.

# Get subgroup info
lg_subgroups <- read_csv("../Data/CB_raw/Languages-StandardLangs.csv") %>%
  filter(Ascii_Name %in% bindat$tip_label) %>%
  select(Ascii_Name, `TEMP@SubgroupName`)
# Manual adjustments to match Bouckaert, Bowern and Atkinson (2018)
lg_subgroups$`TEMP@SubgroupName`[lg_subgroups$`TEMP@SubgroupName` == "Yolŋu"] <- "Yolngu"
lg_subgroups$`TEMP@SubgroupName`[lg_subgroups$`TEMP@SubgroupName` %in% c("Dyirbalic", "Maric", "Nyawaygic", "Paman")] <- "PamaMaric"
lg_subgroups$`TEMP@SubgroupName`[lg_subgroups$`TEMP@SubgroupName` == "Kanyara-Martatha"] <- "Kanyara-Mantharta"
lg_subgroups$`TEMP@SubgroupName`[lg_subgroups$`TEMP@SubgroupName` == "Mirniny"] <- "SouthWest"
lg_subgroups$`TEMP@SubgroupName`[lg_subgroups$`TEMP@SubgroupName` == "Pilbara"] <- "Ngayarta"
lg_subgroups[lg_subgroups$Ascii_Name == "Paakantyi",2] <- "PaakantyiRegion"
lg_subgroups[lg_subgroups$Ascii_Name == "Bandjalang",2] <- "Bandjalangic"
# Manually add lgs missing from Languages-StandardLangs spreadsheet (or listed as "no subgroup defined")
# to match Bouckaert, Bowern and Atkinson (2018)
missing_lgs <- tibble("Ascii_Name" = c("Yaygirr",
                                       "WalmajarriHR", 
                                       "Tharrgari", 
                                       "WesternArrarnta", 
                                       "MangalaMcK",
                                       "Ngadjumaya",
                                       "Mbakwithi"),
                      "TEMP@SubgroupName" = c("Gumbaynggiric",
                                              "Ngumpin-Yapa",
                                              "Kanyara-Mantharta",
                                              "Arandic",
                                              "Marrngu",
                                              "SouthWest",
                                              "PamaMaric")
)
lg_subgroups <- bind_rows(lg_subgroups, missing_lgs)

# Get well-formed list of subgroup names
subgroups <- unique(lg_subgroups$`TEMP@SubgroupName`)
subgroups[subgroups == "no subgroup defined"] <- NA
subgroups <- subgroups[!is.na(subgroups)]
#subgroups <- gsub("-| ", "", subgroups)

write_subgroup_files <- function (lg_subgroups, bindat) {
  subgroup_dfs <- lapply(subgroups, function (i) {filter(lg_subgroups, `TEMP@SubgroupName` == i) %>%
      select(Ascii_Name)})
  names(subgroup_dfs) <- gsub("-| ", "", subgroups)
  lapply(1:length(subgroup_dfs), 
         function (i) write_tsv(subgroup_dfs[[i]],
                                paste0("../Data/subgroups/", names(subgroup_dfs[i]), ".txt"),
                                col_names = FALSE))
}

write_subgroup_files(lg_subgroups)
