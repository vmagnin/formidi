! ForMIDI: a small Fortran MIDI sequencer for composing music, exploring
!          algorithmic music and music theory
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-13

module music
    use, intrinsic :: iso_fortran_env, only: int8, error_unit
    ! Music theory elements common to the ForMIDI and ForSynth projects.
    ! We don't use "only:" to allow "use music" to include
    ! the whole "music_common" module:
    use music_common

    implicit none

    public :: note_name, MIDI_Note

contains

    ! Returns the MIDI note number, from 12 (C0) to 127 (G9).
    ! The note name is composed of two or three characters, 
    ! for example "A4", "A#4", "Ab4", where the final character is 
    ! the octave.
    integer(int8) function MIDI_Note(note)
        character(*), intent(in) :: note
        ! 0 <= octave <=9
        integer(int8) :: octave
        ! Gap relative to A4 (note 69) in semitones:
        integer(int8) :: gap
        ! ASCII code of the 0 character:
        integer(int8), parameter :: zero = iachar('0')

        select case (note(1:1))
            case ('C')
                gap = -9
            case ('D')
                gap = -7
            case ('E')
                gap = -5
            case ('F')
                gap = -4
            case ('G')
                gap = -2
            case ('A') 
                gap = 0
            case ('B')
                gap = +2
            case default
                write(error_unit, *) "ERROR 4: unknown note name!"
                error stop 4
        end select

        ! Treating accidentals (sharp, flat) and computing the octave:
        select case (note(2:2))
            case ('b')
                gap = gap - 1_int8
                octave = iachar(note(3:3), int8) - zero
            case ('#')
                gap = gap + 1_int8
                octave = iachar(note(3:3), int8) - zero
            case default
                octave = iachar(note(2:2), int8) - zero
        end select

        if ((octave >= 0) .and. (octave <= 9)) then
            gap = gap + (octave - 4_int8) * 12_int8
        else
            write(error_unit, *) "ERROR 5: octave out of bounds [0; 9]"
            error stop 5
        end if

        ! Computing and returning the MIDI note number (A4 is 69):
        MIDI_Note = 69_int8 + gap
    end function MIDI_Note

    ! Receives a MIDI note (for example 69),
    ! and returns the name of the note (for example A4).
    ! It works also with the octave -1, although most of its notes
    ! are too low for hearing.
    function note_name(MIDI_note) result(name)
        integer, intent(in) :: MIDI_note
        integer :: m
        character(2)  :: octave
        character(4)  :: name

        if ((MIDI_note < 0).or.(MIDI_note > 127)) then
            if (MIDI_note < 0) m = 0
            if (MIDI_note > 127) m = 127
            write(error_unit, *) "WARNING in note_name(): MIDI_note out of range [0 ; 127] => corrected to ", m
        else
            m = MIDI_note
        end if

        write(octave, '(I0)') (m / 12) - 1
        name = trim(CHROMATIC_SCALE(mod(m, 12) + 1)) // octave
    end function

end module music
