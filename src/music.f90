! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring
!          algorithmic music
! License GNU GPLv3
! Vincent Magnin
! Last modifications: 2022-11-22

module music
    !---------------------------------------------------------------------------
    ! Contains music theory elements: scales, circle of fifths, chords, etc.
    !---------------------------------------------------------------------------

    use, intrinsic :: iso_fortran_env, only: int8, int32
    use formidi, only : MIDI_delta_time, MIDI_Note, ON, OFF

    implicit none

    ! We define some scales, excluding the octave of the first note.
    ! Always use the trim() function to remove trailing spaces.
    ! https://en.wikipedia.org/wiki/Scale_(music)
    character(2), dimension(1:12), parameter :: CHROMATIC_SCALE = &
                 & ['C ','C#','D ','D#','E ','F ','F#','G ','G#','A ','A#','B ']
    ! https://en.wikipedia.org/wiki/Major_scale
    character(1), dimension(1:7),  parameter :: MAJOR_SCALE = &
                                                 & ['C','D','E','F','G','A','B']
    ! https://en.wikipedia.org/wiki/Minor_scale#Harmonic_minor_scale
    character(2), dimension(1:7),  parameter :: HARMONIC_MINOR_SCALE = &
                                          & ['A ','B ','C ','D ','E ','F ','G#']
    ! https://en.wikipedia.org/wiki/Pentatonic_scale#Major_pentatonic_scale
    character(1), dimension(1:5),  parameter :: MAJOR_PENTATONIC_SCALE = &
                                                         & ['C','D','E','G','A']
    ! https://en.wikipedia.org/wiki/Hexatonic_scale#Blues_scale
    character(2), dimension(1:6),  parameter :: HEXATONIC_BLUES_SCALE = &
                                               & ['C ','Eb','F ','Gb','G ','Bb']
    ! https://en.wikipedia.org/wiki/Whole_tone_scale
    character(2), dimension(1:6),  parameter :: WHOLE_TONE_SCALE = &
                                               & ['C ','D ','E ','F#','G#','A#']

    ! https://en.wikipedia.org/wiki/Circle_of_fifths
    ! Always use the trim() function to remove trailing spaces.
    character(2), dimension(1:12) :: CIRCLE_OF_FIFTHS_MAJOR = &
                 & ['C ','G ','D ','A ','E ','B ','Gb','Db','Ab','Eb','Bb','F ']
    character(2), dimension(1:12) :: CIRCLE_OF_FIFTHS_MINOR = &
                 & ['A ','E ','B ','F#','C#','G#','Eb','Bb','F ','C ','G ','D ']

    ! Some frequent chords.
    ! These arrays can be passed to the write_chord() subroutine.
    ! https://en.wikipedia.org/wiki/Chord_(music)
    integer, parameter :: MAJOR_CHORD(1:3) = [ 0, 4, 7 ]
    integer, parameter :: MINOR_CHORD(1:3) = [ 0, 3, 7 ]
    integer, parameter :: DOMINANT_7TH_CHORD(1:4) = [ 0, 4, 7, 10 ]
    integer, parameter :: SUS2_CHORD(1:3) = [ 0, 2, 7 ]
    integer, parameter :: SUS4_CHORD(1:3) = [ 0, 5, 7 ]

    private

    public :: write_chord, MAJOR_CHORD, MINOR_CHORD, DOMINANT_7TH_CHORD, &
            & SUS2_CHORD, SUS4_CHORD, CHROMATIC_SCALE, &
            & MAJOR_SCALE, MAJOR_PENTATONIC_SCALE, WHOLE_TONE_SCALE, &
            & HEXATONIC_BLUES_SCALE, HARMONIC_MINOR_SCALE, &
            & CIRCLE_OF_FIFTHS_MAJOR, CIRCLE_OF_FIFTHS_MINOR

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

end module music
