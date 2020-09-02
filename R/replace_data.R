# This function updates biphone_binary xml files
# It deletes Lardil, adds Wailwan, and replaces sequence data

update_xml <- function (file) {
  xml = readLines(file)
  xml[58] <- "\t\t<taxon id=\"Wailwan\"/>"
  xml[137] <- paste0(xml[137], "\n", "\t\t<taxon idref=\"Wailwan\"/>")
  new_sequences <- readLines("../Data/biphone_binary_data.xml")[134:581]
  xml[279:726] <- new_sequences
  writeLines(xml, gsub("07-23", "08-31", file))
}

dirs <- as.character(sapply(list.files("../biphone_binary"), function (i) paste("../biphone_binary", i, "xml", sep = "/")))

xml_files <- unlist(sapply(dirs, function (i) list.files(i, full.names = TRUE)))

sapply(xml_files, update_xml)

# Round two: Removing Arandic subgroup (pointless because it only has 1 language)
# And updating date in output file names

dirs <- as.character(sapply(list.files("../biphone_binary"), function (i) paste("../biphone_binary", i, "xml", sep = "/")))

xml_files <- unlist(sapply(dirs, function (i) list.files(i, full.names = TRUE)))

update_xml_date <- function (file) {
  xml = readLines(file)
  xml <- gsub("07-23", "08-31", xml)
  writeLines(xml, file)
}

sapply(xml_files, update_xml_date)

remove_arandic <- function (file) {
  xml = readLines(file)
  xml <- xml[-c(130:132)]
  xml <- xml[-c((grep('<taxa idref="Arandic"/>', xml)[1] -1):(grep('<taxa idref="Arandic"/>', xml)[1] +2))]
  xml <- xml[-c(grep('<tmrcaStatistic id\\="tmrca\\(Arandic\\)"', xml):(grep('<tmrcaStatistic id\\="tmrca\\(Arandic\\)"', xml) + 17))]
  xml <- xml[-grep('<monophylyStatistic idref\\="monophyly\\(Arandic\\)"/>', xml)]
  xml <- xml[-grep('<tmrcaStatistic idref\\="tmrca\\(Arandic\\)"/>', xml)]
  xml <- xml[-grep('<tmrcaStatistic idref\\="age\\(Arandic\\)"/>', xml)]
}

sapply(xml_files, remove_arandic)
