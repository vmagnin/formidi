# Changelog
All notable changes to the project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).


## [ForMIDI development version "Forever Young"]

"Forever Young" is a song by the German band Alphaville (1984).

### Added
- `src/music.f90`: a module containing some music theory elements (scales, circle of fifths, chords), and the subroutine `write_chord()` and the function `get_note_name()`.
- `src/demos.f90`: a new `demo4` plays a random walk on the circle of fifths.
- `test/main.f90`: a subroutine `tests_MIDI()` for quickly testing MIDI related functions, with `fpm test`.
- `build.sh` can now also use the Intel ifx compiler: `$ FC='ifx' ./build.sh`. the default compiler is GFortran.

### Changed
- `src/demos.f90`: demo3 (stochastic blues) now uses power chords. In demo3, the MIDI notes were replaced by notes names.

## [ForMIDI 0.1 "Formidable"] 2021-03-02

"Formidable" is a song by the Belgian talentuous artist Stromae.

### Added
- Initial commit.

### Changed
- Translated from C.
