! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-04-20

!--------------------------------------
! A random walk on the circle of fifths
!--------------------------------------
program demo4
    use, intrinsic :: iso_fortran_env, only: int8, int16, int32, dp=>real64
    use formidi
    use music
    use MIDI_control_changes
    use GM_instruments

    implicit none
    integer(int32) :: size_pos
    integer(int8)  :: channel
    integer(int8)  :: instrument, velocity
    integer        :: note
    character(3)   :: name
    logical        :: major
    integer, parameter :: length = 200
    integer  :: i
    real(dp) :: p

    call init_formidi()

    print *, "Output file: demo4.mid"
    ! Create a file with 2 tracks (including the metadata track):
    call create_MIDI_file("demo4.mid", 1_int8, 2_int16, quarter_note)

    ! The first track is always a metadata track. Here, we just define the 
    ! tempo: a quarter note will last 500000 µs = 0.5 s => tempo = 120 bpm
    size_pos = write_MIDI_track_header()
    call MIDI_tempo(500000)
    call write_end_of_MIDI_track()
    call write_MIDI_track_size(size_pos)

    ! The music track:
    size_pos = write_MIDI_track_header()

    ! Sounds also good with instruments String_Ensemble_2 and Pad_8_sweep:
    instrument = Choir_Aahs
    ! We will use altenatively MIDI channels 0 and 1 to avoid cutting
    ! the tail of each chord:
    call MIDI_Program_Change(0_int8, instrument)
    call MIDI_Program_Change(1_int8, instrument)
    ! Heavy reverb effect:
    call MIDI_Control_Change(0_int8, Effects_1_Depth, 127_int8)  ! Reverb
    call MIDI_Control_Change(1_int8, Effects_1_Depth, 127_int8)  ! Reverb

    ! We start with C Major (note at the top of the Major circle):
    note = 1
    major = .true.
    name = trim(CIRCLE_OF_FIFTHS_MAJOR(note)) // "4"
    call write_chord(0_int8, get_MIDI_note(name), MAJOR_CHORD, 90_int8, 4*quarter_note)

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
            call write_chord(channel, get_MIDI_note(name), MAJOR_CHORD, velocity, 4*quarter_note)
        else
            name = trim(CIRCLE_OF_FIFTHS_MINOR(note)) // "4"
            call write_chord(channel, get_MIDI_note(name), MINOR_CHORD, velocity, 4*quarter_note)
        end if

    end do

    call write_end_of_MIDI_track()
    ! The size of the track is now known and must be written in its header:
    call write_MIDI_track_size(size_pos)

    call close_MIDI_file()

end program demo4
