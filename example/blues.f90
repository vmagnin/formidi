! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-10

! A stochastic blues
program blues
    use, intrinsic :: iso_fortran_env, only: int8, int16, int32, dp=>real64
    use MIDI_file_class
    use music
    use MIDI_control_changes
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi
    integer(int32) :: duration
    integer(int32), parameter :: quarter_noteblues = 120
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

    print *, "Output file: blues.mid"

    tonic = MIDI_Note("C1")

    ! Create a file with 3 tracks (including the metadata track):
    ! A quarter note will last 1000000 µs = 1 s => tempo = 60 bpm
    call midi%new("blues.mid", format=1_int8, tracks=3_int16, division=quarter_noteblues, tempo=1000000)
    call midi%end_of_track()

    ! A first music track:
    call midi%track_header()

    call midi%Control_Change(channel=0_int8, type=Effects_1_Depth, ctl_value=64_int8)  ! Reverb
    ! Modulation:
    call midi%Control_Change(channel=0_int8, type=Modulation_Wheel_or_Lever, ctl_value=40_int8)
    ! Instrument:
    call midi%Program_Change(channel=0_int8, instrument=Distortion_Guitar)

    ! A blues scale C, Eb, F, Gb, G, Bb, repeated at each octave.
    ! The MIDI note 0 is a C-1, but can not be heard (f=8.18 Hz).
    ! https://en.wikipedia.org/wiki/Hexatonic_scale#Blues_scale
    ! We copy the blues scale at the beginning of the array:
    do j = 0, 5
        b_scale(j) = MIDI_Note(trim(HEXATONIC_BLUES_SCALE(j+1))//"0") - 12_int8
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
        call midi%play_chord(channel=0_int8, note=b_scale(note), chord=POWER_CHORD, velocity=40_int8, duration=duration)

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

    call midi%end_of_track()

    ! Drums track:
    call midi%track_header()
    call midi%Control_Change(channel=drums, type=Effects_1_Depth, ctl_value=64_int8)  ! Reverb

    do i = 1, length*2
        call midi%delta_time(0_int32)
        ! On the drum channel, each note corresponds to a percussion:
        call midi%Note(event=ON, channel=drums, MIDI_note=Closed_Hi_Hat, velocity=80_int8)

        if (mod(i, 6) == 4) then
            call midi%delta_time(0_int32)
            call midi%Note(event=OFF, channel=drums, MIDI_note=Acoustic_Snare, velocity=92_int8)
            call midi%delta_time(0_int32)
            call midi%Note(event=ON, channel=drums, MIDI_note=Acoustic_Snare, velocity=92_int8)
        else if ((mod(i, 6) == 1) .or. (mod(i, 12) == 6)) then
            call midi%delta_time(0_int32)
            call midi%Note(event=OFF, channel=drums, MIDI_note=Acoustic_Bass_Drum, velocity=127_int8)
            call midi%delta_time(0_int32)
            call midi%Note(event=ON, channel=drums, MIDI_note=Acoustic_Bass_Drum, velocity=127_int8)
        end if

        call midi%delta_time(quarter_noteblues / 3)
        call midi%Note(event=OFF, channel=drums, MIDI_note=Closed_Hi_Hat, velocity=64_int8)
    end do

    call midi%end_of_track()

    call midi%close()

end program blues
