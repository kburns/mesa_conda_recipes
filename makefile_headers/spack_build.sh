
setconda
export PATH=/Users/kburns/Git/spack/opt/spack/darwin-highsierra-x86_64/clang-10.0.0-apple/gcc-7.2.0-sz7sntwz2ah34mmbcepy6s2vls3wrrjr/bin:$PATH

conda create -n spack_mesa
conda activate spack_mesa
conda install -c conda-forge valgrind ffmpeg
conda install --use-local ndiff makedepf90
conda install -c conda-forge openblas
conda install -c conda-forge hdf5 pgplot
