! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-04-20

! Based on the first measures of Pachelbel's Canon
! https://en.wikipedia.org/wiki/Pachelbel%27s_Canon
program demo2
    use, intrinsic :: iso_fortran_env, only: int8, int16, int32
    use formidi
    use music
    use MIDI_control_changes
    use GM_instruments

    implicit none
    integer(int32) :: size_pos
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

    call init_formidi()

    print *, "Output file: demo2.mid"
    ! Create a file with 5 tracks (including the metadata track):
    call create_MIDI_file("demo2.mid", 1_int8, 5_int16, quarter_note)

    ! Metadata track:
    size_pos = write_MIDI_track_header()
    ! A quarter note will last 1000000 µs = 1 s => tempo = 60 bpm
    call MIDI_copyright_notice("Public domain")
    call MIDI_tempo(1000000)
    call write_end_of_MIDI_track()
    call write_MIDI_track_size(size_pos)

    ! A first music track: ground bass
    size_pos = write_MIDI_track_header()
    call MIDI_sequence_track_name("ground bass")
    call MIDI_Control_Change(0_int8, Effects_1_Depth, 64_int8)  ! Reverb
    ! Instrument on channel 0:
    call MIDI_Program_Change(0_int8, String_Ensemble_1)

    do j = 1, 30
        do i = 0, 7
            call write_MIDI_note(0_int8, get_MIDI_note(bass(i)), 64_int8, quarter_note)
        end do
    end do
    call write_end_of_MIDI_track()
    call write_MIDI_track_size(size_pos)

    ! Other music tracks: a three voices canon
    do track = 3, 5
        size_pos = write_MIDI_track_header()
        write(track_name, '("Canon voice ",I0)') track-2
        call MIDI_sequence_track_name(track_name)
        call MIDI_Control_Change(track, Effects_1_Depth, 64_int8)  ! Reverb
        call write_MIDI_note(track, 0_int8, 0_int8, 8*quarter_note*(track - 2))

        do j = 0, 14
            ! Let's change the instrument to add some variations:
            call MIDI_Program_Change(track, &
                                    & int(instrument((track - 3) + j), int8))
            ! Let's play the theme:
            do i = 0, 15
                call write_MIDI_note(track, get_MIDI_note(theme(i)), 64_int8, quarter_note)
            end do
        end do

        call write_end_of_MIDI_track()
        call write_MIDI_track_size(size_pos)
    end do

    call close_MIDI_file()

end program demo2
