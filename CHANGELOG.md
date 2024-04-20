# Changelog
All notable changes to the project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).


## [ForMIDI dev]

### Changed
- `src/demos.f90` was removed and split into `example/demo1.f90`, 
`example/demo2.f90`, `example/demo3.f90` and `example/demo4.f90`. They can be run with the
`fpm run --example` command.

### Removed
- `app/main.f90` was removed.


## [ForMIDI v0.2 "Forever Young"]

"Forever Young" is a song by the German band Alphaville (1984).

### Added
- `src/formidi.f90`: added subroutines to write text inside a MIDI file (meta-events FF 01 to FF 07).
- `src/music.f90`: a module containing some music theory elements (scales, circle of fifths, chords), and the subroutine `write_chord()` and the function `get_note_name()`.
- `src/MIDI_control_changes.f90`: a module with all the MIDI Control Changes parameters.
- `src/GM_instruments.f90`: contains the list of 128 General MIDI instruments and 47 percussive instruments (channel 9).
- `src/demos.f90`: a new `demo4` plays a random walk on the circle of fifths.
- `test/main.f90`: a subroutine `tests_MIDI()` for quickly testing MIDI related functions, with `fpm test`.
- `build.sh` can now also use the Intel ifx compiler: `$ FC='ifx' ./build.sh`. the default compiler is GFortran.

### Changed
- `src/demos.f90`: demo3 (stochastic blues) now uses power chords. In demo3, the MIDI notes were replaced by notes names.

## [ForMIDI v0.1 "Formidable"] 2021-03-02

"Formidable" is a song by the Belgian talentuous artist Stromae.

### Added
- Initial commit.

### Changed
- Translated from the C version (2016-02-16).
