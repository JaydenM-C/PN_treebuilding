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
