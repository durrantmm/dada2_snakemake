configfile: "config.yaml"

import os, sys
from os.path import basename, join
from glob import glob

WD = config['working_dir']

FASTQ_DIR = join(WD, config['orig_fastqs'])

FILTERED_FASTQ_DIR = join(WD, config['filtered_fastqs'])
ERROR_MODEL_DIR = join(WD, config['error_model_dir'])
SEQTABS_DIR = join(WD, config['seqtables_dir'])
MERGED_SEQTAB_DIR = join(WD, config['merged_seqtab_dir'])
TAXONOMY_DIR = join(WD, config['taxonomy_dir'])

BATCHES = [basename(p) for p in glob(join(FASTQ_DIR, "*"))]
SAMPLES = {batch: glob_wildcards('{fastq_dir}/{batch}/{{sample}}.{{pair}}.fastq.gz'.format(fastq_dir=FASTQ_DIR, batch=batch)).sample
           for batch in BATCHES}
PAIRS = ['R1', 'R2']
FWD_REV = ['FWD','REV']


def iter_samples(samples):
    for batch in SAMPLES:
        for samp in SAMPLES[batch]:
            yield (batch, samp)


samps_fwd = ['{dir}/{batch}/{fr}/{sample}.{pair}.fastq.gz'.format(dir=FILTERED_FASTQ_DIR, fr=FWD_REV[0], batch=batch, pair=PAIRS[0], sample=sample) for batch, sample in iter_samples(SAMPLES)]
samps_rev = ['{dir}/{batch}/{fr}/{sample}.{pair}.fastq.gz'.format(dir=FILTERED_FASTQ_DIR, fr=FWD_REV[1], batch=batch, pair=PAIRS[1], sample=sample) for batch, sample in iter_samples(SAMPLES)]

rule all:
    input:
        samps_fwd + samps_rev
    run:
        print("FINISHED SUCCESSFULLY.")

rule filter_and_trim:
    input:
        r1 = "{fq_dir}/{{batch}}/{{sample}}.{pair}.fastq.gz".format(fq_dir=FASTQ_DIR, pair=PAIRS[0]),
        r2 = "{fq_dir}/{{batch}}/{{sample}}.{pair}.fastq.gz".format(fq_dir=FASTQ_DIR, pair=PAIRS[1])
    output:
        r1 = "{fq_dir}/{{batch}}/{fwdrev}/{{sample}}.{pair}.fastq.gz".format(fq_dir=FILTERED_FASTQ_DIR, fwdrev=FWD_REV[0], pair=PAIRS[0]),
        r2 = "{fq_dir}/{{batch}}/{fwdrev}/{{sample}}.{pair}.fastq.gz".format(fq_dir=FILTERED_FASTQ_DIR, fwdrev=FWD_REV[1], pair=PAIRS[1])
    shell:
        "Rscript scripts/filter_and_trim.R {input} {output}"


rule learn_errors:
    input:
        expand('{dir}/{batch}/{fr}/{{sample}}.{pair}.fastq.gz'.format(dir=FILTERED_FASTQ_DIR,
                                                                    fr=FWD_REV[0],
                                                                    batch='{batch}',
                                                                    pair=PAIRS[0]),
                                                                    sample=sample),
        expand('{dir}/{batch}/{fr}/{sample}.{pair}.fastq.gz'.format(dir=FILTERED_FASTQ_DIR,
                                                                    fr=FWD_REV[1],
                                                                    batch='{batch}',
                                                                    pair=PAIRS[1]),
                                                                    sample=SAMPLES['{batch}']})
    output:
        '{error_dir}/{{batch}}/errors.RData'.format(error_dir=ERROR_MODEL_DIR)
    shell:
        'Rscript scripts/error_model.R {output} {input}'
