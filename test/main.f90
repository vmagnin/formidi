! ForMIDI: a small Fortran MIDI sequencer for composing music, exploring
!          algorithmic music and music theory
! License GNU GPLv3
! Vincent Magnin
! Last modifications: 2024-06-14

program main
    use, intrinsic :: iso_fortran_env
    use MIDI_file_class
    use music
    use MIDI_control_changes
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi

    print *, "A4  is 69: ", MIDI_Note("A4"),  note_name(69)
    print *, "G9  is 127:", MIDI_Note("G9"),  note_name(127)
    print *, "C0  is 12: ", MIDI_Note("C0"),  note_name(12)
    print *, "D#3 is 51: ", MIDI_Note("D#3"), note_name(51)
    print *, "Eb6 or D#6 is 87: ", MIDI_Note("Eb6"), note_name(87)
    print *, "C0  is 12: ", MIDI_Note(trim(HEXATONIC_BLUES_SCALE(1))//"0")
    print *, "Note 0 is C-1: ",  note_name(0)
    print *, "Note 1 is C#-1: ", note_name(1)
    print *, "Note out of range +128: ", note_name(+128)
    print *, "Note out of range -1: ", note_name(-1)

    call tests_MIDI()

contains

    ! For quickly testing MIDI related functions:
    subroutine tests_MIDI()
        print *, "Writing a tests.mid file"
        call midi%new("tests.mid", 1, 2, quarter_note, tempo=500000)

        call midi%track_header()
        call midi%Program_Change(0, Harpsichord)        ! Instrument
        call midi%Control_Change(0, Effects_3_Depth, 127)  ! Chorus
        call midi%play_note(0, MIDI_Note("G4"), 64, quarter_note)
        call midi%Control_Change(0, Pan, 127)
        call midi%play_chord(0, MIDI_Note("A4"), CLUSTER_CHORD, 64, 4*quarter_note)

        call midi%Program_Change(1, Church_Organ)        ! Instrument
        call midi%Control_Change(1, Effects_3_Depth, 127)  ! Chorus
        call midi%play_note(1, MIDI_Note("G4"), 64, 4*quarter_note)

        call midi%end_of_track()
        call midi%close()

        print *, "Trying to read it with Timidity++ (Linux only)"
        print *
        call execute_command_line("timidity tests.mid -x 'soundfont /usr/share/sounds/sf2/FluidR3_GM.sf2'")
    end subroutine tests_MIDI

end program main
