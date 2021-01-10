# PN_treebuilding
Inferring phylogenetic trees with quantitative phonotactic characters

**Results files are stored at https://cloud.rdm.uq.edu.au/index.php/s/L88ncHHqiNtBoy4 (password: phonotactics)**

This repository contains data and code accompanying Chapter 6 of my [PhD thesis](https://github.com/JaydenM-C/final_thesis). The output files are too large for Github, so they have been deposited temporarily on UQ's RDM system [here](https://cloud.rdm.uq.edu.au/index.php/s/L88ncHHqiNtBoy4). The RDM repository is password-protected---the password is "phonotactics". A more permanent, public repository will be confirmed once the thesis has undergone revision.

## (§6.3) Prelim test 1: Evolutionary model for binary biphone data

The [biphone_binary](https://github.com/JaydenM-C/PN_treebuilding/biphone_binary) folder contains 16 subfolders, one for each of the 16 model permutations tested. Each of these contains three sub-subfolders: `xml`, `output` and `MLE`. The `xml` folder will contain two BEAST xml files (one each for chain 1 and chain 2, for each model) and the other two sit empty, waiting for output to be generated. Back in the biphone_binary folder, there are two bash scripts, `biphone_binary_ch1.pbs` and `biphone_binary_ch2.pbs`. These run chains 1 and 2 respectively for each model and fill the `output` files. Finally, the `bin` subfolder contains a bash script that combines each chain for each model and calculates an overall marginal likelihood estimate. Producing output in the first instance takes many hours but the MLE combiner script just combines existing calculations so it's very fast.

## (§6.4) Prelim test 2: Tree inference using cognate data only

The folder [WPN_cogsonly_2020-11-13](https://github.com/JaydenM-C/PN_treebuilding/WPN_cogsonly_2020-11-13) contains materials for the lexical-cognate-only model in Preliminary test 2. The whole of prelim test 2 is self-contained within this folder. The original cognate data is in the tsv file `Bouckaert_etal/Pny10-Export.tsv`. There is a two-step process for wrangling this spreadsheet into a nexus file that can be imported into BEAUTi. First, the script `R/cognate_data_wrangling.R` filters the data and saves a file that includes only western Pama-Nyungan languages with sufficient AusPhon data. Then, the bash script `bin/generate_pn_cognate_nexus` takes that file, copies the data into the Perl script `Bouckaert_etal/pny10.pl` and runs the Perl script to generate a nexus file. BEAST XML files are stored in the `WPN_cogsonly` subfolder, one each for four independent chains.

## (§6.5) Main test: Tree inference with phonotactic data

The folder [WPN_alldata_2020-11-18](https://github.com/JaydenM-C/PN_treebuilding/WPN_alldata_2020-11-18) contains materials for the main test. Again, everything is self-contained within this folder. First, the script `R/Ausphon_data_wrangling.R` extracts binary biphone and sound class transition frequency data from AusPhon. AusPhon is owned and managed by Erich Round and is yet to be publicly released. The output files are stored in the `Data` subfolder. Then, the script `R/data_filtering.R` does some additional tidying of the data (removing characters with all NAs and so forth) and performs logit transformation on the frequency data. It also filters the cognate data to applicable western Pama-Nyungan languages. The `bin/generate_pn_cognate_nexus` script should then be run as above, to get a nexus file of cognate data. XML files for BEAST are stored in `WPN_linked` and `WPN_separate` folders. The `Java` folder contains a pre-release version of BEAST v1.10.5 which should be used to run the XML files (another full copy of this version of beast is also in the repository's root directory).

## (§6.6) Follow-up test: Binary biphone data removed

The folder [WPN_treebuilding_2020-11-18](https://github.com/JaydenM-C/PN_treebuilding/WPN_treebuilding_2020-11-18) is self-contained, containing all the materials for the follow-up test in §6.6, in which binary biphone data is removed and the trees are inferred just from cognate data and sound class transition frequency data. This folder is structured very much as above but with the binary biphone parts removed.
