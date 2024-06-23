# Roadmap

The stars in parenthesis are an evaluation of the difficulty.

## ForMIDI 0.4 "?"

### Features
* [x] Implement the meta-event: time_signature FF 58 04 nn dd cc bb   (**)
* [ ] Implement the MIDI event: Pitch Bend (En)   (*)
* [x] Define parameter velocities for forte 80, mezzo-forte 64, piano 42, etc. See https://arxiv.org/pdf/1705.05322
* [x] Define parameter [note values](https://en.wikipedia.org/wiki/Note_value) (whole, half, ...).

### Examples
* [ ] Create an example mixing Dmitri Shostakovich [DSCH motif](https://en.wikipedia.org/wiki/DSCH_motif) and [BACH motif](https://en.wikipedia.org/wiki/BACH_motif). (**)

### Documentation
* [ ] `README.md`: add a picture of the E-MU Xmidi 2x2. (*)
* [ ] Adding a first version of a FORD documentation. (**)


## Ideas for further developments

* [ ] License : keep the GPL 3 or move to [LGPL 3](https://en.wikipedia.org/wiki/GNU_Lesser_General_Public_License) ?
* [ ] Can ForMIDI handle MIDI formats 0 and 2? Test it.
* [ ] Add test for the subroutine write_variable_length_quantity(self, i). It could be split in two routines, one testable and one writing in the file.

* [ ] Examples
    * [ ] Explore aftertouch. (*)
    * [ ] Exploring [Modes of limited transposition](https://en.wikipedia.org/wiki/Mode_of_limited_transposition) (Olivier Messiaen). (**)
    * [ ] A rhythmic canon (https://fr.wikipedia.org/wiki/Canon_rythmique). (**)
    * [ ] Exploring 1/f music (Tangente Sup 59). (**)
    * [ ] A random walk on the [Tonnetz](https://en.wikipedia.org/wiki/Tonnetz). (***)
    * [ ] Trying to understand the [Tininnabuli](https://en.wikipedia.org/wiki/Tintinnabuli) style (Arvo Pärt). (***)

* [ ] Implement more MIDI events:
    * [ ] Aftertouch: polyphonic (An) and channel (Dn) pressure.
    * [ ] sysex_event F0 length bytes

* [ ] Implement more meta-events
    * [ ] key_signature FF 59 02 sf mi
    * [ ] sequence_number FF 00 02 ssss
    * [ ] midi_channel_prefix FF 20 01 cc
    * [ ] SMPTE Offset FF 54 05 hr mn se fr ff
    * [ ] sequence_specific_meta_event FF 7F len data

* [ ] Adding subroutines for [serial](https://en.wikipedia.org/wiki/Serialism) music. (**)
    * [ ] Generating a twelve tones serie.
    * [ ] Geometric transformations (reverse, symetries, etc.). Could also be used for non-serial music (Bach...).

* [ ] A drum pattern object to ease programming rhythms, inspired by the pattern system used in `example/drum_machine.f90`. Could be also used by ForSynth? (***)
* [ ] A note sequencer repeating a pattern. Could be also used by ForSynth? (***)
* [ ] A sequence object, accepting a string with notes, with methods to obtain one by one their parameters (physical or MIDI). A first attempt can be seen in `example/la_folia.f90`. Could be also used by ForSynth? (***)
