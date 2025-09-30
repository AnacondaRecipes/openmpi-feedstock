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
#   echo "== mpifort -show =="; mpifort -show || true
#   echo "== mpifort -showme:compile =="; mpifort -showme:compile || true
#   echo "== mpifort -showme:link    =="; mpifort -showme:link || true

#   mpifort ${FFLAGS:-} helloworld.f   -o helloworld1_f   ${LDFLAGS:-}
#   $MPIEXEC -n 4 ./helloworld1_f

#   mpifort ${FFLAGS:-} helloworld.f90 -o helloworld1_f90 ${LDFLAGS:-}
#   $MPIEXEC -n 4 ./helloworld1_f90

#   # Optionaly test old interfaces
#   if command -v mpif77 >/dev/null 2>&1; then
#     echo "== mpif77 -show =="; mpif77 -show || true
#     mpif77  ${FFLAGS:-} helloworld.f   -o helloworld2_f   ${LDFLAGS:-}
#     $MPIEXEC -n 4 ./helloworld2_f
#   fi

#   if command -v mpif90 >/dev/null 2>&1; then
#     echo "== mpif90 -show =="; mpif90 -show || true
#     mpif90  ${FFLAGS:-} helloworld.f90 -o helloworld2_f90 ${LDFLAGS:-}
#     $MPIEXEC -n 4 ./helloworld2_f90
#   fi
# fi


# if [[ $PKG_NAME == "openmpi-mpifort" ]]; then
#   command -v mpifort
#   mpifort --version || true
#   which -a gfortran || true

#   if [[ "$(uname)" == "Darwin" ]]; then
#     export FC=${FC:-gfortran}
#     export F77=${F77:-gfortran}
#     export F90=${F90:-gfortran}
#     export OMPI_FC=${OMPI_FC:-gfortran}
#     export OMPI_MCA_wrapper_verbose=100
#   fi

#   echo "== mpifort -show =="
#   mpifort -show || true
#   echo "== mpifort -showme:compile =="
#   mpifort -showme:compile || true
#   echo "== mpifort -showme:link =="
#   mpifort -showme:link || true

#   set -x
#   mpifort ${FFLAGS:-} -c helloworld.f -o hello_f.o
#   ls -l hello_f.o
#   mpifort hello_f.o -o helloworld1_f ${LDFLAGS:-}
#   set +x

#   $MPIEXEC -n 4 ./helloworld1_f

#   if [[ -f helloworld.f90 ]]; then
#     set -x
#     mpifort ${FFLAGS:-} -c helloworld.f90 -o hello_f90.o
#     ls -l hello_f90.o
#     mpifort hello_f90.o -o helloworld1_f90 ${LDFLAGS:-}
#     set +x
#     $MPIEXEC -n 4 ./helloworld1_f90
#   fi

#   if command -v mpif77 >/dev/null 2>&1; then
#     mpif77 -show || true
#     set -x
#     mpif77 ${FFLAGS:-} -c helloworld.f -o hello_f77.o
#     mpif77 hello_f77.o -o helloworld2_f ${LDFLAGS:-}
#     set +x
#     $MPIEXEC -n 4 ./helloworld2_f
#   fi

#   if command -v mpif90 >/dev/null 2>&1; then
#     mpif90 -show || true
#     set -x
#     mpif90 ${FFLAGS:-} -c helloworld.f90 -o hello_f90b.o
#     mpif90 hello_f90b.o -o helloworld2_f90 ${LDFLAGS:-}
#     set +x
#     $MPIEXEC -n 4 ./helloworld2_f90
#   fi
# fi

# if [[ $PKG_NAME == "openmpi-mpifort" ]]; then
#   set -euo pipefail

#   command -v mpifort
#   mpifort --version || true
#   echo "== mpifort -show =="
#   mpifort -show || true
#   echo "== mpifort -showme:compile =="
#   CMP_FLAGS="$(mpifort -showme:compile 2>/dev/null || true)"
#   echo "$CMP_FLAGS"
#   echo "== mpifort -showme:link =="
#   LNK_FLAGS="$(mpifort -showme:link 2>/dev/null || true)"
#   echo "$LNK_FLAGS"

#   FC_BIN="${OMPI_FC:-${FC:-gfortran}}"
#   if ! command -v "$FC_BIN" >/dev/null 2>&1; then
#     echo "Fortran compiler not found: $FC_BIN"
#     exit 1
#   fi
#   echo "Using Fortran compiler: $(command -v "$FC_BIN")"

#   ls -l .
#   [[ -f helloworld.f ]] || { echo "helloworld.f not found"; exit 1; }
#   set -x
#   "$FC_BIN" ${FFLAGS:-} $CMP_FLAGS -c helloworld.f -o hello_f.o
#   ls -l hello_f.o
#   "$FC_BIN" hello_f.o $LNK_FLAGS ${LDFLAGS:-} -o helloworld1_f
#   set +x

#   $MPIEXEC -n 4 ./helloworld1_f

