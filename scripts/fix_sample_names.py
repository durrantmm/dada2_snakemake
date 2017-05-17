import sys, os
from os.path import join, abspath, basename
from glob import glob

def main(sample_dir):
    samples = glob(join(sample_dir, '*'))
    for samp in samples:
        samp = abspath(samp)

        s = samp.split('_R1_')

        if len(s) > 1:
            s = s[0]
            s = s.strip('_').strip('-').strip('.')

            new = s + '.R1.fastq.gz'
            print(basename(samp), basename(new))

        else:
            s = samp.split('_R2_')
            s = s[0]
            s = s.strip('_').strip('-').strip('.')

            new = s + '.R2.fastq.gz'
            print(basename(samp), basename(new))


if __name__ == '__main__':
    sample_dir = sys.argv[1]

    main(sample_dir)