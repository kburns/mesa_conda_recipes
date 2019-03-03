# MESA Conda Recipes

This repo contains in-progress work towards creating conda recipes for MESA build requirement and perhaps eventually MESA itself.

Current I'm trying to create a conda environment for osx that emulates the MESA SDK and allows for MESA to be built.

## Status

### osx

- **11035 + homebrew GCC 8.3 + homebrew HDF5**:
    Installation completes with various warnings but seems to pass all tests.
    Fails when running the tutorial model with
    ```
     PGPLOT_DIR is not set in your shell
     check_window ierr          -1
     onScreen_Plots ierr          -1

                                   finished relax_num_steps

     failed in do_relax_num_steps
     star_create_pre_ms_model ierr          -1
     do_load1_star ierr          -1
     before_evolve_loop ierr          -1
    ```
    
- **11035 + homebrew GCC 7.4**:
    Need to disable HDF5 since homebrew version is built with GCC 8.3.
    Installation fails on building the kap module saying it needs HDF5, even though it is disabled in the makefile_header:
    ```
    ```

- **10398 + homebrew GCC 8.3 + homebrew HDF5**:
    Installation produces various warnings and will only complete by removing `-Werror` flag.
    However the code segfaults when running the tutorial model.
    
- **10398 + homebrew GCC 7.4**:
    Need to disable HDF5 since homebrew version is build with GCC 8.3.
    Installation completes with `-Werror` flag and without previous warnings, but still segfaulst on running the tutorial model.

## Procedure

### osx

1. Install the osx 10.9 SDK from [here](https://github.com/phracker/MacOSX-SDKs) to `/opt/MacOSX10.9.sdk`.
2. Install homebrew packages for gcc, openblas, lapack, hdf5, and pgplot.
3. Download MESA to `~/Software/mesa-r10398`.
4. Replace the makefile_header with a symlink to the one from this repo (backup the original first, if you want):
    ```
    ln -sfn $PWD/makefile_headers/mh_conda_osx_r10398 ~/Software/mesa-r10398/utils/makefile_header
    ```
5. Build the conda dependencies and environemnt:
    ```
    conda build ndiff_recipe
    conda build makedepf90_recipe
    conda env create -f mesa_sdk_env.yaml
    ```
6. Activate the environment to install and use MESA:
    ```
    # Activate environment
    conda activate mesa_sdk

    # Attempt MESA installation
    export MESA_DIR=~/Software/mesa-r10398
    cd $MESA_DIR
    ./clean
    ./install
    ```

## Future goals/plans

* Figure out and fix source of compiler warnings so we dont have to remove `-Werror`
* Migrate remaining osx dependencies from homebrew to conda:
    * pgplot
    * hdf5
    * lapack
    * blas
    * gcc
* Get conda linux build working
* Submit conda packages:
    * ndiff
    * makedepf90
    * mesa (eventually)
* Add gyre support

## Development notes

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

### GCC 7 vs 8

Compiling with GCC 8.3 from homebrew yields various array-bounds, do-subscript, stringop-overflow warnings.
Removing `-Werror` will prevent these from halting the installation.
The installation then seems to complete and the tests seem to pass, but the code segfaults upon running the tutorial model.

Comping with GCC 7.4 eliminates the warnings and allows compilation to complete with the `-Werror` flag, but the same segfault still occurs.
I'm going to the 11035 prelease to see if that works with GCC > 7.2, since it also seems to be better supported by pyMesa.

