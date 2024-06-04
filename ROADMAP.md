# Roadmap

The stars in parenthesis are an evaluation of the difficulty.

## ForMidi 0.3

### Development
* [ ] Explore OOP. (**)
    * [ ] Create a `MIDI_file` class?
* [x] Improving `build.sh` (*)

### Features
* [ ] 

### Examples
* [x] Renaming the existings demos with more explicit names, 
* [x] and adding a `README.md`. (*)

### Documentation
* [x] Create a logo. (*)
* [ ] Add comments in examples to document the usage of the API. (*)


## Ideas for further developments

* [ ] Examples
    * [ ] A random walk on the [Tonnetz](https://en.wikipedia.org/wiki/Tonnetz). (***)
    * [ ] Exploring [Tininnabuli](https://en.wikipedia.org/wiki/Tintinnabuli) style (Arvo Pärt). (***)
    * [ ] Exploring [Modes of limited transposition](https://en.wikipedia.org/wiki/Mode_of_limited_transposition) (Olivier Messiaen). (**)
    * [ ] Exploring 1/f music (Tangente). (**)

* [ ] Adding a first version of a FORD documentation. (**)

* [ ] Adding subroutines for serial music.

* [ ] A drum pattern object to ease programming rhythms, inspired by the pattern system used in `example/drum_machine.f90`. Could be also used by ForSynth. (***)
* [ ] A note sequencer repeating a pattern. Could be also used by ForSynth. (***)
* [ ] A sequence object, accepting a string with notes, with methods to obtain one by one their parameters (physical or MIDI). Could be also used by ForSynth. (***)
    * [ ] The sequence could for example be coded as "A4,Q.,pf;A#4,Q,pf;..." (note, length, intensity).
