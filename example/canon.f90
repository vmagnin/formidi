! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-10

! Based on the first measures of Pachelbel's Canon
! https://en.wikipedia.org/wiki/Pachelbel%27s_Canon
program canon
    use, intrinsic :: iso_fortran_env, only: int8, int16, int32
    use MIDI_file_class
    use music
    use MIDI_control_changes
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi
    ! Notes of the bass and theme:
    character(3), parameter :: bass(0:7) =  ["D3 ","A2 ","B2 ","F#2","G2 ", &
                                            &"D2 ","G2 ","A2 " ]
    character(3), parameter :: theme(0:15) = [ "F#5","E5 ","D5 ","C#5", &
                                                & "B4 ","A4 ","B4 ","C#5", &
                                                & "D5 ","C#5","B4 ","A4 ", &
                                                & "G4 ","F#4","G4 ","E4 " ]
    ! List of General MIDI instruments to use sequentially:
    integer(int8), parameter :: instrument(0:16) = [ 40, 41, 42, 44, 45, 48,&
                                & 49, 51, 52, 89, 90, 91, 92, 94, 95, 99, 100 ]
    integer(int8) :: track
    character(13) :: track_name
    integer :: i, j

    print *, "Output file: canon.mid"
    ! Create a file with 5 tracks (including the metadata track):
    ! A quarter note will last 1000000 µs = 1 s => tempo = 60 bpm
    call midi%new("canon.mid", SMF=1_int8, tracks=5_int16, q_ticks=quarter_note, tempo=1000000)
    call midi%copyright_notice("Public domain")
    call midi%end_of_track()

    ! A first music track: ground bass
    call midi%track_header()
    call midi%sequence_track_name("ground bass")
    call midi%Control_Change(channel=0_int8, type=Effects_1_Depth, ctl_value=64_int8)  ! Reverb
    ! Instrument on channel 0:
    call midi%Program_Change(channel=0_int8, instrument=String_Ensemble_1)

    do j = 1, 30
        do i = 0, 7
            call midi%play_note(channel=0_int8, note=get_MIDI_note(bass(i)), velocity=64_int8, duration=quarter_note)
        end do
    end do
    call midi%end_of_track()

    ! Other music tracks: a three voices canon
    do track = 3, 5
        call midi%track_header()
        write(track_name, '("Canon voice ",I0)') track-2
        call midi%sequence_track_name(track_name)
        call midi%Control_Change(channel=track, type=Effects_1_Depth, ctl_value=64_int8)  ! Reverb
        call midi%play_note(channel=track, note=0_int8, velocity=0_int8, duration=8*quarter_note*(track - 2))

        do j = 0, 14
            ! Let's change the instrument to add some variations:
            call midi%Program_Change(channel=track, &
                                    & instrument=int(instrument((track - 3) + j), int8))
            ! Let's play the theme:
            do i = 0, 15
                call midi%play_note(channel=track, note=get_MIDI_note(theme(i)), velocity=64_int8, duration=quarter_note)
            end do
        end do

        call midi%end_of_track()
    end do

    call midi%close()

end program canon
