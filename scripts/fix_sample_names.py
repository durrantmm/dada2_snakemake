import sys, os
from os.path import join
from glob import glob

def main(sample_dir):
    samples = glob(join(sample_dir, '*'))
    for samp in samples:
        s = samp.split('R1')
        if len(samp) > 1:
            s = s[0]
            s = s.strip('_').strip('-').strip('.')
            print(s, '.fastq.gz')
        else:
            s = s[0].split('R2')
            s = s[0]
            s = s.strip('_').strip('-').strip('.')
            print(s, '.fastq.gz')


if __name__ == '__main__':
    sample_dir = sys.argv[1]

    main(sample_dir)