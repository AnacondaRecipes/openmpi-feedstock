#!/bin/bash
set -ex

if [[ "$(uname)" == "Darwin" ]]; then
  export MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-12.1}"
  export SDKROOT="${CONDA_BUILD_SYSROOT:-${SDKROOT:-/Library/Developer/CommandLineTools/SDKs/MacOSX12.1.sdk}}"
  export DYLD_LIBRARY_PATH="$PREFIX/lib:${DYLD_LIBRARY_PATH:-}"
  export OMPI_MCA_plm=isolated
  export OMPI_MCA_pml=ob1
  export OMPI_MCA_btl=self,tcp
  export OMPI_MCA_oob_tcp_if_include=lo0
  export OMPI_MCA_rmaps_base_oversubscribe=yes
  export OMPI_MCA_btl_vader_single_copy_mechanism=none
fi

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

# if [[ $PKG_NAME == "openmpi-mpifort" ]]; then
#   command -v mpifort
#   mpifort -show

#   mpifort $FFLAGS $LDFLAGS helloworld.f -o helloworld1_f
#   $MPIEXEC -n 4 ./helloworld1_f

#   mpifort $FFLAGS $LDFLAGS helloworld.f90 -o helloworld1_f90
#   $MPIEXEC -n 4 ./helloworld1_f90

#   command -v mpif77
#   mpif77 -show

#   mpif77 $FFLAGS $LDFLAGS helloworld.f -o helloworld2_f
#   $MPIEXEC -n 4 ./helloworld2_f

#   command -v mpif90
#   mpif90 -show

#   mpif90 $FFLAGS $LDFLAGS helloworld.f90 -o helloworld2_f90
#   $MPIEXEC -n 4 ./helloworld2_f90

# fi


if [[ $PKG_NAME == "openmpi-mpifort" ]]; then
  set -euo pipefail
  echo "== where am I =="
  pwd
  ls -lah .

  command -v mpifort
  echo "== mpifort -show =="; mpifort -show || true
  echo "== mpifort -showme:compile =="; mpifort -showme:compile || true
  echo "== mpifort -showme:link    =="; mpifort -showme:link || true

  # Проверим наличие исходников
  [[ -f helloworld.f ]]   || { echo "Нет tests/helloworld.f"; exit 1; }
  [[ -f helloworld.f90 ]] || { echo "Нет tests/helloworld.f90"; exit 1; }

  echo "== Сборка и запуск F77 (одним шагом) =="
  set -x
  mpifort ${FFLAGS:-} helloworld.f   -o helloworld1_f   ${LDFLAGS:-}
  set +x
  ls -l helloworld1_f
  set -x
  $MPIEXEC -n 4 ./helloworld1_f
  set +x

  echo "== Сборка и запуск F90 (одним шагом) =="
  set -x
  mpifort ${FFLAGS:-} helloworld.f90 -o helloworld1_f90 ${LDFLAGS:-}
  set +x
  ls -l helloworld1_f90
  set -x
  $MPIEXEC -n 4 ./helloworld1_f90
  set +x

  # Опционально — старые интерфейсы, если нужны:
  if command -v mpif77 >/dev/null 2>&1; then
    echo "== mpif77 -show =="; mpif77 -show || true
    set -x
    mpif77  ${FFLAGS:-} helloworld.f   -o helloworld2_f   ${LDFLAGS:-}
    $MPIEXEC -n 4 ./helloworld2_f
    set +x
  fi

  if command -v mpif90 >/dev/null 2>&1; then
    echo "== mpif90 -show =="; mpif90 -show || true
    set -x
    mpif90  ${FFLAGS:-} helloworld.f90 -o helloworld2_f90 ${LDFLAGS:-}
    $MPIEXEC -n 4 ./helloworld2_f90
    set +x
  fi
fi





popd
