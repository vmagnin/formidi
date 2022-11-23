! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GNU GPLv3
! Vincent Magnin
! Last modifications: 2022-11-23

program main
    use formidi
    use music

    implicit none

    print *, "A4  is 69: ", get_MIDI_note("A4")
    print *, "G9  is 127:", get_MIDI_note("G9")
    print *, "C0  is 12: ", get_MIDI_note("C0")
    print *, "D#3 is 51: ", get_MIDI_note("D#3")
    print *, "Eb6 is 87: ", get_MIDI_note("Eb6")
    print *, "C0  is 12: ", get_MIDI_note(trim(HEXATONIC_BLUES_SCALE(1))//"0")
end program main
