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
  ifx -warn -stand f18 src/formidi.f90 src/music.f90 src/GM_instruments.f90  src/MIDI_control_changes.f90 example/demo1.f90 -o build/demo1.out
  ifx -warn -stand f18 src/formidi.f90 src/music.f90 src/GM_instruments.f90  src/MIDI_control_changes.f90 example/demo2.f90 -o build/demo2.out
  ifx -warn -stand f18 src/formidi.f90 src/music.f90 src/GM_instruments.f90  src/MIDI_control_changes.f90 example/demo3.f90 -o build/demo3.out
  ifx -warn -stand f18 src/formidi.f90 src/music.f90 src/GM_instruments.f90  src/MIDI_control_changes.f90 example/demo4.f90 -o build/demo4.out
else
  "${FC}" -Wall -Wextra -pedantic -std=f2018 src/formidi.f90 src/music.f90  src/GM_instruments.f90  src/MIDI_control_changes.f90 example/demo1.f90 -o build/demo1.out
  "${FC}" -Wall -Wextra -pedantic -std=f2018 src/formidi.f90 src/music.f90  src/GM_instruments.f90  src/MIDI_control_changes.f90 example/demo2.f90 -o build/demo2.out
  "${FC}" -Wall -Wextra -pedantic -std=f2018 src/formidi.f90 src/music.f90  src/GM_instruments.f90  src/MIDI_control_changes.f90 example/demo3.f90 -o build/demo3.out
  "${FC}" -Wall -Wextra -pedantic -std=f2018 src/formidi.f90 src/music.f90  src/GM_instruments.f90  src/MIDI_control_changes.f90 example/demo4.f90 -o build/demo4.out
fi

rm -f *.mod

