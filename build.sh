#!/bin/bash

# For a safer script:
set -eu

# Default compiler can be overrided, for example:
# $ FC='gfortran-8' ./build.sh
# Default:
: ${FC="gfortran"}

# Create (if needed) the build directory:
if [ ! -d build ]; then
    mkdir build
fi

rm -f *.mod

if [ "${FC}" = "ifx" ]; then
  ifx -warn -stand f18 src/formidi.f90 src/demos.f90 app/main.f90 -o build/formidi.out
else
  "${FC}" -Wall -Wextra -pedantic -std=f2018 src/formidi.f90 src/demos.f90 app/main.f90 -o build/formidi.out
fi
