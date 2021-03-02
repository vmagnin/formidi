#!/bin/bash

# For a safer script:
set -eu

# Default compiler can be overrided, for example:
# $ GFC='gfortran-8' ./build.sh
# Default:
: ${GFC="gfortran"}

# Create (if needed) the build directory:
if [ ! -d build ]; then
    mkdir build
fi

rm -f *.mod

"${GFC}" -Wall -Wextra -pedantic -std=f2018 src/formidi.f90 src/demos.f90 app/main.f90 -o build/formidi.out
