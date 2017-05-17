import sys, os
from os.path import join
from glob import glob

def main(sample_dir):
    samples = glob(join(sample_dir, '*'))
    for samp in samples:
        print(samp)


if __name__ == '__main__':
    sample_dir = sys.argv[1]

    main(sample_dir)