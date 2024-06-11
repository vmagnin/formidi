! ForMIDI: a small Fortran MIDI sequencer for composing music, exploring
!          algorithmic music and music theory
! License GNU GPLv3
! Vincent Magnin
! Last modifications: 2024-06-10

program main
    use, intrinsic :: iso_fortran_env
    use MIDI_file_class
    use music
    use MIDI_control_changes
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi

    print *, "A4  is 69: ", get_MIDI_note("A4"),  get_note_name(69_int8)
    print *, "G9  is 127:", get_MIDI_note("G9"),  get_note_name(127_int8)
    print *, "C0  is 12: ", get_MIDI_note("C0"),  get_note_name(12_int8)
    print *, "D#3 is 51: ", get_MIDI_note("D#3"), get_note_name(51_int8)
    print *, "Eb6 or D#6 is 87: ", get_MIDI_note("Eb6"), get_note_name(87_int8)
    print *, "C0  is 12: ", get_MIDI_note(trim(HEXATONIC_BLUES_SCALE(1))//"0")
    print *, "Note 0 is C-1: ",  get_note_name(0_int8)
    print *, "Note 1 is C#-1: ", get_note_name(1_int8)

    call tests_MIDI()

contains

    ! For quickly testing MIDI related functions:
    subroutine tests_MIDI()
        print *, "Writing a tests.mid file"
        call midi%new("tests.mid", 1_int8, 2_int16, quarter_note, tempo=500000)
        call midi%end_of_track()

        call midi%track_header()
        call midi%Program_Change(0_int8, Harpsichord)        ! Instrument
        call midi%Control_Change(0_int8, Effects_3_Depth, 127_int8)  ! Chorus
        call midi%play_note(0_int8, get_MIDI_note("G4"), 64_int8, quarter_note)
        call midi%Control_Change(0_int8, Pan, 127_int8)
        call midi%play_chord(0_int8, get_MIDI_note("A4"), CLUSTER_CHORD, 64_int8, 4*quarter_note)

        call midi%Program_Change(1_int8, Church_Organ)        ! Instrument
        call midi%Control_Change(1_int8, Effects_3_Depth, 127_int8)  ! Chorus
        call midi%play_note(1_int8, get_MIDI_note("G4"), 64_int8, 4*quarter_note)

        call midi%end_of_track()
        call midi%close()

        print *, "Trying to read it with Timidity++ (Linux only)"
        print *
        call execute_command_line("timidity tests.mid -x 'soundfont /usr/share/sounds/sf2/FluidR3_GM.sf2'")
    end subroutine tests_MIDI

end program main
