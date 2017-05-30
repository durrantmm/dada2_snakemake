if (!("dada2" %in% installed.packages()[,"Package"])){
  source("https://bioconductor.org/biocLite.R")
  biocLite("dada2")  
}
library(dada2); packageVersion("dada2")
library(readr); packageVersion("readr")
args = commandArgs(trailingOnly=TRUE)

seqtab <- readRDS(args[1], refhook = NULL)
seqtab_out_rds <- args[2]
seqtab_out_tsv <- args[3]

print("Removing bimeric sequences...")
seqtab <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE)

print("Writing to file...")
saveRDS(seqtab, seqtab_out_rds) 

seqtab_tsv <- cbind(data.frame(ID=rownames(data.frame(seqtab))), 
                           data.frame(seqtab)) 
write_tsv(seqtab_tsv, seqtab_out_tsv) 