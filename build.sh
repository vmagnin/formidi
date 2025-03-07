#!/bin/bash
# Vincent Magnin
# Last modification: 2024-07-01

# For a safer script:
set -eu

# Default compiler can be overrided, for example:
# $ FC='ifx' ./build.sh
# Default:
: ${FC="gfortran"}

# Create (if needed) the build directory:
if [ ! -d build ]; then
    mkdir build
fi

rm -f *.mod

if [ "${FC}" = "ifx" ]; then
  flags="-warn all -stand f18"
else
  # GFortran flags:
  flags="-Wall -Wextra -pedantic -std=f2018 -fbounds-check"
fi

# Compiling modules:
"${FC}" ${flags} -c src/utilities.f90 src/MIDI_file_class.f90 src/music_common.f90 src/music.f90 src/GM_instruments.f90  src/MIDI_control_changes.f90

# Compiling examples:
for file in "third_kind" "canon" "blues" "circle_of_fifths" "la_folia" "motifs" ; do
  echo "${file}"
  "${FC}" ${flags} utilities.o MIDI_file_class.o music_common.o music.o  GM_instruments.o  MIDI_control_changes.o example/${file}.f90 -o build/${file}.out
done

# Cleanup to avoid any problem with fpm or another compiler:
rm -f *.mod
rm *.o
