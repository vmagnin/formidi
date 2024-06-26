! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin, 2024-06-05
! Last modifications: 2024-06-23

!> An example on the classical Portuguese/Spanish theme of La Folia
!> https://en.wikipedia.org/wiki/Folia
program la_folia
    use MIDI_file_class
    use music
    use MIDI_control_changes, only: Effects_1_Depth, Pan
    ! Contains the list of General MIDI 128 instruments and 47 percussions:
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi
    integer :: n, d
    character(3) :: note, chord_type, note_value
    integer, dimension(3) :: arpeggio1, arpeggio2
    ! Chords of the Folia theme in D minor.
    ! This is a first attempt to encode a chord into a string with its fundamental,
    ! its type (M, m, 7th...) and its value (w, q, h, etc.).
    ! That system may evolve in the future.
    ! https://en.wikipedia.org/wiki/Note_value
    character(7), parameter :: chords(1:17) = [ "D3 m h.","A2 7 h.","D3 m h.","C3 M h.", &
                                              & "F3 M h.","C3 M h.","D3 m h.","A2 7 h.", &
                                              & "D3 m h.","A2 7 h.","D3 m h.","C3 M h.", &
                                              & "F3 M h.","C3 M h.","D3 m h.","A2 7 h.","D3 m h." ]
    integer :: i, j

    ! Create a file with 3 tracks (including the metadata track):
    ! A quarter note will last 600000 µs = 0.6 s => tempo = 100 bpm
    ! The time signature is 3/4 (this argument is optional with 4/4 for default value).
    call midi%new("la_folia.mid", format=1, tracks=3, divisions=quarter_note, tempo=600000, &
                & time_signature=[3, 4], copyright="Public domain")

    ! (1) A track with chords played by strings on MIDI channel 0
    call midi%track_header(track_name="chords")
    ! Reverb:
    call midi%Control_Change(channel=0, type=Effects_1_Depth, ctl_value=64)
    ! Panning, slightly on the left (center is 64):
    call midi%Control_Change(channel=0, type=Pan, ctl_value=44)
    ! Choosing the instrument:
    call midi%Program_Change(channel=0, instrument=String_Ensemble_1)

    ! We repeat the theme three times identically:
    do j = 1, 3
        do i = 1, 17
            call analyze(chords(i), note, chord_type, note_value)
            if (note_value(1:1) == "q") d = quarter_note      ! quarter note
            if (note_value(1:1) == "h") d = half_note         ! half note
            if (note_value(2:2) == ".") d = dotted(d)         ! Dotted note

            n = MIDI_Note(trim(note))

            select case(trim(chord_type))
            case("m")
                call midi%play_chord(channel=0, note=n, chord=MINOR_CHORD, velocity=f_level, value=d)
            case("M")
                call midi%play_chord(channel=0, note=n, chord=MAJOR_CHORD, velocity=f_level, value=d)
            case("7")
                call midi%play_chord(channel=0, note=n, chord=DOMINANT_7TH_CHORD, velocity=f_level, value=d)
            end select
        end do
    end do
    ! Outro:
    call midi%play_chord(channel=0, note=n, chord=MINOR_CHORD, velocity=f_level, value=d)

    call midi%end_of_track()

    ! (2) A track with arpeggios by plucked strings on MIDI channel 1
    call midi%track_header(track_name="la Folia")
    ! Reverb:
    call midi%Control_Change(channel=1, type=Effects_1_Depth, ctl_value=64)
    ! Panning, slightly on the right (center is 64):
    call midi%Control_Change(channel=1, type=Pan, ctl_value=84)
    ! Choosing the instrument:
    call midi%Program_Change(channel=1, instrument=Electric_Guitar_clean)

    ! We repeat the theme three times but with various arpeggios:
    do j = 1, 3
        do i = 1, 17
            call analyze(chords(i), note, chord_type, note_value)
            if (note_value(1:1) == "q") d = eighth_note
            if (note_value(1:1) == "h") d = quarter_note
            if (note_value(2:2) == ".") d = dotted(d)

            n = MIDI_Note(trim(note))

            select case (trim(chord_type))
            case("m")
                arpeggio1 = MINOR_CHORD
            case("M")
                arpeggio1 = MAJOR_CHORD
            case("7")
                ! We don't play the fifth (7), because we want only three notes, not four:
                arpeggio1 = [ 0, 4, 10 ]
            end select

            ! Each chord is played two times, in various ways:
            select case(j)
            case(1)
                ! Swept the same way:
                arpeggio2 = arpeggio1
            case(2)
                ! The second time, swept in reverse order:
                arpeggio2 = arpeggio1(3:1:-1)
            case(3)
                ! Both reversed:
                arpeggio2 = arpeggio1(3:1:-1)
                arpeggio1 = arpeggio2
            end select

            call midi%play_broken_chord(channel=1, note=n, chord=arpeggio1, velocity=mf_level, value=d)
            call midi%play_broken_chord(channel=1, note=n, chord=arpeggio2, velocity=mf_level, value=d)
        end do
    end do

    call midi%end_of_track()

    call midi%close()

    print *,"You can now play the file ", midi%get_name()

contains

    !> Receives a string with an encoded chord, and returns its fundamental,
    !> the type of chord and its encoded value
    subroutine analyze(string, note, chord_type, note_value)
        character(*), intent(in) :: string
        character(3), intent(out) :: note, chord_type, note_value
        integer :: i1, i2

        i1=index(trim(string), " ", back=.false.)
        i2=index(trim(string), " ", back=.true.)
        note       = string(1:i1-1)
        chord_type = string(i1+1:i2-1)
        note_value = string(i2+1:)
    end subroutine

end program la_folia
