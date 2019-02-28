# MESA Conda Recipes

This repo contains in-progress work towards creating conda recipes for MESA build requirement and perhaps eventually MESA itself.

Current I'm trying to create a conda environment for osx that emulates the MESA SDK and allows for MESA to be built.

## Procedure

With conda compilers:

```
# Build dependencies
conda build ndiff
conda build makedepf90

# Create mesa_sdk conda environment
conda env create -f mesa_sdk_env.yaml
conda activate mesa_sdk

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

With homebrew compilers:

```
# Build dependencies
conda build ndiff
conda build makedepf90

# Create mesa_sdk conda environment
conda env create -f mesa_sdk_env.yaml
conda activate mesa_sdk

# Point to 10.9 SDK
export CONDA_BUILD_SYSROOT=/opt/MacOSX10.9.sdk

# Point to cpp
export CPP=/usr/local/bin/cpp-8

# Attempt MESA installation
export MESA_DIR=~/Software/mesa-r10398
cd $MESA_DIR
./clean
./install
```

## Status

The installation is currently failing on making the star module with the error

```
../private/star_private_def.f90:203:47:

../private/star_private_def.f90:199:37:

          do i=1,num_termination_codes
                                     2
../private/star_private_def.f90:203:47:

                      trim(termination_code_str(i-1)), i
                                               1
Error: Array reference at (1) out of bounds (0 < 1) in loop beginning at (2) [-Werror=do-subscript]
../private/star_private_def.f90:296:80:

../private/star_private_def.f90:293:23:

          do i=1,numTlim
                       2
../private/star_private_def.f90:296:80:

                   write(*,2) 'missing dt_why_str following ' // trim(dt_why_str(i-1)), i
                                                                                1
Error: Array reference at (1) out of bounds (0 < 1) in loop beginning at (2) [-Werror=do-subscript]
f951: all warnings being treated as errors
make: *** [star_private_def.o] Error 1
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

### mtx test error

The installation was failing on testing mtx with a comparison error.
To avoid, I'm just going to try moving towards homebrew compilers rather than keep working on the overlapping clang/gcc/gfortran issues from conda on mac.

