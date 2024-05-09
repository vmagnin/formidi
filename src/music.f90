! ForMIDI: a small Fortran MIDI sequencer for composing music, exploring
!          algorithmic music and music theory
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-05-09

module music
    !---------------------------------------------------------------------------
    ! Contains music theory elements: scales, circle of fifths, chords, etc.
    !---------------------------------------------------------------------------

    use, intrinsic :: iso_fortran_env, only: int8, int32, error_unit
    use formidi, only : MIDI_delta_time, MIDI_Note, ON, OFF
    ! Music theory elements common to the ForMIDI and ForSynth projects:
    use music_common

    implicit none

    public

contains

    subroutine write_chord(channel, Note_MIDI, chord, velocity, duration)
        ! Writes a chord, waits for its duration, and writes the OFF events
        integer(int8), intent(in)  :: channel, Note_MIDI
        integer, dimension(:), intent(in) :: chord
        integer(int8),  intent(in) :: velocity
        integer(int32), intent(in) :: duration
        integer :: i

        do i = 1, size(chord)
            call MIDI_delta_time(0)
            call MIDI_Note(ON,  channel, Note_MIDI + int(chord(i), kind=int8), velocity)
        end do

        call MIDI_delta_time(duration)

        do i = 1, size(chord)
            call MIDI_Note(OFF, channel, Note_MIDI + int(chord(i), kind=int8), 0_int8)
            if (i < size(chord)) call MIDI_delta_time(0)
        end do
    end subroutine


    ! Receives a MIDI note (for example 69),
    ! and returns the name of the note (for example A4).
    ! It works also with the octave -1, although most of its notes
    ! are too low for hearing.
    pure function get_note_name(MIDI_note) result(name)
        integer(int8), intent(in) :: MIDI_note
        character(2) :: octave
        character(4) :: name

        write(octave, '(I0)') (MIDI_note / 12) - 1
        name = trim(CHROMATIC_SCALE(mod(MIDI_note, 12_int8) + 1)) // octave
    end function

end module music
