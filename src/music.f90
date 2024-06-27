! ForMIDI: a small Fortran MIDI sequencer for composing music, exploring
!          algorithmic music and music theory
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-23

!> Offers music parameters and functions specific to MIDI files.
module music
    use, intrinsic :: iso_fortran_env, only: int8, error_unit
    ! Music theory elements common to the ForMIDI and ForSynth projects.
    ! We don't use "only:" to allow "use music" to include
    ! the whole "music_common" module:
    use music_common
    use utilities, only: checked_int8

    implicit none
    public

    !> The timing resolution of a MIDI file is defined by the number
    !> of MIDI ticks in a quarter note: the value 96 is commonly used because
    !> it can be divided by 2 and 3.
    !> We also define the most useful other values.
    !> https://en.wikipedia.org/wiki/Note_value
    integer, parameter :: quarter_note       = 96
    integer, parameter :: whole_note         = 4*quarter_note
    integer, parameter :: half_note          = 2*quarter_note
    integer, parameter :: eighth_note        = quarter_note/2    ! Quaver
    integer, parameter :: sixteenth_note     = quarter_note/4    ! Semiquaver
    integer, parameter :: thirty_second_note = quarter_note/8

    !> Common note levels expressed as MIDI velocities
    !> https://arxiv.org/pdf/1705.05322
    integer, parameter :: ffff_level = 127
    integer, parameter :: fff_level  = 112
    integer, parameter :: ff_level   =  96
    integer, parameter :: f_level    =  80
    integer, parameter :: mf_level   =  64
    integer, parameter :: mp_level   =  53
    integer, parameter :: p_level    =  42
    integer, parameter :: pp_level   =  31
    integer, parameter :: ppp_level  =  20
    integer, parameter :: pppp_level =   8

contains

    !> Returns the MIDI note number, from 12 (C0) to 127 (G9).
    !> The note name is composed of two or three characters, 
    !> for example "A4", "A#4", "Ab4", where the final character is 
    !> the octave.
    integer function MIDI_Note(note)
        character(*), intent(in) :: note
        ! 0 <= octave <=9
        integer :: octave
        ! Gap relative to A4 (note 69) in semitones:
        integer :: gap
        ! ASCII code of the 0 character:
        integer, parameter :: zero = iachar('0')

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
                gap = gap - 1
                octave = iachar(note(3:3)) - zero
            case ('#')
                gap = gap + 1
                octave = iachar(note(3:3)) - zero
            case default
                octave = iachar(note(2:2)) - zero
        end select

        if ((octave >= 0) .and. (octave <= 9)) then
            gap = gap + (octave - 4) * 12
        else
            write(error_unit, *) "ERROR 5: octave out of bounds [0; 9]"
            error stop 5
        end if

        ! Computing and returning the MIDI note number (A4 is 69):
        MIDI_Note = 69 + gap
    end function MIDI_Note

    !> Receives a MIDI note (for example 69),
    !> and returns the name of the note (for example A4).
    !> It works also with the octave -1, although most of its notes
    !> are too low for hearing.
    function note_name(MIDI_note) result(name)
        integer, intent(in) :: MIDI_note
        integer :: m
        character(2)  :: octave
        character(4)  :: name

        m = checked_int8(MIDI_note)
        write(octave, '(I0)') (m / 12) - 1
        name = trim(CHROMATIC_SCALE(mod(m, 12) + 1)) // octave
    end function

    !> Returns the value of a dotted note.
    integer function dotted(value)
        integer, intent(in) :: value

        dotted = value + value/2
    end function

end module music
