# ForMIDI
A small Fortran MIDI sequencer for composing music, exploring algorithmic music and music theory. It can also be used to teach Fortran programming in a fun way!

Like Bach and Shostakovich, you can use letters from your name to create your own [musical cryptogram](https://en.wikipedia.org/wiki/Musical_cryptogram), like BACH and DEsCH. You can also make music with prime numbers, mathematical suites (Fibonacci, Syracuse...), the decimals of Pi, etc. MIDI notes are numbers!	

## Features

* Creates multi-tracks `.mid` files (MIDI 1.0).
* Includes several demos with comments:
	- demo1: five notes that could be useful to communicate with an E.T. intelligence...
	- demo2: a simple canon based on the first measures of Pachelbel's Canon. Listen to the [ogg file](http://magnin.plil.net/IMG/ogg/canon.ogg).
	- demo3: a stochastic blues, including a percussion track (there are 16 MIDI channels, from 0 to 15. The channel 9 is only for percussion).
	- demo4: a random walk on the circle of fifths.
* You need only a modern Fortran compiler and a MIDI media player, whatever 
your OS.
* GPLv3 license.

## Compilation and execution

You can easily build and run the project using the Fortran Package Manager [fpm](https://github.com/fortran-lang/fpm) at the root of the project directory:

```
$ fpm build
$ fpm run
```

Or you can also use the `build.sh` script if you don't have fpm installed.

The demos files are generated in the same directory, for example `demo1.mid`:

```bash
$ file demo1.mid
demo1.mid: Standard MIDI data (format 1) using 2 tracks at 1/128
```

MIDI files are similar to music scores. They don't contain any sound but just binary coded commands for the instruments, and are therefore very light files:

```bash
$ hexdump -C demo1.mid
00000000  4d 54 68 64 00 00 00 06  00 01 00 02 00 80 4d 54  |MThd..........MT|
00000010  72 6b 00 00 00 45 00 ff  51 03 07 a1 20 00 ff 01  |rk...E..Q... ...|
00000020  36 54 68 69 73 20 66 69  6c 65 20 77 61 73 20 63  |6This file was c|
00000030  72 65 61 74 65 64 20 77  69 74 68 20 74 68 65 20  |reated with the |
00000040  46 6f 72 4d 49 44 49 20  46 6f 72 74 72 61 6e 20  |ForMIDI Fortran |
00000050  70 72 6f 6a 65 63 74 00  ff 2f 00 4d 54 72 6b 00  |project../.MTrk.|
00000060  00 00 34 00 c0 5d 00 90  43 40 81 00 80 43 00 00  |..4..]..C@...C..|
00000070  90 45 40 81 00 80 45 00  00 90 41 40 81 00 80 41  |.E@...E...A@...A|
00000080  00 00 90 35 40 81 00 80  35 00 00 90 3c 40 82 00  |...5@...5...<@..|
00000090  80 3c 00 00 ff 2f 00                              |.<.../.|
00000097
```
The "MThd" string begins the header of the MIDI file. Each track begins with a header beginning by "MTrk". The first track is always a metadata track, containing for example the tempo of the music.

## Playing your MIDI file with a media player

### Linux

You can use [TiMidity++](http://timidity.sourceforge.net/):

```bash
$ timidity demo1.mid
```

The quality of the output depends essentially on the quality of the soundfont. By default, timidity uses the [freepats](http://freepats.zenvoid.org/) soundfont. A better soundfont is `FluidR3_GM.sf2` (`fluid-soundfont-gm` package in Ubuntu):

```bash
$ timidity demo1.mid -x "soundfont /usr/share/sounds/sf2/FluidR3_GM.sf2"
```

You can save the music as a WAV file with the `-Ow` option, and a OGG with `-Ov`.

Another software synthesizer is [FluidSynth](https://www.fluidsynth.org/):

```bash
$ fluidsynth -a alsa -m alsa_seq -l -i /usr/share/sounds/sf2/FluidR3_GM.sf2 demo1.mid
```

### macOS

You can use GarageBand.

### Windows

You can simply play your MIDI files with the Windows Media Player.

### Online tools

You can convert your MIDI files to several audio formats using online tools such as:

* https://audio.online-convert.com/convert/midi-to-ogg
* https://www.conversion-tool.com/midi/

With some of them, you can even choose the soundfont.

## Playing your MIDI file with your synthesizer

You can connect your musical keyboard or synthesizer to your computer using a USB / MIDI interface. First price is around 15 € or $.

### Linux

This ALSA command will print the list of the connected MIDI devices:

```bash
$ aplaymidi -l
 Port    Client name                      Port name
 14:0    Midi Through                     Midi Through Port-0
 24:0    E-MU Xmidi 2x2                   E-MU Xmidi 2x2 MIDI 1
 24:1    E-MU Xmidi 2x2                   E-MU Xmidi 2x2 MIDI 2
```

If the synthesizer is connected to the port 24:0, this command will play the MIDI file:

```bash
$ aplaymidi -p 24:0 demo1.mid
```

## Importing your MIDI file in other softwares

You can of course import your `.mid` file into any sequencer like [LMMS](https://lmms.io/) (Linux, Windows, macOS) or [Rosegarden](http://www.rosegardenmusic.com/).


## Contributing

* Post a message in the GitHub *Issues* tab to discuss the function you want to work on.
* Concerning coding conventions, follow the [stdlib conventions](https://github.com/fortran-lang/stdlib/blob/master/STYLE_GUIDE.md).
* When ready, make a *Pull Request*.

## MIDI technical information

* https://en.wikipedia.org/wiki/MIDI
* [Standard MIDI Files](https://www.midi.org/articles/about-midi-part-4-midi-files)
* [Standard MIDI-File Format Spec. 1.1, updated](https://www.cs.cmu.edu/~music/cmsip/readings/Standard-MIDI-file-format-updated.pdf)
* (fr) [La norme MIDI et les fichiers MIDI](https://www.jchr.be/linux/midi-format.htm)
* [Codage Variable Length Quantity](https://en.wikipedia.org/wiki/Variable-length_quantity)
* [General MIDI instruments](https://en.wikipedia.org/wiki/General_MIDI)
* [MIDI notes](https://www.inspiredacoustics.com/en/MIDI_note_numbers_and_center_frequencies)
* [Control Change Messages](https://www.midi.org/specifications-old/item/table-3-control-change-messages-data-bytes-2)
* (fr) [Introduction au MIDI : les control change](https://fr.audiofanzine.com/mao/editorial/dossiers/le-midi-les-midi-control-change.html)
* [Soundfont CGM3.01 (1.57 Gb)](http://www.bismutnetwork.com/04CrisisGeneralMidi/Soundfont3.0.php)


## Bibliography
### English

* Jean-Claude Risset, [*Computer music: why ?*](https://www.posgrado.unam.mx/musica/lecturas/tecnologia/optativasRecomendadas/Risset_ComputerMusic%20why.pdf), 2003.
* Dave Benson, [*Music - A Mathematical Offering*](https://homepages.abdn.ac.uk/d.j.benson/pages/html/music.pdf), 2008.
* [Illiac Suite (>Wikipedia)](https://en.wikipedia.org/wiki/Illiac_Suite).
* About the history of electronic music: https://github.com/vmagnin/forsynth/blob/main/ELECTRONIC_MUSIC_HISTORY.md

### French
* Vincent Magnin, ["Avec MIDI, lancez-vous dans la musique assistée par ordinateur !"](https://connect.ed-diamond.com/Linux-Pratique/lphs-029/avec-midi-lancez-vous-dans-la-musique-assistee-par-ordinateur), *Linux Pratique*, HS n°29, février 2014.
* Vincent Magnin, ["Format MIDI : composez en C !"](https://connect.ed-diamond.com/GNU-Linux-Magazine/GLMF-196/Format-MIDI-composez-en-C), *GNU/Linux Magazine,* 196, sept. 2016.
* Vincent Magnin, ["Format MIDI et musique algorithmique"](https://connect.ed-diamond.com/GNU-Linux-Magazine/GLMF-198/Format-MIDI-et-musique-algorithmique), *GNU/Linux Magazine,* 198, nov. 2016.
* Vincent Magnin, ["Lancez-vous dans la « dance music » avec Linux MultiMedia Studio !"](https://connect.ed-diamond.com/Linux-Pratique/lp-082/lancez-vous-dans-la-dance-music-avec-linux-multimedia-studio), *Linux Pratique,* n°82, mars 2014.
* Vincent Magnin, ["Composez librement avec le séquenceur Rosegarden"](https://connect.ed-diamond.com/Linux-Pratique/lphs-029/composez-librement-avec-le-sequenceur-rosegarden), *Linux Pratique,* HS n°29, février 2014.
* M. Andreatta, ["Musique algorithmique"](http://articles.ircam.fr/textes/Andreatta11b/index.pdf), 2009.
* Laurent de Wilde, [*Les fous du son - D'Edison à nos jours*](https://www.grasset.fr/livres/les-fous-du-son-9782246859277), Editions Grasset et Fasquelle, 560 pages, 2016, ISBN 9782246859277.
* Laurent Fichet, [*Les théories scientifiques de la musique aux XIXe et XXe siècles*](https://www.vrin.fr/livre/9782711642847/les-theories-scientifiques-de-la-musique), Vrin, 1996, ISBN 978-2-7116-4284-7.
* Guillaume Kosmicki , [*Musiques électroniques - Des avant-gardes aux dance floors*](https://lemotetlereste.com/musiques/musiqueselectroniquesnouvelleedition/), Editions Le mot et le reste, 2nd edition, 2016, 416 p., ISBN 9782360541928.
* Bibliothèque Tangente n°11, [*Mathématiques et musique - des destinées parallèles*](https://www.lalibrairie.com/livres/mathematiques-et-musique--des-destinees-paralleles--2022_0-9115242_9782848842462.html), Paris : Éditions POLE, septembre 2022, ISBN 9782848842462.
