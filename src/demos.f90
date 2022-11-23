! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GNU GPLv3
! Vincent Magnin
! Last modifications: 2022-11-23

module demos
    use, intrinsic :: iso_fortran_env, only: int8, int16, int32, dp=>real64
    use formidi
    use music

    implicit none

    private

    public :: demo1, demo2, demo3, demo4

contains

    subroutine demo1()
        integer(int32) :: size_pos

        ! Create a file with 2 tracks (including the metadata track):
        call create_MIDI_file("demo1.mid", 1_int8, 2_int16, quarter_note)

        ! The first track is always a metadata track. Here, we just define the 
        ! tempo: a quarter note will last 500000 µs = 0.5 s.
        size_pos = write_MIDI_track_header()
        call MIDI_tempo(500000)
        call write_end_of_MIDI_track()
        call write_MIDI_track_size(size_pos)

        ! The music track:
        size_pos = write_MIDI_track_header()

        ! Instrument 93 (in the 0..127 range) is "Synth Pad 6 (metallic)":
        call MIDI_Program_Change(0_int8, 93_int8)

        ! Close Encounters of the Third Kind:
        ! https://www.youtube.com/watch?v=S4PYI6TzqYk
        call write_MIDI_note(0_int8, get_MIDI_note("G4"), 64_int8, quarter_note)
        call write_MIDI_note(0_int8, get_MIDI_note("A4"), 64_int8, quarter_note)
        call write_MIDI_note(0_int8, get_MIDI_note("F4"), 64_int8, quarter_note)
        call write_MIDI_note(0_int8, get_MIDI_note("F3"), 64_int8, quarter_note)
        call write_MIDI_note(0_int8, get_MIDI_note("C4"), 64_int8, 2*quarter_note)

        call write_end_of_MIDI_track()
        ! The size of the track is now known and must be written in its header:
        call write_MIDI_track_size(size_pos)

        call close_MIDI_file()
    end subroutine demo1


    subroutine demo2()
        ! Based on the first measures of Pachelbel's Canon
        ! https://en.wikipedia.org/wiki/Pachelbel%27s_Canon
        integer(int32) :: size_pos
        ! MIDI notes of the bass and theme:
        integer(int8) :: bass(0:7) = [ 50, 45, 47, 42, 43, 38, 43, 45 ]
        integer(int8) :: theme(0:15) = [ 78, 76, 74, 73, 71, 69, 71, 73, 74, &
                                       & 73, 71, 69, 67, 66, 67, 64 ]
        ! List of General MIDI instruments to use sequentially:
        integer(int8) :: instrument(0:16) = [ 40, 41, 42, 44, 45, 48, 49, 51, &
                                        & 52, 89, 90, 91, 92, 94, 95, 99, 100 ]
        integer(int8) :: track
        integer :: i, j

        ! Create a file with 5 tracks (including the metadata track):
        call create_MIDI_file("demo2.mid", 1_int8, 5_int16, quarter_note)

        ! Metadata track:
        size_pos = write_MIDI_track_header()
        call MIDI_tempo(1000000)
        call write_end_of_MIDI_track()
        call write_MIDI_track_size(size_pos)

        ! A first music track: ground bass
        size_pos = write_MIDI_track_header()
        call MIDI_Control_Change(0_int8, reverb, 64_int8)
        ! "String ensemble 1" is instrument 48:
        call MIDI_Program_Change(0_int8, 48_int8)

        do j = 1, 30
            do i = 0, 7
                call write_MIDI_note(0_int8, bass(i), 64_int8, quarter_note)
            end do
        end do
        call write_end_of_MIDI_track()
        call write_MIDI_track_size(size_pos)

        ! A second music track: a three voices canon
        do track = 3, 5
            size_pos = write_MIDI_track_header()
            call MIDI_Control_Change(track, reverb, 64_int8)
            call write_MIDI_note(track, 0_int8, 0_int8, 8*quarter_note*(track - 2))

            do j = 0, 14
                ! Let's change the instrument to add some variations:
                call MIDI_Program_Change(track, &
                                       & int(instrument((track - 3) + j), int8))
                ! Let's play the theme:
                do i = 0, 15
                    call write_MIDI_note(track, theme(i), 64_int8, quarter_note)
                end do
            end do

            call write_end_of_MIDI_track()
            call write_MIDI_track_size(size_pos)
        end do

        call close_MIDI_file()
    end subroutine demo2


    subroutine demo3()
        ! A stochastic blues
        integer(int32) :: size_pos, duration
        integer(int32), parameter :: quarter_noteblues = 120_int32
        real(dp) :: p, delta
        integer :: i, j
        integer, parameter ::  nb_notes = 6
        integer, parameter ::  length = 200
        integer(int8) :: b_scale(0:127)     ! Blues
        integer :: jmax
        integer(int8) :: octave
        integer(int8) :: note
        logical :: again
        ! The tonic is the C note:
        integer(int8) :: tonic

        tonic = get_MIDI_note("C1")

        ! Create a file with 3 tracks (including the metadata track):
        call create_MIDI_file("demo3.mid", 1_int8, 3_int16, quarter_noteblues)

        ! Metadata track:
        size_pos = write_MIDI_track_header()
        call MIDI_tempo(1000000)
        call write_end_of_MIDI_track()
        call write_MIDI_track_size(size_pos)

        ! A first music track:
        size_pos = write_MIDI_track_header()

        call MIDI_Control_Change(0_int8, reverb, 64_int8)
        ! Modulation:
        call MIDI_Control_Change(0_int8, 1_int8, 40_int8)
        ! Distorsion guitar (30 in the 0..127 range):
        call MIDI_Program_Change(0_int8, 30_int8)

        ! A blues scale C, Eb, F, Gb, G, Bb, repeated at each octave.
        ! The MIDI note 0 is a C.
        ! https://en.wikipedia.org/wiki/Hexatonic_scale#Blues_scale
        b_scale(0) = 0_int8
        b_scale(1) = 3_int8
        b_scale(2) = 5_int8
        b_scale(3) = 6_int8
        b_scale(4) = 7_int8
        b_scale(5) = 10_int8
        jmax = nb_notes - 1
        octave = 1
        again = .true.
        do
            do j = 0, nb_notes-1
                if (b_scale(j) + octave*12 <= 127) then
                    jmax = octave*nb_notes + j
                    b_scale(jmax) = b_scale(j) + octave*12_int8
                else
                    again = .false.
                end if
            end do
            octave = octave + 1_int8
            if (.not. again) exit
        end do

        ! Let's make a random walk on that scale:
        duration = quarter_noteblues
        note = tonic
        do i = 1, length
            call write_chord(0_int8, b_scale(note), POWER_CHORD, 40_int8, duration)

            ! Random walk:
            call random_number(p)
            ! We need a kind of restoring force to avoid going too far:
            delta = ((b_scale(note) - b_scale(tonic)) / 12.0_dp) * 0.45_dp
            if (p >= 0.55_dp + delta) then
                if (note < jmax) note = note + 1_int8
            else if (p >= 0.1_dp) then
                if (note > 0) note = note - 1_int8
            end if

            ! Duration:
            call random_number(p)
            if (p >= 0.75_dp) then
                duration = quarter_noteblues
            else
                duration = quarter_noteblues / 4
            end if
        end do

        call write_end_of_MIDI_track()
        call write_MIDI_track_size(size_pos)

        ! Drums track:
        size_pos = write_MIDI_track_header()
        call MIDI_Control_Change(drums, reverb, 64_int8)

        do i = 1, length*3
            ! Closed Hi-hat (42)
            call MIDI_delta_time(0_int32)
            call MIDI_Note(ON, drums, 42_int8, 80_int8)

            if (mod(i, 6) == 4) then
                ! Acoustic snare (38)
                call MIDI_delta_time(0_int32)
                call MIDI_Note(OFF, drums, 38_int8, 92_int8)
                call MIDI_delta_time(0_int32)
                call MIDI_Note(ON, drums, 38_int8, 92_int8)
            else if ((mod(i, 6) == 1) .or. (mod(i, 12) == 6)) then
                ! Acoustic bass drum (35)
                call MIDI_delta_time(0_int32)
                call MIDI_Note(OFF, drums, 35_int8, 127_int8)
                call MIDI_delta_time(0_int32)
                call MIDI_Note(ON, drums, 35_int8, 127_int8)
            end if

            call MIDI_delta_time(quarter_noteblues / 3)
            call MIDI_Note(OFF, drums, 42_int8, 64_int8)
        end do

        call write_end_of_MIDI_track()
        call write_MIDI_track_size(size_pos)

        call close_MIDI_file()
    end subroutine demo3


    subroutine demo4()
        !--------------------------------------
        ! A random walk on the circle of fifths
        !--------------------------------------
        integer(int32) :: size_pos
        integer(int8)  :: channel
        integer(int8)  :: instrument, velocity
        integer        :: note
        character(3)   :: name
        logical        :: major
        integer, parameter :: length = 200
        integer  :: i
        real(dp) :: p

        ! Create a file with 2 tracks (including the metadata track):
        call create_MIDI_file("demo4.mid", 1_int8, 2_int16, quarter_note)

        ! The first track is always a metadata track. Here, we just define the 
        ! tempo: a quarter note will last 500000 µs = 0.5 s.
        size_pos = write_MIDI_track_header()
        call MIDI_tempo(500000)
        call write_end_of_MIDI_track()
        call write_MIDI_track_size(size_pos)

        ! The music track:
        size_pos = write_MIDI_track_header()

        ! Instrument 52 (in the 0..127 range) is "Choir Aahs".
        ! Sounds also good with instruments 49 and 95.
        instrument = 52_int8
        ! We will use altenatively MIDI channels 0 and 1 to avoid cutting
        ! the tail of each chord:
        call MIDI_Program_Change(0_int8, instrument)
        call MIDI_Program_Change(1_int8, instrument)
        ! Heavy reverb effect:
        call MIDI_Control_Change(0_int8, reverb, 127_int8)
        call MIDI_Control_Change(1_int8, reverb, 127_int8)

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
    end subroutine demo4

end module demos
