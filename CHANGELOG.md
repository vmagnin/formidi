# Changelog
All notable changes to the project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [ForMIDI dev]

### Added
- The Meta event `set_time_signature()` method and the `time_signature` optional argument in the `new()` method.
- In `src/music.f90`:
    - most useful notes values, alongside `quarter_note`, are now defined as Fortran parameters: `whole_note`, `half_note`, `eighth_note`, `sixteenth_note` and `thirty_second_note`, expressed in MIDI ticks.
    - A `dotted()` function returning the value of a dotted note.
    - Common note levels expressed as MIDI velocities, from `pppp_level` to `ffff_level`.
- Unit tests for the function `variable_length_quantity(i)`, which was added to be called by the method `write_variable_length_quantity(self, i)`.

### Changed
- In the `Note_OFF()` method, the velocity argument is now optional (64 is the default value).
- The `ON` and `OFF` MIDI constants are now defined as parameters, using their decimal value.
- The `quarter_note` parameter is now 96 instead of 128 (96 has the advantage of being a multiple of 2 and 3).

### Fixed
- The last `ishft()` in the `write_variable_length_quantity()` is now toward the right instead of left (fixes Issue #9).


## [ForMIDI v0.3 "Forbidden Planet"] 2024-06-15

*Forbidden Planet* (1956) is considered to be the first movie with an entire electronic soundtrack, composed by Bebe and Louis Barron.

### Added
- An `example/README.md` file presenting each example, with links to listen the OGG files.
- `example/la_folia.f90`: variations on [La Folia](https://en.wikipedia.org/wiki/Folia), demonstrating the use of the method `play_broken_chord()`.
- A method `play_broken_chord()`, using an array containing the intervals to play, was added in the `MIDI_file_class`. For the moment, each note has the same duration.
- A method `get_name()` returns the MIDI filename.
- `src/utilities.f90`: offers miscellaneous functions, like `checked_int8()`.
- A `ROADMAP.md` file.
- A `logo/` directory.

### Changed
- OOP refactoring: `src/formidi.f90` is now `MIDI_file_class.f90`.
    - The API was simplified by renaming many methods and arguments, and by removing the need to use int8, int16 or int32 integers: the user will now just use default kind integers. More simplifications:
    - `init_formidi()` is now automatically called when you create a MIDI file.
    - The `size_pos` variable is now automatically managed by the object.
    - The `tempo` and `copyright` (optional) are now passed to the construction `new()` method.
    - A `text_event` (optional) can now be passed to the `new()` and `track_header()` methods.
    - The track name is now passed to the `track_header()` method.
    - The metadata track is now closed automatically at the end of the `new()` method.
    - The subroutine `write_chord()` (renamed `play_chord()`) was moved in the `MIDI_file_class`.
    - The method `Note()` was split in two: `Note_ON()` and `Note_OFF()`.
- Examples:
    - `src/demos.f90` was removed and split into `example/third_kind.f90`, 
`example/canon.f90`, `example/blues.f90` and `example/circle_of_fifths.f90`. They can be run with the `fpm run --example` command.
    - In examples, keyword argument lists are now generally used to improve understanding and comments were added.
    - The multi-tracks examples `canon.f90`, `blues.f90` and `la_folia.f90` now uses the control change Pan to obtain a stereo effect.
- `src/music.f90` was splitted in two files: `src/music.f90` and `src/music_common.f90` which contain music theory elements common to the ForMIDI and ForSynth projects.
- The function `get_MIDI_note()` (renamed `MIDI_note()`) was moved in `src/music.f90`.
- `build.sh` improved.

### Removed
- `app/main.f90` was removed.

### Fixed
- `example/blues.f90`: the note_OFF events of the drums were not correctly placed.


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
