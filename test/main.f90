! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GNU GPLv3
! Vincent Magnin
! Last modifications: 2022-11-25

program main
    use, intrinsic :: iso_fortran_env
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

    call init_formidi()
    call tests_MIDI()

contains

    ! For quickly testing MIDI related functions:
    subroutine tests_MIDI()
        integer(int32) :: size_pos

        print *, "Writing a tests.mid file"
        call create_MIDI_file("tests.mid", 1_int8, 2_int16, quarter_note)
        size_pos = write_MIDI_track_header()
        call MIDI_tempo(500000)
        call write_end_of_MIDI_track()
        call write_MIDI_track_size(size_pos)
        size_pos = write_MIDI_track_header()

        call MIDI_Program_Change(0_int8, 0_int8)        ! Instrument
        call write_MIDI_note(0_int8, get_MIDI_note("G4"), 64_int8, quarter_note)
        call write_chord(0_int8, get_MIDI_note("A4"), CLUSTER_CHORD, 64_int8, 4*quarter_note)

        call write_end_of_MIDI_track()
        call write_MIDI_track_size(size_pos)
        call close_MIDI_file()

        print *, "Trying to read it with Timidity++ (Linux only)"
        print *
        call execute_command_line("timidity tests.mid -x 'soundfont /usr/share/sounds/sf2/FluidR3_GM.sf2'")
    end subroutine tests_MIDI

end program main
