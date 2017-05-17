import sys, os
from os.path import join, abspath
from glob import glob

def main(sample_dir):
    samples = glob(join(sample_dir, '*'))
    for samp in samples:
        samp = abspath(samp)

        s = samp.split('R1')

        if len(samp) > 1:
            s = s[0]
            s = s.strip('_').strip('-').strip('.')

            new = s + '.R1.fastq.gz'
            print(samp, new)
        else:
            s = s[0].split('R2')
            s = s[0]
            s = s.strip('_').strip('-').strip('.')

            new = s + '.R2.fastq.gz'
            print(samp, new)


if __name__ == '__main__':
    sample_dir = sys.argv[1]

    main(sample_dir)