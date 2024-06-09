! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-09

!--------------------------------------
! A random walk on the circle of fifths
!--------------------------------------
program circle_of_fifths
    use, intrinsic :: iso_fortran_env, only: int8, int16, int32, dp=>real64
    use MIDI_file_class
    use music
    use MIDI_control_changes
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi
    integer(int32) :: size_pos
    integer(int8)  :: channel
    integer(int8)  :: instrument, velocity
    integer        :: note
    character(3)   :: name
    logical        :: major
    integer, parameter :: length = 200
    integer  :: i
    real(dp) :: p

    call midi%init_formidi()

    print *, "Output file: circle_of_fifths.mid"
    ! Create a file with 2 tracks (including the metadata track):
    call midi%create_MIDI_file("circle_of_fifths.mid", 1_int8, 2_int16, quarter_note)

    ! The first track is always a metadata track. Here, we just define the 
    ! tempo: a quarter note will last 500000 µs = 0.5 s => tempo = 120 bpm
    size_pos = midi%write_MIDI_track_header()
    call midi%MIDI_tempo(500000)
    call midi%write_end_of_MIDI_track()
    call midi%write_MIDI_track_size(size_pos)

    ! The music track:
    size_pos = midi%write_MIDI_track_header()

    ! Sounds also good with instruments String_Ensemble_2 and Pad_8_sweep:
    instrument = Choir_Aahs
    ! We will use altenatively MIDI channels 0 and 1 to avoid cutting
    ! the tail of each chord:
    call midi%MIDI_Program_Change(0_int8, instrument)
    call midi%MIDI_Program_Change(1_int8, instrument)
    ! Heavy reverb effect:
    call midi%MIDI_Control_Change(0_int8, Effects_1_Depth, 127_int8)  ! Reverb
    call midi%MIDI_Control_Change(1_int8, Effects_1_Depth, 127_int8)  ! Reverb

    ! We start with C Major (note at the top of the Major circle):
    note = 1
    major = .true.
    name = trim(CIRCLE_OF_FIFTHS_MAJOR(note)) // "4"
    call midi%write_chord(0_int8, get_MIDI_note(name), MAJOR_CHORD, 90_int8, 4*quarter_note)

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
        channel = int(mod(i, 2), kind=int8)

        ! The volume will evolve, to create some dynamics:
        velocity = 90_int8 + int(20*sin(real(i)), kind=int8)

        ! Write the chord on the track:
        if (major) then
            name = trim(CIRCLE_OF_FIFTHS_MAJOR(note)) // "4"
            call midi%write_chord(channel, get_MIDI_note(name), MAJOR_CHORD, velocity, 4*quarter_note)
        else
            name = trim(CIRCLE_OF_FIFTHS_MINOR(note)) // "4"
            call midi%write_chord(channel, get_MIDI_note(name), MINOR_CHORD, velocity, 4*quarter_note)
        end if

    end do

    call midi%write_end_of_MIDI_track()
    ! The size of the track is now known and must be written in its header:
    call midi%write_MIDI_track_size(size_pos)

    call midi%close_MIDI_file()

end program circle_of_fifths
