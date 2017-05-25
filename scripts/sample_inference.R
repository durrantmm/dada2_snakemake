if (!("dada2" %in% installed.packages()[,"Package"])){
  source("https://bioconductor.org/biocLite.R")
  biocLite("dada2")  
}
library(dada2); packageVersion("dada2")
args = commandArgs(trailingOnly=TRUE)

error_rdata <- args[1]
fastq_fwd <- args[2]
fastq_rev <- args[3]
seqtab_out <- args[4]
 
dir.create(dirname(seqtab_out))

load(error_rdata, verbose = TRUE)

# Sample inference and merger of paired-end reads

print(paste("Processing:", fastq_fwd, "and", fastq_rev))

sample.name <- strsplit(basename(fastq_fwd), '[.]')[[1]][1]

# Sample inference and merger of paired-end reads
mergers <- vector("list", 1)
names(mergers) <- sample.name

print("Running dada2 derepFastq() on forward reads...")
derepF <- derepFastq(fastq_fwd)
print("Running dada2 dada() on forward reads...")
ddF <- dada(derepF, err=errF, multithread=TRUE, VERBOSE=T)

print("Running dada2 derepFastq() on reverse reads...")
derepR <- derepFastq(fastq_rev)
print("Running dada2 dada() on reverse reads...")
ddR <- dada(derepR, err=errR, multithread=TRUE, VERBOSE=T)

merger <- mergePairs(ddF, derepF, ddR, derepR)
mergers[[sample.name]] <- merger

rm(derepF); rm(derepR)

# Construct sequence table and remove chimeras
seqtab <- makeSequenceTable(mergers)
print(paste("Saving results to", seqtab_out))
saveRDS(seqtab, seqtab_out) 
