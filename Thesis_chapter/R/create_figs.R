library(ape)
library(treeio)
library(tidytree)
library(tidyverse)
library(phytools)

### COGNATES ONLY VS PREVIOUS TREES ###

# Read trees as ape's S3 phylo class
cogs    <- ape::read.nexus("../trees/WPN_cogsonly_2020-11-18_MCCT.tree")
bba2018 <- ape::read.nexus("../trees/BBA2018_Pny_MCCT.nex")
bba2018 <- ape::drop.tip(bba2018, setdiff(bba2018$tip.label, cogs$tip.label))

# Read trees as treeio's S4 phylo class
cogs_df    <- treeio::read.beast("../trees/WPN_cogsonly_2020-11-18_MCCT.tree") %>%
  treeio::as_tibble(cogs_df) %>% full_join(tidytree::as_tibble(cogs))
bba2018_df <- treeio::read.beast("../trees/BBA2018_Pny_MCCT.nex")
bba2018_df <- treeio::drop.tip(bba2018_df, setdiff(bba2018_df@phylo$tip.label, cogs$tip.label)) %>%
  treeio::as_tibble(bba2018_df) %>% full_join(tidytree::as_tibble(bba2018))
class(bba2018_df$posterior) <- "numeric"

# Claire Bowern's 2015 tree
cb2015 <- ape::read.nexus("../trees/PNY10_285.(time).sum.tree")
cb2015 <- ape::drop.tip(cb2015, setdiff(cb2015$tip.label, cogs$tip.label))

cb2015_df <- treeio::read.beast("../trees/PNY10_285.(time).sum.tree")
cb2015_df <- treeio::drop.tip(cb2015_df, setdiff(cb2015_df@phylo$tip.label, cogs$tip.label)) %>%
  treeio::as_tibble(cb2015_df) %>% full_join(tidytree::as_tibble(cb2015))

# CB's 2015 tree vs BBA's 2018 tree
cb2015_vs_bba2018 <- cophylo(cb2015, bba2018)
cairo_pdf("../fig/cb2015_vs_bba2018.pdf", height = 10, width = 8)
plot.cophylo(cb2015_vs_bba2018)
par(mar=c(0,0,1,0))
title("Bowern (2015) vs Bouckaert, Bowern and Atkinson (2018)")
nodelabels.cophylo(round(cb2015_df$posterior, 2), cb2015_df$node, cex = .7, adj = 0, which = "left")
nodelabels.cophylo(round(bba2018_df$posterior, 2), bba2018_df$node, cex = .7, adj = 0, which = "right")
dev.off()

# Cogs tree vs BBA2018
bba2018_vs_cogs <- cophylo(cogs, bba2018)
cairo_pdf("../fig/cogs_vs_bba2018.pdf", height = 10, width = 8)
plot.cophylo(bba2018_vs_cogs)
par(mar=c(0,0,1,0))
title("Cognate-only model vs. Bouckaert, Bowern and Atkinson (2018)")
nodelabels.cophylo(round(cogs_df$posterior,2), cogs_df$node, cex = .7, adj = 0, which = "left")
nodelabels.cophylo(round(bba2018_df$posterior,2), bba2018_df$node, cex = .7, adj = 1, which = "right")
dev.off()

# Cogs tree vs CB2015
# Cogs tree seems closer to 2018 tree than 2015 tree
cb2015_vs_cogs <- cophylo(cogs, cb2015)
cairo_pdf("../fig/cogs_vs_cb2015.pdf", height = 10, width = 8)
plot.cophylo(cb2015_vs_cogs)
par(mar=c(0,0,1,0))
title("Cognates only vs Bowern (2015)")
nodelabels.cophylo(round(cogs_df$posterior,2), cogs_df$node, cex = .7, adj = 0, which = "left")
nodelabels.cophylo(round(cb2015_df$posterior,2), cb2015_df$node, cex = .7, adj = 1, which = "right")
dev.off()


### READING MORE TREES ###

## All data ##
linked_all <- ape::read.nexus("../trees/WPN_linked_alldata_2020-11-18_ch7-8_10_MCCT.tree")
sep_all_cogs <- ape::read.nexus("../trees/WPN_separate_alldata_2020-11-18_ch2_7.WPN_cognates.MCCT.tree")
sep_all_phon <- ape::read.nexus("../trees/WPN_separate_alldata_2020-11-18_ch2_7.default.MCCT.tree")

linked_all_df <- treeio::read.beast("../trees/WPN_linked_alldata_2020-11-18_ch7-8_10_MCCT.tree") %>%
  treeio::as_tibble(linked_all_df) %>% full_join(tidytree::as_tibble(linked_all))
sep_all_cogs_df <- treeio::read.beast("../trees/WPN_separate_alldata_2020-11-18_ch2_7.WPN_cognates.MCCT.tree") %>%
  treeio::as_tibble(sep_all_cogs_df) %>% full_join(tidytree::as_tibble(sep_all_cogs))
