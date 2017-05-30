if (!("dada2" %in% installed.packages()[,"Package"])){
  source("https://bioconductor.org/biocLite.R")
  biocLite("dada2")  
}
library(dada2); packageVersion("dada2")
library(readr); packageVersion("readr")
args = commandArgs(trailingOnly=TRUE)

seqtab <- readRDS(args[1], refhook = NULL)
silva_train_set <- args[2]
silva_species_train_set <- args[3]
silva_taxa_out_rds <- args[4]

seqtab <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE)

print("Assigning initial taxonomies using silva training set...")
silva.taxa <- assignTaxonomy(seqtab, silva_train_set, allowMultiple=TRUE, 
                             verbose=TRUE, multithread=TRUE)

print("Assigning species using silva training set...")
silva.taxa <- addSpecies(silva.taxa, silva_species_train_set, allowMultiple=TRUE, 
                         verbose=TRUE, multithread=TRUE)
?addSpecies
silva.taxa.df <- data.frame(silva.taxa)
silva.taxa.df$Sequence <- rownames(silva.taxa)

print("Saving data from silva taxonomy assignments...")
saveRDS(silva.taxa, silva_taxa_out_rds) # CHANGE ME to where you want sequence table saved