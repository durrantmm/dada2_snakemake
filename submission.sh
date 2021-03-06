#
# set the name of the job
#$ -N log_snakemake
#
# set the maximum memory usage (per slot)
#$ -l h_vmem=1G
#
# set the maximum run time
#$ -l h_rt=168:00:00
#
# send mail when job ends or aborts
#$ -m bea
#
# specify an email address
#$ -M mdurrant@stanford.edu
#
# specify the account name
#$ -A bhatt
#
# check for errors in the job submission options
#$ -w w
#
# output logfile
#$ -o log_snakemake
#
# Pass all environoment variables
#$ -V
#
#$ -cwd


snakemake --cluster-config cluster.json --cluster "qsub -V -l h_vmem={cluster.mem} -l h_rt={cluster.time} -A {cluster.account}" -j 200 -p --config wd=${wd}
