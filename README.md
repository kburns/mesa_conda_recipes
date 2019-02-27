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

# Activate environment
conda activate mesa_sdk

# Point to 10.9 SDK (see note on crlibm arch)
export CONDA_BUILD_SYSROOT=/opt/MacOSX10.9.sdk

# Attempt MESA installation
export MESA_DIR=~/Software/mesa-r10398
cd $MESA_DIR
./clean
./install
```

## Status

The installation is currently failing on testing crlibm with the error
```
 Error in crlibm str_to_double exponent for '-1.6346727726351920E+12 ' got '12' ierr=        5010
At line 423 of file ../public/crlibm_lib.f
Fortran runtime error: Bad integer for item 1 in list input
```

## Notes

### conda-build

We're building ndiff and makedepf90 using the conda-managed clang and gfortran compilers.
For these to work, we need an old(?) mac SDK from [here](https://github.com/phracker/MacOSX-SDKs).

### rpath

Initially the installation was failing on the const module tests.
Inspecting the tester object linking showed that the conda-supplied gfortran compiler was building object files with rpath-relative load commands, but not setting rpath.
To fix this, I modified the makefile_header to supply the rpath as an additional linker argument.

### crlibm arch

The installation was failing on building crlibm with an issue relating to trying to target i386 and not finding x86_64 symbols with the 10.14 SDK inside xcode.
This was fixed by setting `CONDA_BUILD_SYSROOT=/opt/MacOSX10.9.sdk`.


