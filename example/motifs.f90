! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin, 2024-07-01
! Last modifications: 2024-07-04

!> An example mixing Dmitri Shostakovich's [DSCH motif](https://en.wikipedia.org/wiki/DSCH_motif)
!> and [BACH motif](https://en.wikipedia.org/wiki/BACH_motif), with four
!> musical tracks.
program motifs
    use MIDI_file_class
    use music
    use MIDI_control_changes, only: Effects_1_Depth, Effects_3_Depth, Pan
    ! Contains the list of General MIDI 128 instruments and 47 percussions:
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi
    integer, parameter :: arpeggio(1:6) = [ 0, 7, 12, 7, 12, 7 ]
    integer, parameter :: octave=12
    integer :: values(1:6)
    integer :: i, j, k, n, v
    integer :: BACH(4)
    integer :: DSCH(4)
    integer :: scale(6)

    ! BACH and DSCH are in German notation:
    BACH(1) = MIDI_Note("Bb2")  ! B
    BACH(2) = MIDI_Note("A2")   ! A
    BACH(3) = MIDI_Note("C3")   ! C
    BACH(4) = MIDI_Note("B2")   ! H

    DSCH(1) = MIDI_Note("D3")   ! D
    DSCH(2) = MIDI_Note("Eb3")  ! Es
    DSCH(3) = MIDI_Note("C3")   ! C
    DSCH(4) = MIDI_Note("B2")   ! H

    ! The total value of the arpeggio is a whole note (four quarter notes):
    values(1) = dotted(eighth_note)
    values(2) = eighth_note
    values(3) = dotted(eighth_note)
    values(4) = eighth_note
    values(5) = dotted(eighth_note)
    values(6) = dotted(eighth_note)

    ! A scale composed of all notes in the two motifs:
    scale = [ MIDI_Note("A2"), MIDI_Note("Bb2"), MIDI_Note("B2"), MIDI_Note("C3"), MIDI_Note("D3"), MIDI_Note("Eb3")]

    ! Create a file with 5 tracks (including the metadata track):
    ! A quarter note will last 375000 µs = 0.375 s => tempo = 160 bpm
    ! The time signature is 4/4 (default value).
    call midi%new("motifs.mid", format=1, tracks=5, divisions=quarter_note, tempo=375000)

    ! (1) A bass track on MIDI channel 0
    call midi%track_header(track_name="bass")
    ! Chorus:
    call midi%Control_Change(channel=0, type=Effects_3_Depth, ctl_value=32)
    ! Panning, slightly on the left (center is 64):
    call midi%Control_Change(channel=0, type=Pan, ctl_value=44)
    ! Choosing the instrument:
    call midi%Program_Change(channel=0, instrument=Electric_Bass_finger)

    ! The four musical tracks will use the same loops, to follow the structure
    ! of the song and stay synchronized, using silence when necessary.

    ! Intro
    ! Silence (velocity=0):
    call midi%play_note(channel=0, note=0, velocity=0, value=whole_note)
    ! Playing the scale:
    do i = 1, size(scale)
        call midi%play_note(channel=0, note=scale(i), velocity=f_level, value=half_note)
    end do

    do k = 1, 2
        ! Chorus
        do j = 1, 4
            do i = 1, size(DSCH)
                ! Duration = whole note
                call midi%play_broken_chord(channel=0, note=DSCH(i), chord=arpeggio, velocity=ff_level, values=values)
            end do
        end do

        ! Verse
        do j = 1, 4
            do i = 1, size(BACH)
                ! Duration = whole note
                call midi%play_broken_chord(channel=0, note=BACH(i), chord=arpeggio, velocity=ff_level, values=values)
            end do
        end do
    end do

    ! Outro
    ! Reverb:
    call midi%Control_Change(channel=0, type=Effects_1_Depth, ctl_value=127)
    do i = 1, size(scale)
        ! With decreasing level and increasing duration:
        call midi%play_chord(channel=0, note=scale(i), chord=MAJOR_CHORD, &
                           & velocity=int(ff_level/(1.2**i)), value=int(half_note*1.2**i))
    end do

    call midi%end_of_track()

    !---------------------------------------------------------------------------
    ! (2) A synth track on MIDI channel 1
    call midi%track_header(track_name="synth")
    ! Reverb:
    call midi%Control_Change(channel=1, type=Effects_1_Depth, ctl_value=64)
    ! Panning, slightly on the right (center is 64):
    call midi%Control_Change(channel=1, type=Pan, ctl_value=80)
    ! Choosing the instrument:
    call midi%Program_Change(channel=1, instrument=Pad_2_warm)

    ! Intro
    ! Silence:
    call midi%play_note(channel=1, note=0, velocity=0, value=whole_note)
    ! Playing the scale:
    do i = 1, size(scale)
        call midi%play_chord(channel=1, note=scale(i), chord=MAJOR_CHORD, velocity=f_level, value=half_note)
    end do

    do k = 1, 2
        ! Chorus
        do j = 1, 4
            do i = 1, size(DSCH)
                call midi%play_chord(channel=1, note=DSCH(i), chord=MAJOR_CHORD, velocity=ff_level, value=whole_note)
            end do
        end do

        ! Verse
        do j = 1, 4
            do i = 1, size(BACH)
                call midi%play_chord(channel=1, note=BACH(i), chord=MAJOR_CHORD, velocity=ff_level, value=whole_note)
            end do
        end do
    end do

    call midi%end_of_track()

    !---------------------------------------------------------------------------
    ! (3) A drums track
    call midi%track_header(track_name="drums")
    ! Reverb:
    call midi%Control_Change(channel=drums, type=Effects_1_Depth, ctl_value=127)
    ! Panning (center is 64):
    call midi%Control_Change(channel=drums, type=Pan, ctl_value=64)

    ! Intro
    do i = 1, size(scale)+2
        call midi%play_note(channel=drums, note=Side_Stick, velocity=ff_level, value=half_note)
    end do

    do k = 1, 2
        ! Chorus
        do j = 1, 4
            ! The total value of the broken chord is a whole note (four quarter notes):
            do i = 1, size(DSCH)
                call midi%play_note(channel=drums, note=Bass_Drum_1,    velocity=ffff_level, &
                                  & value=quarter_note)
                call midi%play_note(channel=drums, note=Closed_Hi_Hat,  velocity=ffff_level, &
                                  & value=quarter_note)
                call midi%play_note(channel=drums, note=Bass_Drum_1,    velocity=ffff_level, &
                                  & value=quarter_note)
                call midi%play_note(channel=drums, note=Acoustic_Snare, velocity=ffff_level, &
                                  & value=quarter_note)
            end do
        end do

        ! Verse
        do j = 1, 4
            do i = 1, size(BACH)
                call midi%play_note(channel=drums, note=Bass_Drum_1,   velocity=ffff_level, value=quarter_note)
                call midi%play_note(channel=drums, note=Closed_Hi_Hat, velocity=ffff_level, value=quarter_note)
                call midi%play_note(channel=drums, note=Bass_Drum_1,   velocity=ffff_level, value=quarter_note)
                call midi%play_note(channel=drums, note=Closed_Hi_Hat, velocity=ffff_level, value=quarter_note)
            end do
        end do
    end do

    call midi%end_of_track()

    !---------------------------------------------------------------------------
    ! (4) A guitar track on MIDI channel 2
    call midi%track_header(track_name="guitar")
    ! Reverb:
    call midi%Control_Change(channel=2, type=Effects_1_Depth, ctl_value=127)
    ! Panning, slightly on the left (center is 64):
    call midi%Control_Change(channel=2, type=Pan, ctl_value=32)
    ! Choosing the instrument:
    call midi%Program_Change(channel=2, instrument=Acoustic_Guitar_nylon)

    ! Intro
    ! Silence:
    call midi%play_note(channel=2, note=0, velocity=0, value=whole_note)
    ! Silence:
    do i = 1, size(scale)
        call midi%play_note(channel=2, note=0, velocity=0, value=half_note)
    end do

    ! Base note:
    n = DSCH(1)+octave
    ! fifth=+7, fourth=+5, 7th=+10, octave=+12
    do k = 1, 2
        do j = 1, 4*4
            if ((k == 1).and.(j<=8)) then
                v = 0   ! silence at the beginning of the song
            else
                v = f_level-4
            end if
            call midi%play_note(channel=2, note=n+7, velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+5, velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+7, velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+5, velocity=v, value=quarter_note)
        end do

        do j = 1, 4
            call midi%play_note(channel=2, note=n+7,  velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+10, velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+7,  velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+10, velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+12, velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+10, velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+7,  velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+12, velocity=v, value=quarter_note)
        end do

        do j = 1, 4
            call midi%play_note(channel=2, note=n+7,  velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+10, velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+7,  velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+10, velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+12, velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+10, velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+7,  velocity=v, value=quarter_note)
            call midi%play_note(channel=2, note=n+5,  velocity=v, value=quarter_note)
        end do
    end do

    call midi%end_of_track()

    !---------------------------------------------------------------------------
    call midi%close()

    print *,"You can now play the file ", midi%get_name()

end program motifs
