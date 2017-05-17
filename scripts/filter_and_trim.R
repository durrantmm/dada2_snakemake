library(dada2); packageVersion("dada2")
# File parsing
args = commandArgs(trailingOnly=TRUE)

FWD.fastq <- args[1]
REV.fastq <- args[2]
filtered_path <- args[3]
filtered_path.fwd <- file.path(filtered_path, "FWD")
filtered_path.rev <- file.path(filtered_path, "REV")

dir.create(filtered_path)
dir.create(filtered_path.fwd)
dir.create(filtered_path.rev)

print(paste("Filtering fastq files", FWD.fastq, "and", REV.fastq))
filterAndTrim(fwd=FWD.fastq, filt=file.path(filtered_path.fwd, basename(FWD.fastq)),
              rev=REV.fastq, filt.rev=file.path(filtered_path.rev, basename(REV.fastq)),
              trimLeft=10,
              truncLen=c(295,275), 
              maxEE=c(2, 6), 
              truncQ=2, 
              maxN=0,
              rm.phix=TRUE,
              compress=TRUE, 
              verbose=TRUE)