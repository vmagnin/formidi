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
  ifx -warn -stand f18 src/formidi.f90 src/music_common.f90 src/music.f90 src/GM_instruments.f90  src/MIDI_control_changes.f90 example/third_kind.f90 -o build/third_kind.out
  ifx -warn -stand f18 src/formidi.f90 src/music_common.f90 src/music.f90 src/GM_instruments.f90  src/MIDI_control_changes.f90 example/canon.f90 -o build/canon.out
  ifx -warn -stand f18 src/formidi.f90 src/music_common.f90 src/music.f90 src/GM_instruments.f90  src/MIDI_control_changes.f90 example/blues.f90 -o build/blues.out
  ifx -warn -stand f18 src/formidi.f90 src/music_common.f90 src/music.f90 src/GM_instruments.f90  src/MIDI_control_changes.f90 example/circle_of_fifths.f90 -o build/circle_of_fifths.out
else
  "${FC}" -Wall -Wextra -pedantic -std=f2018 src/formidi.f90 src/music_common.f90 src/music.f90  src/GM_instruments.f90  src/MIDI_control_changes.f90 example/third_kind.f90 -o build/third_kind.out
  "${FC}" -Wall -Wextra -pedantic -std=f2018 src/formidi.f90 src/music_common.f90 src/music.f90  src/GM_instruments.f90  src/MIDI_control_changes.f90 example/canon.f90 -o build/canon.out
  "${FC}" -Wall -Wextra -pedantic -std=f2018 src/formidi.f90 src/music_common.f90 src/music.f90  src/GM_instruments.f90  src/MIDI_control_changes.f90 example/blues.f90 -o build/blues.out
  "${FC}" -Wall -Wextra -pedantic -std=f2018 src/formidi.f90 src/music_common.f90 src/music.f90  src/GM_instruments.f90  src/MIDI_control_changes.f90 example/circle_of_fifths.f90 -o build/circle_of_fifths.out
fi

rm -f *.mod

