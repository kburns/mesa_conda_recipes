# MESA Conda Recipes

This repo contains in-progress work towards creating conda recipes for MESA build requirement and perhaps eventually MESA itself.

Current I'm trying to create a conda environment for osx that emulates the MESA SDK and allows for MESA to be built.

## Procedure

```
# Create mesa_sdk conda environment
conda env create -f mesa_sdk_env.yaml

# Install extra dependencies (after building the recipes with `conda build`)
conda install -n mesa_sdk --use-local ndiff
conda install -n mesa_sdk --use-local makedepf90

# Point to 10.9 SDK (see note on building crlibm)
export CONDA_BUILD_SYSROOT=/opt/MacOSX10.9.sdk

# Attempt MESA installation
export MESA_DIR=~/Software/mesa-r10398
cd $MESA_DIR
./clean
./install
```


