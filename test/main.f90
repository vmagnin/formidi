! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GNU GPLv3
! Vincent Magnin
! Last modifications: 2022-11-23

program main
    use formidi
    use music

    implicit none

    print *, "A4", get_MIDI_note("A4")
    print *, "G9", get_MIDI_note("G9")
    print *, "C0", get_MIDI_note("C0")
    print *, "D#3", get_MIDI_note("D#3")
    print *, "Eb6", get_MIDI_note("Eb6")
    print *, get_MIDI_note(trim(HEXATONIC_BLUES_SCALE(1))//"0")
end program main
