configfile: "config.yaml"

import os, sys
from os.path import basename, join
from glob import glob

WD = config['working_dir']
ORIG_FASTQ_DIR = join(WD, config['orig_fastqs'])
FILTERED_FASTQ_DIR = join(WD, config['filtered_fastqs'])
ERROR_MODEL_DIR = join(WD, config['error_model_dir'])
SEQTABS_DIR = join(WD, config['seqtables_dir'])
MERGED_SEQTAB_DIR = join(WD, config['merged_seqtab_dir'])
TAXONOMY_DIR = join(WD, config['taxonomy_dir'])

WC = glob_wildcards(join(ORIG_FASTQ_DIR, "{batch}/{sample}.{pair}.fastq.gz"))

print(WC.batch)
print(WC.sample)
print(WC.pair)

rule all:
    input:
        "hello"

rule filter_and_trim:
    input:
        r1 = "{fq_dir}/{{sample}}.{pair}.fastq.gz".format(fq_dir=ORIG_FASTQ_DIR, pair=PAIRS[0]),
        r2 = "{fq_dir}/{{sample}}.{pair}.fastq.gz".format(fq_dir=ORIG_FASTQ_DIR, pair=PAIRS[1])
    output:
        r1 = "{fq_dir}/{fwdrev}/{{sample}}.{pair}.fastq.gz".format(fq_dir=FILTERED_FASTQ_DIR, fwdrev=FWD_REV[0], pair=PAIRS[0]),
        r2 = "{fq_dir}/{fwdrev}/{{sample}}.{pair}.fastq.gz".format(fq_dir=FILTERED_FASTQ_DIR, fwdrev=FWD_REV[1], pair=PAIRS[1])
    shell:
        "Rscript scripts/filter_and_trim.R {{input.r1}} {{input.r2}} {output_dir}".format(output_dir=FILTERED_FASTQ_DIR)
