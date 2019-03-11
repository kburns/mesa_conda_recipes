# MESA Conda Recipes

This repo contains in-progress work towards creating conda recipes for MESA build requirement and perhaps eventually MESA itself.

Current I'm trying to create a conda environments for osx and linux that emulate the MESA SDK and allow for MESA to be built.

## Working builds

### osx

- **11532 + homebrew GCC 8.3 (working)**:
    - Works with homebrew hdf5, pgplot, openblas, and lapack.
        - Prints various bounds warnings.
        - Installation completes and tutorial model runs successfully.

- **11035 + homebrew GCC 8.3 (working)**:
    - Works with homebrew hdf5, pgplot, and openblas.
        - Fails tests in mtx and net with small numerical differences.
        - Prints various bounds warnings.
        - If tests are skipped, installation completes and tutorial model runs successfully.`.
    - Works with homebrew hdf5, pgplot, openblas, and lapack.
        - Prints various bounds warnings.
        - Installation completes and tutorial model runs successfully.

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

### linux

- **11532 + conda GCC 7.3 (working)**:
    - Working with conda hdf5, pgplot, and openblas.
        - Lapack installed but openblas gets picked up by linker.
        - Fails tests in mtx and net with small numerical differences.
        - If tests are skipped, installation completes and tutorial model runs successfully.
        - To get plots, X11 forwarding must be enabled in SSH to server and to worker inside salloc.
        
- **11035 + conda GCC 7.3 (working)**:
    - Working with conda hdf5, pgplot, and openblas.
        - Lapack installed but openblas gets picked up by linker.
        - Fails tests in mtx and net with small numerical differences.
        - If tests are skipped, installation completes and tutorial model runs successfully.
        - To get plots, X11 forwarding must be enabled in SSH to server and to worker inside salloc.

## Failing builds

### osx

- **11035 + homebrew GCC 7.4 (failing)**:
    - Need to disable HDF5 since homebrew version is built with GCC 8.3.
    - Installation fails on building the kap module saying it needs HDF5, even though it is disabled in the makefile_header:
    ```
    ../private/kap_aesopus.f90:28:6:
       use hdf5
    ```

- **10398 + homebrew GCC 8.3 (failing)**:
    - Fails with homebrew hdf5, pgplot, and openblas:
        - Fails tests in mtx and net with small numerical differences.
        - Raises errors on various bounds warnings.
        - If tests are skipped and `-Werror` flag is removed, installation completes but tutorial model segfaults.

- **10398 + homebrew GCC 7.4 (failing)**:
    - Need to disable HDF5 since homebrew version is build with GCC 8.3.
    - Fails with homebrew pgplot and openblas:
        - Fails tests in mtx, net and rates with small numerical differences.
        - If tests are skipped, installation completes but tutorial model segfaults.
    - Fails with homebrew pgplot, openblas, and lapack:
        - Fails tests in rates with small numerical differences.
        - If tests are skipped, installation completes but tutorial model segfaults.

### linux

- **10398 + conda GCC 7.3 (failing)**:
    - Fails with conda hdf5, pgplot, and openblas:
        - Lapack installed but openblas gets picked up by linker.
        - Fails tests in mtx and net with small numerical differences.
        - If tests are skipped, installation completes but tutorial model segfaults.

## Procedure

### osx

1. Install homebrew packages for gcc, openblas, lapack, hdf5, and pgplot.
2. Download MESA to `~/Software/mesa-r11532`.
3. Replace the makefile_header with a symlink to the one from this repo (backup the original first, if you want):
    ```
    ln -nsf $PWD/makefile_headers/mh_brew_osx_r11532 ~/Software/mesa-r11532/utils/makefile_header
    ```
4. Build the conda environemnt:
    ```
    conda env create -f env_brew_osx.yaml
    ```
5. Activate the environment to install and use MESA:
    ```
    # Activate environment
    conda activate mesa_brew

    # Attempt MESA installation
    export MESA_DIR=~/Software/mesa-r11532
    cd $MESA_DIR
    export DYLD_LIBRARY_PATH=../../make:../make:$MESA_DIR/lib:$DYLD_LIBRARY_PATH
    ./clean
    ./install
    ```

### linux

1. Download MESA to `~/Software/mesa-r11532`.
2. Replace the makefile_header with a symlink to the one from this repo (backup the original first, if you want):
    ```
    ln -nsf $PWD/makefile_headers/mh_conda_linux_r11532 ~/Software/mesa-r11532/utils/makefile_header
    ```
3. Build the conda environemnt:
    ```
    conda env create -f env_conda_linux.yaml
    ```
4. Activate the environment to install and use MESA:
    ```
    # Activate environment
    conda activate mesa_conda

    # Attempt MESA installation
    export MESA_DIR=~/Software/mesa-r11532
    cd $MESA_DIR
    ./clean
    ./install
    ```

## Future goals/plans

- Get osx build working with conda-supplied compilers.
- Get linux build working for 11532.
- Get linux build to use lapack instead of openblas from conda.
- Convert envs to mesa-sdk conda recipes
- Build conda recipe for mesa
- Build conda recipe for pymesa

## Development notes

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

### Numerical test failures

The tests seem to fail with small numerical errors in the conda and brew builds when openblas's lapack library is picked up instead of the standalone lapack.
It's easy to fix this in the brew builds, but its not clear how to do it with the conda builds, since they both put their libraries in the same place.

