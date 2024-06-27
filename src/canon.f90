! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-22

!> An example based on the first measures of Pachelbel's Canon
!> https://en.wikipedia.org/wiki/Pachelbel%27s_Canon
program canon
    use MIDI_file_class
    use music
    use MIDI_control_changes, only: Effects_1_Depth, Pan
    ! Contains the list of General MIDI 128 instruments and 47 percussions:
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi
    ! Notes of the bass and theme:
    character(3), parameter :: bass(1:8) =  ["D3 ","A2 ","B2 ","F#2","G2 ", &
                                            &"D2 ","G2 ","A2 " ]
    character(3), parameter :: theme(1:16) = [ "F#5","E5 ","D5 ","C#5", &
                                             & "B4 ","A4 ","B4 ","C#5", &
                                             & "D5 ","C#5","B4 ","A4 ", &
                                             & "G4 ","F#4","G4 ","E4 " ]
    ! List of General MIDI instruments to use sequentially:
    integer, parameter :: instrument(1:17) = [ 40, 41, 42, 44, 45, 48,&
                                 & 49, 51, 52, 89, 90, 91, 92, 94, 95, 99, 100 ]
    ! Pan value for each track:
    integer, parameter :: panning(2:5) = [ 54, 34, 74, 94 ]
    integer :: track
    character(13) :: track_name
    integer :: i, j

    ! Create a file with 5 tracks (including the metadata track):
    ! A quarter note will last 1000000 µs = 1 s => tempo = 60 bpm
    call midi%new("canon.mid", format=1, tracks=5, divisions=quarter_note, tempo=1000000, copyright="Public domain")

    ! (1) A first music track: ground bass
    call midi%track_header(track_name="ground bass")
    call midi%Control_Change(channel=0, type=Effects_1_Depth, ctl_value=64)  ! Reverb
    ! Instrument on channel 0:
    call midi%Program_Change(channel=0, instrument=String_Ensemble_1)
    ! Panning:
    call midi%Control_Change(channel=0, type=Pan, ctl_value=panning(2))

    do j = 1, 30
        do i = 1, 8
            call midi%play_note(channel=0, note=MIDI_Note(bass(i)), velocity=mf_level, value=quarter_note)
        end do
    end do
    call midi%end_of_track()

    ! Three other music tracks: a three voices canon with various instruments
    do track = 3, 5
        write(track_name, '("Canon voice ",I0)') track-2
        call midi%track_header(track_name)

        ! Reverb and pan:
        call midi%Control_Change(channel=track, type=Effects_1_Depth, ctl_value=64)
        call midi%Control_Change(channel=track, type=Pan, ctl_value=panning(track))

        ! A pause to shift the start of each voice of the canon:
        call midi%play_note(channel=track, note=0, velocity=0, value=8*quarter_note*(track - 2))

        do j = 1, 15
            ! Let's change regularly the instruments to add some variations:
            call midi%Program_Change(channel=track, instrument=instrument((track - 3) + j))
            ! Let's play the theme:
            do i = 1, 16
                call midi%play_note(channel=track, note=MIDI_Note(theme(i)), velocity=mf_level, value=quarter_note)
            end do
        end do

        call midi%end_of_track()
    end do

    call midi%close()

    print *,"You can now play the file ", midi%get_name()
end program canon
