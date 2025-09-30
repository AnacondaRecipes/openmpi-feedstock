#!/bin/bash

# unset unused old fortran compiler vars
unset F90 F77

set -e

export FCFLAGS="$FFLAGS"

# avoid absolute-paths in compilers
export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")

./autogen.pl --force

EXTRA_CONF=
if [ $(uname) == Darwin ]; then
    if [[ ! -z "$CONDA_BUILD_SYSROOT" ]]; then
        export CFLAGS="$CFLAGS -isysroot $CONDA_BUILD_SYSROOT"
        export CXXFLAGS="$CXXFLAGS -isysroot $CONDA_BUILD_SYSROOT"
    fi
    export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"

    # fix #include <version> issue on mac
    # VERSION (no ext) is included from the top-level repo dir for c++
    # xref: https://github.com/open-mpi/ompi/issues/7155
    # fix by renaming VERSION to VERSION.sh
    # grep -l '/VERSION' -R . | xargs sed -i "" s@/VERSION@/VERSION.sh@g
    mv -v VERSION VERSION.sh
    sed -i "" s@/VERSION@/VERSION.sh@g configure
    EXTRA_CONF="--disable-builtin-atomics"
fi

export LIBRARY_PATH="$PREFIX/lib"

# ==== detect OMPI major from VERSION ====
# if major <5, then adding binding --enable-mpi-cxx. Since version =>5 droped this option
OMPI_MAJOR=""
if [[ -f VERSION ]]; then
  OMPI_MAJOR="$(awk -F= '/^[[:space:]]*major[[:space:]]*=/ {gsub(/[[:space:]]/, "", $2); print $2; exit}' VERSION)"
fi

MPI_CXX_FLAG=""
if [[ -n "$OMPI_MAJOR" && "$OMPI_MAJOR" -lt 5 ]]; then
  if ./configure --help 2>/dev/null | grep -q -- '--enable-mpi-cxx'; then
    MPI_CXX_FLAG="--enable-mpi-cxx"
  fi
fi

./configure --prefix="${PREFIX}" \
  --disable-dependency-tracking \
  ${EXTRA_CONF} \
  --enable-ipv6 \
  ${MPI_CXX_FLAG} \
  --enable-mpi-fortran \
  --disable-wrapper-rpath \
  --disable-wrapper-runpath \
  --with-wrapper-cflags="-I${PREFIX}/include" \
  --with-wrapper-cxxflags="-I${PREFIX}/include" \
  --with-wrapper-fcflags="-I${PREFIX}/include" \
  --with-wrapper-ldflags="-L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib" \
  --with-sge

make -j"${CPU_COUNT:-1}"
make install
