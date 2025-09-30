#!/bin/bash
set -ex

MPIEXEC="${PWD}/mpiexec.sh"

pushd "tests"

if [[ $PKG_NAME == "openmpi" ]]; then
  command -v ompi_info
  ompi_info

  command -v mpiexec
  $MPIEXEC --help
  $MPIEXEC -n 4 ./helloworld.sh
fi

if [[ $PKG_NAME == "openmpi-mpicc" ]]; then
  command -v mpicc
  mpicc -show

  mpicc $CFLAGS $LDFLAGS helloworld.c -o helloworld_c
  $MPIEXEC -n 4 ./helloworld_c
fi

if [[ $PKG_NAME == "openmpi-mpicxx" ]]; then
  command -v mpicxx
  mpicxx -show

  mpicxx $CXXFLAGS $LDFLAGS helloworld.cxx -o helloworld_cxx
  $MPIEXEC -n 4 ./helloworld_cxx
fi

if [[ $PKG_NAME == "openmpi-mpifort" ]]; then

  command -v mpifort
  echo "== mpifort -show =="; mpifort -show || true
  echo "== mpifort -showme:compile =="; mpifort -showme:compile || true
  echo "== mpifort -showme:link    =="; mpifort -showme:link || true

  if [[ "$(uname)" == "Darwin" ]]; then
    export FC=${FC:-gfortran}
    export F77=${F77:-gfortran}
    export F90=${F90:-gfortran}
    export OMPI_FC=${OMPI_FC:-gfortran}
    export OMPI_MCA_wrapper_verbose=100
    export MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-12.1}"
    export SDKROOT="${CONDA_BUILD_SYSROOT:-${SDKROOT:-/Library/Developer/CommandLineTools/SDKs/MacOSX12.1.sdk}}"
    export DYLD_LIBRARY_PATH="$PREFIX/lib:${DYLD_LIBRARY_PATH:-}"
    export OMPI_MCA_plm=isolated
    export OMPI_MCA_pml=ob1
    export OMPI_MCA_btl=self,tcp
    export OMPI_MCA_oob_tcp_if_include=lo0
    export OMPI_MCA_rmaps_base_oversubscribe=yes
    export OMPI_MCA_btl_vader_single_copy_mechanism=none

    gfortran helloworld.f -c -o hello_f.o $(mpifort -showme:compile)
    gfortran hello_f.o -o helloworld1_f  $(mpifort -showme:link)
    $MPIEXEC -n 4 ./helloworld1_f

    gfortran helloworld.f -c -o hello_f.o $(mpif77 -showme:compile)
    gfortran hello_f.o -o helloworld2_f $(mpif77 -showme:link)
    $MPIEXEC -n 4 ./helloworld2_f

    gfortran helloworld.f90 -c -o hello_f90.o $(mpif90 -showme:compile)
    gfortran hello_f90.o -o helloworld2_f90 $(mpif90 -showme:link)
    $MPIEXEC -n 4 ./helloworld2_f90

    exit 0
  fi

  mpifort ${FFLAGS:-} helloworld.f   -o helloworld1_f   ${LDFLAGS:-}
  $MPIEXEC -n 4 ./helloworld1_f

  mpifort ${FFLAGS:-} helloworld.f90 -o helloworld1_f90 ${LDFLAGS:-}
  $MPIEXEC -n 4 ./helloworld1_f90

  # Optionaly test old interfaces
  if command -v mpif77 >/dev/null 2>&1; then
    echo "== mpif77 -show =="; mpif77 -show || true
    mpif77  ${FFLAGS:-} helloworld.f   -o helloworld2_f   ${LDFLAGS:-}
    $MPIEXEC -n 4 ./helloworld2_f
  fi

  if command -v mpif90 >/dev/null 2>&1; then
    echo "== mpif90 -show =="; mpif90 -show || true
    mpif90  ${FFLAGS:-} helloworld.f90 -o helloworld2_f90 ${LDFLAGS:-}
    $MPIEXEC -n 4 ./helloworld2_f90
  fi
fi

popd
