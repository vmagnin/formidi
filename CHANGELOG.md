# Changelog
All notable changes to the project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).


## [ForMIDI dev]

### Added
- `src/formidi.f90` is now `MIDI_file_class.f90`.
   - A subroutine `write_broken_chord()` (renamed `play__broken_chord()`), using an array containing the intervals to play, was added in that class. For the moment, each note has the same duration.
   - The subroutine `write_chord()` (renamed `play_chord()`) was moved in that class.
   - The function `get_MIDI_note()` (renamed `MIDI_note()`) was moved in `src/music.f90`.
   - `init_formidi()` is now automatically called when you create a MIDI file.
   - The `size_pos` variable is now automatically managed by the object.
   - The `tempo` and `copyright` (optional) are now passed to the construction `new()` method.
   - A `text_event` (optional) can now be passed to the `new()` and `track_header()` methods.
   - The track name is now passed to the `track_header()` method.
   - The metadata track is now closed automatically at the end of the `new()` method.
- The method `get_name()` returns the MIDI filename.
- `ROADMAP.md`
- An `example/README.md` file presenting each example.
- `example/la_folia.f90`: variations on [La Folia](https://en.wikipedia.org/wiki/Folia), demonstrating the use of the subroutine `play_broken_chord()`.
- A `logo/` directory.

### Changed
- `src/music.f90` was splitted in two files: `src/music.f90` and `src/music_common.f90` which contain music theory elements common to the ForMIDI and ForSynth projects.
- `src/demos.f90` was removed and split into `example/third_kind.f90`, 
`example/canon.f90`, `example/blues.f90` and `example/circle_of_fifths.f90`. They can
be run with the `fpm run --example` command.
- `build.sh` improved.
- In examples, keyword argument lists are now generally used to improve understanding.
- The API was simplified by renaming many methods and arguments.
- The method `Note()` was split in two: `Note_ON()` and `Note_OFF()`.

### Removed
- `app/main.f90` was removed.


## [ForMIDI v0.2 "Forever Young"] 2022-12-15

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
