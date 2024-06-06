! ForMIDI: a small Fortran MIDI sequencer for composing music, exploring
!          algorithmic music and music theory
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-06

module music
    use, intrinsic :: iso_fortran_env, only: int8, int32, error_unit
    use formidi, only : MIDI_delta_time, MIDI_Note, ON, OFF
    ! Music theory elements common to the ForMIDI and ForSynth projects:
    use music_common

    implicit none

    public :: write_chord, write_broken_chord, get_note_name

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

    ! Writes a broken chord using an array containing the intervals
    ! (see the music_common module).
    ! For the moment, each note has the same duration.
    ! https://en.wikipedia.org/wiki/Arpeggio
    subroutine write_broken_chord(channel, Note_MIDI, chord, velocity, duration)
        integer(int8), intent(in)  :: channel, Note_MIDI
        integer, dimension(:), intent(in) :: chord
        integer(int8),  intent(in) :: velocity
        integer(int32), intent(in) :: duration
        integer(int32) :: dnote, residual
        integer :: i

        dnote = nint(real(duration) / size(chord))
        ! The MIDI duration being an integer, the last note of the chord may
        ! have a slightly different duration to keep the total duration exact:
        residual = duration - dnote*(size(chord) - 1)

        call MIDI_delta_time(0)
        do i = 1, size(chord)
            call MIDI_Note(ON,  channel, Note_MIDI + int(chord(i), kind=int8), velocity)
            if (i < size(chord)) then 
                call MIDI_delta_time(dnote)
            else
                call MIDI_delta_time(residual)
            end if
        end do

        do i = 1, size(chord)
            call MIDI_Note(OFF, channel, Note_MIDI + int(chord(i), kind=int8), 0_int8)
            ! The delta time must always be placed before a note:
            if (i < size(chord)) call MIDI_delta_time(0)
        end do
    end subroutine write_broken_chord

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
