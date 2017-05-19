configfile: "config.yaml"

import os, sys
from os.path import basename, join
from glob import glob

WD = config['wd']

FASTQ_DIR = join(WD, config['orig_fastqs'])

FILTERED_FASTQ_DIR = join(WD, config['filtered_fastqs'])
ERROR_MODEL_DIR = join(WD, config['error_model_dir'])
SEQTABS_DIR = join(WD, config['seqtables_dir'])
MERGED_SEQTAB_DIR = join(WD, config['merged_seqtab_dir'])
TAXONOMY_DIR = join(WD, config['taxonomy_dir'])

SAMPLES = glob_wildcards('{fastq_dir}/{{sample}}.{{pair}}.fastq.gz'.format(fastq_dir=FASTQ_DIR)).sample
PAIRS = ['R1', 'R2']
FWD_REV = ['FWD','REV']


def iter_samples(samples):
    for batch in SAMPLES:
        for samp in SAMPLES[batch]:
            yield (batch, samp)


print(len(SAMPLES))
sys.exit()
samps_fwd = expand('{dir}/{fr}/{{sample}}.{pair}.fastq.gz'.format(dir=FILTERED_FASTQ_DIR, fr=FWD_REV[0], pair=PAIRS[0]), sample=SAMPLES)
samps_rev = expand('{dir}/{fr}/{{sample}}.{pair}.fastq.gz'.format(dir=FILTERED_FASTQ_DIR, fr=FWD_REV[1], pair=PAIRS[1]), sample=SAMPLES)


rule all:
    input:
        samps_fwd,
        samps_rev
    run:
        print("FINISHED SUCCESSFULLY.")


rule filter_and_trim:
    input:
        r1 = "{fq_dir}/{{sample}}.{pair}.fastq.gz".format(fq_dir=FASTQ_DIR, pair=PAIRS[0]),
        r2 = "{fq_dir}/{{sample}}.{pair}.fastq.gz".format(fq_dir=FASTQ_DIR, pair=PAIRS[1])
    output:
        r1 = "{fq_dir}/{fwdrev}/{{sample}}.{pair}.fastq.gz".format(fq_dir=FILTERED_FASTQ_DIR, fwdrev=FWD_REV[0], pair=PAIRS[0]),
        r2 = "{fq_dir}/{fwdrev}/{{sample}}.{pair}.fastq.gz".format(fq_dir=FILTERED_FASTQ_DIR, fwdrev=FWD_REV[1], pair=PAIRS[1])
    shell:
        "Rscript scripts/filter_and_trim.R {input} {output}"


rule learn_errors:
    input:
        '{dir}/{fr}/{{sample}}.{{pair}}.fastq.gz'.format(dir=FILTERED_FASTQ_DIR, fr=FWD_REV[0], pair=PAIRS[0])
    output:
        '{error_dir}/errors.RData'.format(error_dir=ERROR_MODEL_DIR)
    shell:
        'Rscript scripts/error_model.R {output} {input}'
