if (!("dada2" %in% installed.packages()[,"Package"])){
  source("https://bioconductor.org/biocLite.R")
  biocLite("dada2")  
}
library(dada2); packageVersion("dada2")

args = commandArgs(trailingOnly=TRUE)

error_rdata <- args[1]
files <- args[2:length(args)]
FWD.fastqs <- files[1:(length(files)/2)]
REV.fastqs <- files[((length(files)/2)+1):length(files)]

dir.create(dirname(error_rdata))

# Learn forward error rates
print("Learning forward error rates from 2 million reads...")
errF <- learnErrors(FWD.fastqs, nread=2e6, multithread=TRUE)

# Learn reverse error rates
print("Learning reverse error rates from 2 million reads...")
errR <- learnErrors(REV.fastqs, nread=2e6, multithread=TRUE)

print("Saving error rates...")
save(errF, errR, file=error_rdata)