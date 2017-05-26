if (!("dada2" %in% installed.packages()[,"Package"])){
  source("https://bioconductor.org/biocLite.R")
  biocLite("dada2")  
}
library(dada2); packageVersion("dada2")
library(readr); packageVersion("readr")
args = commandArgs(trailingOnly=TRUE)

seqtab <- readRDS(args[1], refhook = NULL)
rdp_train_set <- args[2]
rdp_species_train_set <- args[3]
rdp_taxa_out_rds <- args[4]

print("Assigning initial taxonomies using rdp training set...")

rdp.taxa <- assignTaxonomy(seqtab, rdp_train_set, verbose=TRUE)
print("Assigning species using rdp training set...")
rdp.taxa <- addSpecies(rdp.taxa, rdp_species_train_set, verbose=TRUE)

rdp.taxa.df <- data.frame(rdp.taxa)
rdp.taxa.df$Sequence <- rownames(rdp.taxa)

print("Saving data from rdp taxonomy assignments...")
saveRDS(rdp.taxa, rdp_taxa_out_rds) # CHANGE ME to where you want sequence table saved
