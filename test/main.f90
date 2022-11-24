! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GNU GPLv3
! Vincent Magnin
! Last modifications: 2022-11-24

program main
    use, intrinsic :: iso_fortran_env, only: int8
    use formidi
    use music

    implicit none

    print *, "A4  is 69: ", get_MIDI_note("A4"),  get_note_name(69_int8)
    print *, "G9  is 127:", get_MIDI_note("G9"),  get_note_name(127_int8)
    print *, "C0  is 12: ", get_MIDI_note("C0"),  get_note_name(12_int8)
    print *, "D#3 is 51: ", get_MIDI_note("D#3"), get_note_name(51_int8)
    print *, "Eb6 or D#6 is 87: ", get_MIDI_note("Eb6"), get_note_name(87_int8)
    print *, "C0  is 12: ", get_MIDI_note(trim(HEXATONIC_BLUES_SCALE(1))//"0")
    print *, "Note 0 is C-1: ",  get_note_name(0_int8)
    print *, "Note 1 is C#-1: ", get_note_name(1_int8)

end program main
