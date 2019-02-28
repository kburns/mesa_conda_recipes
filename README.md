# MESA Conda Recipes

This repo contains in-progress work towards creating conda recipes for MESA build requirement and perhaps eventually MESA itself.

Current I'm trying to create a conda environment for osx that emulates the MESA SDK and allows for MESA to be built.

## Procedure

```
# Create mesa_sdk conda environment
conda env create -f mesa_sdk_env.yaml
conda activate mesa_sdk

# Install extra dependencies (after building the recipes with `conda build`)
conda install --use-local ndiff
conda install --use-local makedepf90

# Get rid of libgfortran.3
conda uninstall --force libgfortan-ng
conda uninstall --force libgfortran
conda install libgfortran

# Point to 10.9 SDK
export CONDA_BUILD_SYSROOT=/opt/MacOSX10.9.sdk

# Point to cpp
export CPP=cpp

# Attempt MESA installation
export MESA_DIR=~/Software/mesa-r10398
cd $MESA_DIR
./clean
./install
```

## Status

The installation is currently failing on testing mtx with the error
```
/Users/kburns/Software/mesa-r10398/mtx/test
TEST FAILED -- compare test_output to tmp.txt
```

## Notes

### conda build

We're building ndiff and makedepf90 using the conda-managed clang and gfortran compilers.
For these to work, we need an old(?) mac SDK from [here](https://github.com/phracker/MacOSX-SDKs).

### rpath

Initially the installation was failing on the const module tests.
Inspecting the tester object linking showed that the conda-supplied gfortran compiler was building object files with rpath-relative load commands, but not setting rpath.
To fix this, I modified the makefile_header to supply the rpath as an additional linker argument.

### crlibm arch

The installation was failing on building crlibm with an issue relating to trying to target i386 and not finding x86_64 symbols with the 10.14 SDK inside xcode.
This was fixed by setting `CONDA_BUILD_SYSROOT=/opt/MacOSX10.9.sdk`.

### crlibm bad integer

The installation was failing on testing crlibm with a fortran read error due to the linker linking to libgfortran.3.dylib, provided by the libgfortran-ng conda package, which was being pulled in by lapack.
Uninstalling the libgfortran-ng conda package and reinstalling the libgfortran conda package results in it hitting libgfortran.4.dylib, and proceeding.

### mtx cpp error

The installation was failing because CPP was not set.  Fixed by setting `export CPP=cpp`.

