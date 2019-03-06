# MESA Conda Recipes

This repo contains in-progress work towards creating conda recipes for MESA build requirement and perhaps eventually MESA itself.

Current I'm trying to create a conda environments for osx and linux that emulate the MESA SDK and allow for MESA to be built.

## Status

### osx

- **10398 + spack GCC 7.2 (working)**:
    - Works with spack hdf5 and homebrew pgplot.
    - Works with spack openblas:
        - Fails tests in mtx and net with small numerical differences.
        - Fails tests in rates with large numerical differences.
        - If tests are skipped, installation completes and tutorial model runs successfully.
    - Works with spack veclibfort:
        - Fails tests in mtx, num, and net with small numerical differences.
        - Fails tests in rates with large numerical differences.
        - If tests are skipped, installation completes and tutorial model runs successfully.
    - Fails with mesa src blas/lapack:
        - Fails at mtx tests with various GNU extension errors:
            ```
            gfortran -Wno-uninitialized -fno-range-check -fmax-errors=12  -fprotect-parens -fno-sign-zero -fbacktrace -ggdb -finit-real=snan   -std=f2008 -Wno-error=tabs -I../public -I../private -I../../include  -Wunused-value -Werror -W -Wno-compare-reals -Wno-unused-parameter -fimplicit-none -O2 -c -ffixed-form -ffixed-line-length-132 -x f77-cpp-input -w ../blas_src/zdotc.f
            ../blas_src/zaxpy.f:60:16:
                COMPLEX*16 ZA
            Error: GNU Extension: Nonstandard type declaration COMPLEX*16 at (1)
            ```
    - Fails with conda hdf5, pgplot, or openblas with "undefined symbols" errors.

- **10398 + homebrew GCC 7.4 (failing)**:
    - Need to disable HDF5 since homebrew version is build with GCC 8.3.
    - Fails with homebrew pgplot and openblas:
        - Fails tests in mtx, net and rates with small numerical differences.
        - If tests are skipped, installation completes but tutorial model segfaults.
    - Fails with homebrew pgplot, openblas, and lapack:
        - Fails tests in rates with small numerical differences.
        - If tests are skipped, installation completes but tutorial model segfaults.

- **10398 + homebrew GCC 8.3 (failing)**:
    - Fails with homebrew hdf5, pgplot, and openblas:
        - Fails tests in mtx and net with small numerical differences.
        - Raises errors on various bounds warnings.
        - If tests are skipped and `-Werror` flag is removed, installation completes but tutorial model segfaults.

- **11035 + homebrew GCC 7.4 (failing)**:
    - Need to disable HDF5 since homebrew version is built with GCC 8.3.
    - Installation fails on building the kap module saying it needs HDF5, even though it is disabled in the makefile_header:
    ```
    ../private/kap_aesopus.f90:28:6:
       use hdf5
    ```

- **11035 + homebrew GCC 8.3 (working)**:
    - Works with homebrew hdf5, pgplot, and openblas.
        - Fails tests in mtx and net with small numerical differences.
        - Prints various bounds warnings.
        - If tests are skipped, installation completes and tutorial model runs successfully.`.
    - Works with homebrew hdf5, pgplot, openblas, and lapack.
        - Prints various bounds warnings.
        - Installation completes and tutorial model runs successfully.

### linux

- **10398 + conda GCC 7.3 + conda HDF5**:
    Building utils fails with the error:
    ```
    ../private/utils_openmp.f:38:13:

              use omp_lib, only: OMP_GET_THREAD_NUM
                 1
    Fatal Error: Can't open module file 'omp_lib.mod' for reading at (1): No such file or directory
    compilation terminated.
    make: *** [utils_openmp.o] Error 1

    /mnt/home/kburns/software/mesa-r10398/utils/make
    FAILED
    ```
    Might be related to [this issue](https://github.com/ContinuumIO/anaconda-issues/issues/8423), but it's not clear if it has been fixed for GCC < 8.

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

- [ ] Figure out and fix source of compiler warnings so we dont have to remove `-Werror`
- [ ] Migrate remaining osx dependencies from homebrew to conda:
    - [ ] pgplot
    - [ ] hdf5
    - [ ] lapack
    - [ ] blas
    - [ ] gcc
- [ ] Get conda linux build working
- [ ] Create conda packages:
    - [x] ndiff (merged into conda-forge)
    - [ ] makedepf90 (submitted to conda-forge)
    - [ ] mesa (eventually)
- [ ] Add gyre support

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

