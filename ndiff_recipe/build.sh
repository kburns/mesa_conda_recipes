# Setup required folders inside prefix
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/include
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/man/cat1
mkdir -p $PREFIX/man/man1
mkdir -p $PREFIX/share/lib/

./configure --prefix="$PREFIX"
make
make install
