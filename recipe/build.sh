#!/bin/bash

export LDFLAGS="$LDFLAGS -Wl,-rpath,${CONDA_PREFIX}/lib"

export FCFLAGS="$FFLAGS"
./configure --prefix=$PREFIX \
            --disable-dependency-tracking \
            --enable-mpi-cxx \
            --enable-mpi-fortran

make -j$CPU_COUNT
make install

if [[ $OSTYPE != darwin* ]]; then
    cp $RECIPE_DIR/../check-glibc.sh .
    bash check-glibc.sh $PREFIX/lib/ || exit 1
fi

