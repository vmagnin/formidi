! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-15

!--------------------------------------
! A random walk on the circle of fifths
!--------------------------------------
program circle_of_fifths
    use, intrinsic :: iso_fortran_env, only: dp=>real64
    use MIDI_file_class
    use music
    use MIDI_control_changes, only: Effects_1_Depth
    ! Contains the list of General MIDI 128 instruments and 47 percussions:
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi
    integer :: channel, instrument, velocity, note
    character(3) :: name
    logical  :: major
    integer, parameter :: length = 200
    integer  :: i
    real(dp) :: p

    ! Create a file with 2 tracks (including the metadata track):
    ! The first track is always a metadata track. We define the 
    ! tempo: a quarter note will last 500000 µs = 0.5 s => tempo = 120 bpm
    call midi%new("circle_of_fifths.mid", format=1, tracks=2, divisions=quarter_note, tempo=500000)

    ! (1) The single music track:
    call midi%track_header()

    ! Sounds also good with instruments String_Ensemble_2 and Pad_8_sweep:
    instrument = Choir_Aahs
    ! We will use altenatively MIDI channels 0 and 1 to avoid cutting
    ! the tail of each chord:
    call midi%Program_Change(channel=0, instrument=instrument)
    call midi%Program_Change(channel=1, instrument=instrument)
    ! Heavy (127) reverb effect:
    call midi%Control_Change(channel=0, type=Effects_1_Depth, ctl_value=127)  ! Reverb
    call midi%Control_Change(channel=1, type=Effects_1_Depth, ctl_value=127)  ! Reverb

    ! We start with C Major (note at the top of the Major circle):
    note = 1
    major = .true.
    name = trim(CIRCLE_OF_FIFTHS_MAJOR(note)) // "4"
    call midi%play_chord(channel=0, note=MIDI_Note(name), chord=MAJOR_CHORD, velocity=90, value=4*quarter_note)

    ! A random walk with three events: we can go one note clockwise,
    ! one note counterclockwise or switch Major<->minor.
    do i = 1, length
        ! A random number 0 <= p < 3
        call random_number(p)
        p = 3 * p
        ! The three possible events:
        if (p >= 2.0_dp) then
            note = note + 1
            if (note > 12) note = 1
        else if (p >= 1.0_dp) then
            note = note - 1
            if (note < 1) note = 12
        else
            major = .not. major
        end if

        ! Alternate between channels 0 and 1:
        channel = mod(i, 2)

        ! The volume will evolve, to obtain some dynamics:
        velocity = 90 + int(20*sin(real(i)))

        ! Write a major or minor chord on the track:
        if (major) then
            name = trim(CIRCLE_OF_FIFTHS_MAJOR(note)) // "4"
            call midi%play_chord(channel, MIDI_Note(name), MAJOR_CHORD, velocity, 4*quarter_note)
        else
            name = trim(CIRCLE_OF_FIFTHS_MINOR(note)) // "4"
            call midi%play_chord(channel, MIDI_Note(name), MINOR_CHORD, velocity, 4*quarter_note)
        end if
    end do

    call midi%end_of_track()

    call midi%close()

    print *,"You can now play the file ", midi%get_name()
end program circle_of_fifths
