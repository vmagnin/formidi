# Roadmap

The stars in parenthesis are an evaluation of the difficulty.

## ForMIDI 0.5 "?"

### Development
* [ ] License : keep the GPL 3 or move to [LGPL 3](https://en.wikipedia.org/wiki/GNU_Lesser_General_Public_License) ?

### Features
* [ ] Implement aftertouch MIDI events: polyphonic (An) and channel (Dn) pressure. (*)
* [ ] Can ForMIDI handle MIDI formats 0 and 2? Test it.

### Examples
* [ ] An example generating the major (or minor) scales by transposing the array +1 twelve times. (*)
* [ ] Exploring [Modes of limited transposition](https://en.wikipedia.org/wiki/Mode_of_limited_transposition) (Olivier Messiaen). (**)
* [ ] Choosing a licence for the OGG files ? (artlibre? CC?)


## Ideas for further developments

* [ ] Examples
    * [ ] Exploring aftertouch. (*)
    * [ ] A rhythmic canon (https://fr.wikipedia.org/wiki/Canon_rythmique). (**)
    * [ ] Exploring 1/f music (Tangente Sup 59). (**)
        * Levitin DJ, Chordia P, Menon V. [Musical rhythm spectra from Bach to Joplin obey a 1/f power law.](https://pubmed.ncbi.nlm.nih.gov/22355125/) Proc Natl Acad Sci U S A. 2012 Mar 6;109(10):3716-20. doi:10.1073/pnas.1113828109. Epub 2012 Feb 21. PMID: 22355125; PMCID: PMC3309746.
        * Richard F. Voss, John Clarke; ’’1/f noise’’ in music: Music from 1/f noise. J. Acoust. Soc. Am. 1 January 1978; 63 (1): 258–263. https://doi.org/10.1121/1.381721
    * [ ] A random walk on the [Tonnetz](https://en.wikipedia.org/wiki/Tonnetz). (***)
    * [ ] Trying to understand the [Tininnabuli](https://en.wikipedia.org/wiki/Tintinnabuli) style (Arvo Pärt). (***)

* [ ] Adding subroutines for [serial](https://en.wikipedia.org/wiki/Serialism) music. See https://github.com/vmagnin/formidi/issues/8 (**)
    * [ ] Generating a twelve tones serie.
    * [ ] Geometric transformations (reverse, symetries, etc.). Could also be used for non-serial music (Bach...).

* [ ] A drum pattern object to ease programming rhythms, inspired by the pattern system used in `example/drum_machine.f90`. Could be also used by ForSynth? (***)
* [ ] A note sequencer repeating a pattern. Could be also used by ForSynth? (***)
* [ ] A sequence object, accepting a string with notes, with methods to obtain one by one their parameters (physical or MIDI). A first attempt can be seen in `example/la_folia.f90`. Could be also used by ForSynth? (***)

* [ ] Implement more meta-events:
    * [ ] key_signature FF 59 02 sf mi
    * [ ] sequence_number FF 00 02 ssss
    * [ ] midi_channel_prefix FF 20 01 cc
    * [ ] SMPTE Offset FF 54 05 hr mn se fr ff
    * [ ] sequence_specific_meta_event FF 7F len data

* [ ] Implement more MIDI events:
    * [ ] sysex_event F0 length bytes
