! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-04-20

! A stochastic blues
program demo3
    use, intrinsic :: iso_fortran_env, only: int8, int16, int32, dp=>real64
    use formidi
    use music
    use MIDI_control_changes
    use GM_instruments

    implicit none
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

    call init_formidi()

    print *, "Output file: demo3.mid"

    tonic = get_MIDI_note("C1")

    ! Create a file with 3 tracks (including the metadata track):
    call create_MIDI_file("demo3.mid", 1_int8, 3_int16, quarter_noteblues)

    ! Metadata track:
    size_pos = write_MIDI_track_header()
    ! A quarter note will last 1000000 µs = 1 s => tempo = 60 bpm
    call MIDI_tempo(1000000)
    call write_end_of_MIDI_track()
    call write_MIDI_track_size(size_pos)

    ! A first music track:
    size_pos = write_MIDI_track_header()

    call MIDI_Control_Change(0_int8, Effects_1_Depth, 64_int8)  ! Reverb
    ! Modulation:
    call MIDI_Control_Change(0_int8, Modulation_Wheel_or_Lever, 40_int8)
    ! Instrument:
    call MIDI_Program_Change(0_int8, Distortion_Guitar)

    ! A blues scale C, Eb, F, Gb, G, Bb, repeated at each octave.
    ! The MIDI note 0 is a C-1, but can not be heard (f=8.18 Hz).
    ! https://en.wikipedia.org/wiki/Hexatonic_scale#Blues_scale
    ! We copy the blues scale at the beginning of the array:
    do j = 0, 5
        b_scale(j) = get_MIDI_note(trim(HEXATONIC_BLUES_SCALE(j+1))//"0") - 12_int8
    end do

    ! And we copy it as many times as possible:
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
    call MIDI_Control_Change(drums, Effects_1_Depth, 64_int8)  ! Reverb

    do i = 1, length*2
        call MIDI_delta_time(0_int32)
        call MIDI_Note(ON, drums, Closed_Hi_Hat, 80_int8)

        if (mod(i, 6) == 4) then
            call MIDI_delta_time(0_int32)
            call MIDI_Note(OFF, drums, Acoustic_Snare, 92_int8)
            call MIDI_delta_time(0_int32)
            call MIDI_Note(ON, drums, Acoustic_Snare, 92_int8)
        else if ((mod(i, 6) == 1) .or. (mod(i, 12) == 6)) then
            call MIDI_delta_time(0_int32)
            call MIDI_Note(OFF, drums, Acoustic_Bass_Drum, 127_int8)
            call MIDI_delta_time(0_int32)
            call MIDI_Note(ON, drums, Acoustic_Bass_Drum, 127_int8)
        end if

        call MIDI_delta_time(quarter_noteblues / 3)
        call MIDI_Note(OFF, drums, Closed_Hi_Hat, 64_int8)
    end do

    call write_end_of_MIDI_track()
    call write_MIDI_track_size(size_pos)

    call close_MIDI_file()

end program demo3