#   if [[ -f helloworld.f90 ]]; then
#     set -x
#     "$FC_BIN" ${FFLAGS:-} $CMP_FLAGS -c helloworld.f90 -o hello_f90.o
#     ls -l hello_f90.o
#     "$FC_BIN" hello_f90.o $LNK_FLAGS ${LDFLAGS:-} -o helloworld1_f90
#     set +x
#     $MPIEXEC -n 4 ./helloworld1_f90
#   fi

#   if command -v mpif77 >/dev/null 2>&1; then
#     F77_CMP="$(mpif77 -showme:compile 2>/dev/null || true)"
#     F77_LNK="$(mpif77 -showme:link    2>/dev/null || true)"
#     set -x
#     "$FC_BIN" ${FFLAGS:-} $F77_CMP -c helloworld.f -o hello_f77.o
#     "$FC_BIN" hello_f77.o $F77_LNK ${LDFLAGS:-} -o helloworld2_f
#     set +x
#     $MPIEXEC -n 4 ./helloworld2_f
#   fi

#   if command -v mpif90 >/dev/null 2>&1; then
#     F90_CMP="$(mpif90 -showme:compile 2>/dev/null || true)"
#     F90_LNK="$(mpif90 -showme:link    2>/dev/null || true)"
#     if [[ -f helloworld.f90 ]]; then
#       set -x
#       "$FC_BIN" ${FFLAGS:-} $F90_CMP -c helloworld.f90 -o hello_f90b.o
#       "$FC_BIN" hello_f90b.o $F90_LNK ${LDFLAGS:-} -o helloworld2_f90
#       set +x
#       $MPIEXEC -n 4 ./helloworld2_f90
#     fi
#   fi
# fi


if [[ $PKG_NAME == "openmpi-mpifort" ]]; then
  set -euo pipefail

  FC_BIN="${OMPI_FC:-${FC:-gfortran}}"
  command -v "$FC_BIN" >/dev/null 2>&1 || { echo "No Fortran compiler: $FC_BIN"; exit 1; }

  RAW_CMP="$(mpifort -showme:compile 2>/dev/null || true)"
  RAW_LNK="$(mpifort -showme:link    2>/dev/null || true)"

  CMP_FLAGS="$(printf '%s\n' "$RAW_CMP" | sed -E 's/(^|[[:space:]])-Wl,[^[:space:]]+//g')"
  LNK_FLAGS="$RAW_LNK"

  echo "== Using FC: $(command -v "$FC_BIN")"
  echo "== Compile flags: $CMP_FLAGS"
  echo "== Link    flags: $LNK_FLAGS"

  ls -l .
  [[ -f helloworld.f   ]] || { echo "helloworld.f not found"; exit 1; }
  [[ -f helloworld.f90 ]] || true

  set -x
  # gfortran --version
  # "$FC_BIN" --version
  # "$FC_BIN" ${FFLAGS:-} $CMP_FLAGS -c ./helloworld.f   -o hello_f.o
  # "$FC_BIN" hello_f.o   $LNK_FLAGS ${LDFLAGS:-}        -o helloworld1_f
  # set +x
  # $MPIEXEC -n 4 ./helloworld1_f

  gfortran helloworld.f -c -o hello_f.o $(mpifort -showme:compile)
  gfortran hello_f.o -o helloworld1_f  $(mpifort -showme:link)
 
  set +x

#   if [[ -f helloworld.f90 ]]; then
#     set -x
#     "$FC_BIN" ${FFLAGS:-} $CMP_FLAGS -c ./helloworld.f90 -o hello_f90.o
#     "$FC_BIN" hello_f90.o $LNK_FLAGS ${LDFLAGS:-}        -o helloworld1_f90
#     set +x
#     $MPIEXEC -n 4 ./helloworld1_f90
#   fi

#   if command -v mpif77 >/dev/null 2>&1; then
#     F77_CMP="$(mpif77 -showme:compile 2>/dev/null || true)"
#     F77_LNK="$(mpif77 -showme:link    2>/dev/null || true)"
#     F77_CMP="$(printf '%s\n' "$F77_CMP" | sed -E 's/(^|[[:space:]])-Wl,[^[:space:]]+//g')"
#     set -x
#     "$FC_BIN" ${FFLAGS:-} $F77_CMP -c ./helloworld.f -o hello_f77.o
#     "$FC_BIN" hello_f77.o $F77_LNK ${LDFLAGS:-}      -o helloworld2_f
#     set +x
#     $MPIEXEC -n 4 ./helloworld2_f
#   fi

#   if command -v mpif90 >/dev/null 2>&1 && [[ -f helloworld.f90 ]]; then
#     F90_CMP="$(mpif90 -showme:compile 2>/dev/null || true)"
#     F90_LNK="$(mpif90 -showme:link    2>/dev/null || true)"
#     F90_CMP="$(printf '%s\n' "$F90_CMP" | sed -E 's/(^|[[:space:]])-Wl,[^[:space:]]+//g')"
#     set -x
#     "$FC_BIN" ${FFLAGS:-} $F90_CMP -c ./helloworld.f90 -o hello_f90b.o
#     "$FC_BIN" hello_f90b.o $F90_LNK ${LDFLAGS:-}       -o helloworld2_f90
#     set +x
#     $MPIEXEC -n 4 ./helloworld2_f90
#   fi
fi





popd
