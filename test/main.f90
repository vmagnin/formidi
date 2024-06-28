! ForMIDI: a small Fortran MIDI sequencer for composing music, exploring
!          algorithmic music and music theory
! License GNU GPLv3
! Vincent Magnin
! Last modifications: 2024-06-28

program main
    use, intrinsic :: iso_fortran_env
    use MIDI_file_class
    use music
    use MIDI_control_changes
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi
    character(8) :: vlq

    ! Testing the variable_length_quantity() function:
    write(vlq, '(1z2.2)') variable_length_quantity(0)   ! z'00'
    if (trim(vlq) /= "00") error stop "ERROR: variable_length_quantity(0)"

    write(vlq, '(1z2.2)') variable_length_quantity(64)  ! z'40'
    if (trim(vlq) /= "40") error stop "ERROR: variable_length_quantity(z'40')"

    write(vlq, '(1z2.2)') variable_length_quantity(127) ! z'7F'
    if (trim(vlq) /= "7F") error stop "ERROR: variable_length_quantity(z'7F')"

    write(vlq, '(2z2.2)') variable_length_quantity(128) ! z'80'
    if (trim(vlq) /= "8100") error stop "ERROR: variable_length_quantity(z'80')"

    write(vlq, '(2z2.2)') variable_length_quantity(8192)    ! z'2000'
    if (trim(vlq) /= "C000") error stop "ERROR: variable_length_quantity(z'2000')"

    write(vlq, '(2z2.2)') variable_length_quantity(16383)   ! z'3FFF'
    if (trim(vlq) /= "FF7F") error stop "ERROR: variable_length_quantity(z'3FFF')"

    write(vlq, '(3z2.2)') variable_length_quantity(16384)   ! z'4000'
    if (trim(vlq) /= "818000") error stop "ERROR: variable_length_quantity(z'4000')"

    write(vlq, '(3z2.2)') variable_length_quantity(65535)   ! z'FFFF'
    if (trim(vlq) /= "83FF7F") error stop "ERROR: variable_length_quantity(z'FFFF')"

    write(vlq, '(3z2.2)') variable_length_quantity(1048576) ! z'100000'
    if (trim(vlq) /= "C08000") error stop "ERROR: variable_length_quantity(z'100000')"

    write(vlq, '(3z2.2)') variable_length_quantity(2097151) ! z'1FFFFF'
    if (trim(vlq) /= "FFFF7F") error stop "ERROR: variable_length_quantity(z'1FFFFF')"

    write(vlq, '(4z2.2)') variable_length_quantity(2097152) ! z'200000'
    if (trim(vlq) /= "81808000") error stop "ERROR: variable_length_quantity(z'200000')"

    write(vlq, '(4z2.2)') variable_length_quantity(134217728) ! z'08000000'
    if (trim(vlq) /= "C0808000") error stop "ERROR: variable_length_quantity(z'08000000')"

    write(vlq, '(4z2.2)') variable_length_quantity(268435455) ! z'0FFFFFFF'
    if (trim(vlq) /= "FFFFFF7F") error stop "ERROR: variable_length_quantity(z'0FFFFFFF')"

    ! Testing the MIDI_note() function:
    if (MIDI_Note("A4")  /= 69)  error stop "ERROR: MIDI_Note('A4')"
    if (MIDI_Note("G9")  /= 127) error stop "ERROR: MIDI_Note('G9')"
    if (MIDI_Note("C0")  /= 12)  error stop "ERROR: MIDI_Note('C0')"
    if (MIDI_Note("D#3") /= 51)  error stop "ERROR: MIDI_Note('D#3')"
    if (MIDI_Note("Eb6") /= 87)  error stop "ERROR: MIDI_Note('Eb6')"
    if (MIDI_Note(trim(HEXATONIC_BLUES_SCALE(1))//"0")  /= 12)  error stop "ERROR: MIDI_Note blues scale"

    ! Testing the note_name() function:
    if (note_name(69)  /= "A4")  error stop "ERROR: note_name(69)"
    if (note_name(127) /= "G9")  error stop "ERROR: note_name(127)"
    if (note_name(12)  /= "C0")  error stop "ERROR: note_name(12)"
    if (note_name(51)  /= "D#3") error stop "ERROR: note_name(51)"
    if (note_name(87)  /= "D#6") error stop "ERROR: note_name(87)"

    ! Testing the note_name() function:
    if (note_name(0) /= "C-1") error stop "ERROR: note_name(0)"
    if (note_name(1) /= "C#-1") error stop "ERROR: note_name(1)"
    ! Those values should be automatically corrected:
    print *, "Note out of range +128: ", note_name(+128)
    print *, "Note out of range -1: ", note_name(-1)

    print *
    call tests_MIDI()

contains

    ! For quickly testing MIDI related functions:
    subroutine tests_MIDI()
        integer :: i

        call midi%new("tests.mid", 1, 2, quarter_note, tempo=500000)
        print *,"Writing the file ", midi%get_name()

        call midi%track_header()
        call midi%Program_Change(0, Harpsichord)           ! Instrument
        call midi%Control_Change(0, Effects_3_Depth, 127)  ! Chorus
        call midi%play_note(0, MIDI_Note("G4"), mf_level, quarter_note)
        call midi%Control_Change(0, Pan, 127)
        call midi%play_chord(0, MIDI_Note("A4"), CLUSTER_CHORD, mf_level, whole_note)

        call midi%Program_Change(1, Church_Organ)          ! Instrument
        call midi%Control_Change(1, Effects_3_Depth, 127)  ! Chorus
        call midi%play_note(1, MIDI_Note("G4"), mf_level, whole_note)

        ! Testing Pitch Bend MIDI event:
        call midi%delta_time(0)
        call midi%Note_ON(channel=1, note=MIDI_Note("A4"), velocity=ffff_level)
        do i = 64, 127
            call midi%delta_time(thirty_second_note)
            call midi%pitch_bend(1, msb=i)
        end do
        call midi%delta_time(0)
        call midi%Note_OFF(channel=1, note=MIDI_Note("A4"))

        call midi%end_of_track()
        call midi%close()

        print *, "Trying to read it with Timidity++ (Linux only)"
        print *
        call execute_command_line("timidity tests.mid -x 'soundfont /usr/share/sounds/sf2/FluidR3_GM.sf2'")
    end subroutine tests_MIDI

end program main
