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

SAMPLES = list(set(glob_wildcards('{fastq_dir}/{{sample}}.{{pair}}.fastq.gz'.format(fastq_dir=FASTQ_DIR)).sample))
PAIRS = ['R1', 'R2']
FWD_REV = ['FWD','REV']

samps_fwd = expand('{dir}/{fr}/{{sample}}.{pair}.fastq.gz'.format(dir=FILTERED_FASTQ_DIR, fr=FWD_REV[0], pair=PAIRS[0]), sample=SAMPLES)
samps_rev = expand('{dir}/{fr}/{{sample}}.{pair}.fastq.gz'.format(dir=FILTERED_FASTQ_DIR, fr=FWD_REV[1], pair=PAIRS[1]), sample=SAMPLES)


rule all:
    input:
        '{merged_seqtab_dir}/seqtab.rds'.format(merged_seqtab_dir=MERGED_SEQTAB_DIR),
        '{merged_seqtab_dir}/seqtab.tsv'.format(merged_seqtab_dir=MERGED_SEQTAB_DIR),
        expand('{taxonomy_dir}/{{sample}}.silva.rds'.format(taxonomy_dir=TAXONOMY_DIR), sample=SAMPLES),
        expand('{taxonomy_dir}/{{sample}}.rdp.rds'.format(taxonomy_dir=TAXONOMY_DIR), sample=SAMPLES)
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
        samps_fwd,
        samps_rev
    output:
        '{error_dir}/errors.RData'.format(error_dir=ERROR_MODEL_DIR)
    shell:
        'Rscript scripts/error_model.R {output} {input}'


rule sample_inference:
    input:
        error = '{error_dir}/errors.RData'.format(error_dir=ERROR_MODEL_DIR),
        r1 = "{fq_dir}/{fwdrev}/{{sample}}.{pair}.fastq.gz".format(fq_dir=FILTERED_FASTQ_DIR, fwdrev=FWD_REV[0], pair=PAIRS[0]),
        r2 = "{fq_dir}/{fwdrev}/{{sample}}.{pair}.fastq.gz".format(fq_dir=FILTERED_FASTQ_DIR, fwdrev=FWD_REV[1], pair=PAIRS[1])
    output:
        '{seqtab_dir}/{{sample}}.seqtab'.format(seqtab_dir=SEQTABS_DIR)
    shell:
        'Rscript scripts/sample_inference.R {input.error} {input.r1} {input.r2} {output}'


rule merge_seqtabs:
    input:
        expand('{seqtab_dir}/{{sample}}.seqtab'.format(seqtab_dir=SEQTABS_DIR), sample=SAMPLES)
    output:
        '{merged_seqtab_dir}/seqtab.rds'.format(merged_seqtab_dir=MERGED_SEQTAB_DIR),
        '{merged_seqtab_dir}/seqtab.tsv'.format(merged_seqtab_dir=MERGED_SEQTAB_DIR)
    shell:
        'Rscript scripts/merge_seqtabs.R {output} {input}'


rule assign_taxonomy_rdp:
    input:
        '{seqtab_dir}/{{sample}}.seqtab'.format(seqtab_dir=SEQTABS_DIR),
        config['rdp_train_set'],
        config['rdp_species_train_set']
    output:
        '{taxonomy_dir}/{{sample}}.rdp.rds'.format(taxonomy_dir=TAXONOMY_DIR)
    shell:
        'Rscript scripts/assign_taxonomies_rdp.R {input} {output}'


rule assign_taxonomy_silva:
    input:
        '{seqtab_dir}/{{sample}}.seqtab'.format(seqtab_dir=SEQTABS_DIR),
        config['silva_train_set'],
        config['silva_species_train_set']
    output:
        '{taxonomy_dir}/{{sample}}.silva.rds'.format(taxonomy_dir=TAXONOMY_DIR)
    shell:
        'Rscript scripts/assign_taxonomies_silva.R {input} {output}