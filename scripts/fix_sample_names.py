import sys, os
from os.path import join
from glob import glob

def main(sample_dir):
    samples = glob(join(sample_dir, '*'))
    for samp in samples:
        samp = samp.split('R1')
        if len(samp) > 1:
            print(samp[0], '.fastq.gz')
        else:
            samp = samp[0].split('R2')
            print(samp[0], '.fastq.gz')


if __name__ == '__main__':
    sample_dir = sys.argv[1]

    main(sample_dir)