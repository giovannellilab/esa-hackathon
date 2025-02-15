# Installation guide

### Creating the environment

```bash
mamba create -n esa-hack -y

mamba activate esa-hack
```


### Installing required packages

```bash
pip install requests
mamba install -c conda-forge ncbi-datasets-cli antismash pandas ipykernel -y
mamba install -c bioconda ncbi-genome-download -y
```


### Setting up antiSMASH

```bash
# (ONLY FOR MAC) Fix nrpys installation (https://apple.stackexchange.com/a/443379)
pip uninstall nrpys
ARCHFLAGS="-arch arm64" pip install nrpys --compile --no-cache-dir
```

```bash
# Fix bcbio-gff installation (https://github.com/antismash/antismash/issues/713#issuecomment-2137807803)
mamba install bcbio-gff=0.7.0
```

```bash
# Download antiSMASH databases
download-antismash-databases
```


## Additional dependencies

The `parallel`, `rename` and `wget` command line tools are required in order to run the scripts:

```bash
mamba install conda-forge::parallel bioconda::rename anaconda::wget -y
```
