library(dada2); packageVersion("dada2")
# File parsing
args = commandArgs(trailingOnly=TRUE)

FWD.fastq <- args[1]
REV.fastq <- args[2]
FWD.filtered_path <- args[3]
REV.filtered_path <- args[4]

dir.create(dirname(FWD.filtered_path), recursive=T)
dir.create(dirname(REV.filtered_path), recursive=T)

print(paste("Filtering fastq files", FWD.fastq, "and", REV.fastq))
filterAndTrim(fwd=FWD.fastq, filt=FWD.filtered_path,
              rev=REV.fastq, filt.rev=REV.filtered_path,
              trimLeft=10,
              truncLen=c(295,275), 
              maxEE=c(2, 6), 
              truncQ=2, 
              maxN=0,
              rm.phix=TRUE,
              compress=TRUE, 
              verbose=TRUE)