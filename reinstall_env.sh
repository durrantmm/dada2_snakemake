source deactivate dada2
conda remove -n dada2 --all --yes
conda env create -f environment.yaml
source activate dada2