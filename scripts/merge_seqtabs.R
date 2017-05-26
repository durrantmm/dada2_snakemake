if (!("dada2" %in% installed.packages()[,"Package"])){
  source("https://bioconductor.org/biocLite.R")
  biocLite("dada2")  
}
library(dada2); packageVersion("dada2")
library(readr); packageVersion("readr")
args = commandArgs(trailingOnly=TRUE)

seqtable_out_rds <- args[1]
seqtable_out_tsv <- args[2]
seqtab_paths <- args[3:length(args)]

load_seqtables <- function(seqtab_paths){
  seqtables <- list()
  i = 1
  for (path in seqtab_paths){
    print(paste('Loading seqtable', i , 'of', length(seqtab_paths)))
  
    seqtab_in <- readRDS(path, refhook = NULL)
    if (class(seqtab_in) != "matrix" | nrow(seqtab_in) == 0 | ncol(seqtab_in) == 0){
      print(paste("Warning, sequence table is incomplete, ignoring:", path))
    }else{
      seqtables[[i]] <- seqtab_in
      i = i+1
    }
  }
  return(seqtables)
}

seqtabs <- load_seqtables(seqtab_paths)

merged_seqtab <- do.call(mergeSequenceTables, seqtabs)
print("Dimensions of merged sequence table:")

print(table(nchar(getSequences(merged_seqtab))))
saveRDS(merged_seqtab, seqtable_out_rds) # CHANGE ME to where you want sequence table saved
write_tsv(data.frame(merged_seqtab), seqtable_out_tsv) # CHANGE ME to where you want sequence table saved