sep_all_phon_df <- treeio::read.beast("../trees/WPN_separate_alldata_2020-11-18_ch2_7.default.MCCT.tree") %>%
  treeio::as_tibble(sep_all_phon_df) %>% full_join(tidytree::as_tibble(sep_all_phon))

## Binary biphone data removed ##
linked <- ape::read.nexus("../trees/WPN_linked_2020-11-18_ch1_MCCT.tree")
sep_cogs <- ape::read.nexus("../trees/WPN_separate_2020-11-18.WPN_cognates.MCCT.trees")
sep_phon <- ape::read.nexus("../trees/WPN_separate_2020-11-18.WPN_phonotactics.MCCT.trees")

linked_df <- treeio::read.beast("../trees/WPN_linked_2020-11-03_MCCT.trees") %>%
  treeio::as_tibble(linked_df) %>% full_join(tidytree::as_tibble(linked))
sep_cogs_df <- treeio::read.beast("../trees/WPN_separate_2020-11-18.WPN_cognates.MCCT.trees") %>%
  treeio::as_tibble(sep_cogs_df) %>% full_join(tidytree::as_tibble(sep_cogs))
sep_phon_df <- treeio::read.beast("../trees/WPN_separate_2020-11-18.WPN_phonotactics.MCCT.trees") %>%
  treeio::as_tibble(sep_phon_df) %>% full_join(tidytree::as_tibble(sep_phon))

#### MORE PLOTTING ####

## Cognates only vs all data, linked model ##

cogs_vs_linked_all <- cophylo(cogs, linked_all)

cairo_pdf("../fig/cogs_vs_linked_all.pdf", height = 10, width = 8)
plot.cophylo(cogs_vs_linked_all)
par(mar=c(0,0,1,0))
title("Cognates vs. all data linked")
nodelabels.cophylo(round(cogs_df$posterior,2), cogs_df$node, cex = .7, adj = 0, which = "left")
nodelabels.cophylo(round(linked_all_df$posterior,2), linked_all_df$node, cex = .7, adj = 1, which = "right")
dev.off()

bba2018_vs_linked_all <- cophylo(bba2018, linked_all)

cairo_pdf("../fig/bba2018_vs_linked_all.pdf", height = 10, width = 8)
plot.cophylo(bba2018_vs_linked_all)
par(mar=c(0,0,1,0))
title("Bouckaert, Bowern and Atkinson (2018) vs. all data linked")
nodelabels.cophylo(round(bba2018_df$posterior,2), bba2018_df$node, cex = .7, adj = 0, which = "left")
nodelabels.cophylo(round(linked_all_df$posterior,2), linked_all_df$node, cex = .7, adj = 1, which = "right")
dev.off()

## All data separate: cognates element vs phonotactics element ##

sep_all_cogs_vs_sep_all_phon <- cophylo(sep_all_cogs, sep_all_phon)

cairo_pdf("../fig/separate_cogs_vs_phonotactics_alldata.pdf", height = 10, width = 8)
plot.cophylo(sep_all_cogs_vs_sep_all_phon)
par(mar=c(0,0,1,0))
title("Separate (all data): cognates element vs phonotactics element")
nodelabels.cophylo(round(sep_all_cogs_df$posterior, 2), sep_all_cogs_df$node, cex = .7, adj = 0, which = "left")
nodelabels.cophylo(round(sep_all_phon_df$posterior, 2), sep_all_phon_df$node, cex = .7, adj = 1, which = "right")
dev.off()

## Cognates only vs linked model (binary biphone data removed)

cogs_vs_linked <- cophylo(cogs, linked)

cairo_pdf("../fig/cogs_vs_linked.pdf", height = 10, width = 8)
plot.cophylo(cogs_vs_linked)
par(mar=c(0,0,1,0))
title("Cognates vs. linked model (binary biphone data removed)")
nodelabels.cophylo(round(cogs_df$posterior,2), cogs_df$node, cex = .7, adj = 0, which = "left")
nodelabels.cophylo(round(linked_all_df$posterior,2), linked_all_df$node, cex = .7, adj = 1, which = "right")
dev.off()

## Linked models with vs without binary biphone data

linked_all_vs_linked <- cophylo(linked_all, linked)

cairo_pdf("../fig/linked_all_vs_linked.pdf", height = 10, width = 8)
plot.cophylo(linked_all_vs_linked)
par(mar=c(0,0,1,0))
title("Linked models with vs without binary biphone data")
nodelabels.cophylo(round(linked_all_df$posterior,2), linked_all_df$node, cex = .7, adj = 0, which = "left")
nodelabels.cophylo(round(linked_df$posterior,2), linked_df$node, cex = .7, adj = 1, which = "right")
dev.off()
