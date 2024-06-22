! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-22

! A stochastic blues
program blues
    use, intrinsic :: iso_fortran_env, only: dp=>real64
    use MIDI_file_class
    use music
    use MIDI_control_changes, only: Effects_1_Depth, Modulation_Wheel_or_Lever, Pan
    ! Contains the list of General MIDI 128 instruments and 47 percussions:
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi
    real(dp) :: p, delta
    integer :: i, j, jmax
    integer, parameter :: nb_notes = 6
    integer, parameter :: length = 200
    integer :: b_scale(0:127)     ! Blues scale
    integer :: octave, note, value
    logical :: again
    ! The tonic is the C note:
    integer :: tonic

    tonic = MIDI_Note("C1")

    ! Create a file with 3 tracks (including the metadata track):
    ! A quarter note will last 1000000 µs = 1 s => tempo = 60 bpm
    call midi%new("blues.mid", format=1, tracks=3, divisions=quarter_note, tempo=1000000)

    ! (1) A first music track with guitar:
    call midi%track_header()
    ! Reverb:
    call midi%Control_Change(channel=0, type=Effects_1_Depth, ctl_value=64)
    ! Modulation:
    call midi%Control_Change(channel=0, type=Modulation_Wheel_or_Lever, ctl_value=40)
    ! Panning, slightly on the left (center is 64):
    call midi%Control_Change(channel=0, type=Pan, ctl_value=44)
    ! Instrument:
    call midi%Program_Change(channel=0, instrument=Distortion_Guitar)

    ! A blues scale C, Eb, F, Gb, G, Bb, repeated at each octave.
    ! The MIDI note 0 is a C-1, but can not be heard (f=8.18 Hz).
    ! https://en.wikipedia.org/wiki/Hexatonic_scale#Blues_scale
    ! We copy the blues scale at the beginning of the array:
    do j = 0, 5
        b_scale(j) = MIDI_Note(trim(HEXATONIC_BLUES_SCALE(j+1))//"0") - 12
    end do

    ! And we copy it as many times as possible:
    jmax = nb_notes - 1
    octave = 1
    again = .true.
    do
        do j = 0, nb_notes-1
            if (b_scale(j) + octave*12 <= 127) then
                jmax = octave*nb_notes + j
                b_scale(jmax) = b_scale(j) + octave*12
            else
                again = .false.
            end if
        end do
        octave = octave + 1
        if (.not. again) exit
    end do

    ! Let's make a random walk on that scale:
    value = quarter_note
    note = tonic
    do i = 1, length
        call midi%play_chord(channel=0, note=b_scale(note), chord=POWER_CHORD, velocity=p_level-2, value=value)

        ! Random walk:
        call random_number(p)
        ! We need a kind of restoring force to avoid going too far:
        delta = ((b_scale(note) - b_scale(tonic)) / 12.0_dp) * 0.45_dp
        if (p >= 0.55_dp + delta) then
            if (note < jmax) note = note + 1
        else if (p >= 0.1_dp) then
            if (note > 0) note = note - 1
        end if

        ! Duration:
        call random_number(p)
        if (p >= 0.75_dp) then
            value = quarter_note
        else
            value = sixteenth_note
        end if
    end do

    call midi%end_of_track()

    ! (2) Drums track (channel 9 by default):
    call midi%track_header()
    ! Reverb:
    call midi%Control_Change(channel=drums, type=Effects_1_Depth, ctl_value=64)
    ! Panning, slightly on the right (center is 64):
    call midi%Control_Change(channel=drums, type=Pan, ctl_value=84)

    do i = 1, length*2
        call midi%delta_time(0)
        ! On the drum channel, each note corresponds to a percussion:
        call midi%Note_ON(channel=drums, note=Closed_Hi_Hat, velocity=80)

        ! We use modulo to create a rhythm:
        if (mod(i, 6) == 4) then
            call midi%delta_time(0)
            call midi%Note_ON(channel=drums, note=Acoustic_Snare, velocity=92)
        else if ((mod(i, 6) == 1) .or. (mod(i, 12) == 6)) then
            call midi%delta_time(0)
            call midi%Note_ON(channel=drums, note=Acoustic_Bass_Drum, velocity=127)
        end if

        call midi%delta_time(quarter_note / 3)
        call midi%Note_OFF(channel=drums, note=Closed_Hi_Hat, velocity=64)

        if (mod(i, 6) == 4) then
            call midi%delta_time(0)
            call midi%Note_OFF(channel=drums, note=Acoustic_Snare, velocity=92)
        else if ((mod(i, 6) == 1) .or. (mod(i, 12) == 6)) then
            call midi%delta_time(0)
            call midi%Note_OFF(channel=drums, note=Acoustic_Bass_Drum, velocity=127)
        end if
    end do

    call midi%end_of_track()

    call midi%close()

    print *,"You can now play the file ", midi%get_name()
end program blues
