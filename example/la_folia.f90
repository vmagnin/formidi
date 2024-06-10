! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin, 2024-06-05
! Last modifications: 2024-06-10

! https://en.wikipedia.org/wiki/Folia
program la_folia
    use, intrinsic :: iso_fortran_env, only: i8=>int8, int16, int32
    use MIDI_file_class
    use music
    use MIDI_control_changes
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi
    integer(int8) :: n
    integer :: i, j
    character(3) :: note, chord_type, note_value
    integer(int32) :: d
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

    print *, "Output file: la_folia.mid"
    ! Create a file with 3 tracks (including the metadata track):
    call midi%new("la_folia.mid", 1_i8, 3_int16, quarter_note)
    ! A quarter note will last 600000 µs = 0.6 s => tempo = 100 bpm
    call midi%copyright_notice("Public domain")
    call midi%tempo(600000)
    call midi%write_end_of_track()

    ! Track 1: chords played by strings on MIDI channel 0
    call midi%write_track_header()
    call midi%sequence_track_name("chords")
    call midi%Control_Change(0_i8, Effects_1_Depth, 64_i8)  ! Reverb
    call midi%Program_Change(0_i8, String_Ensemble_1)

    do j = 1, 3
        do i = 1, 17
            call analyze(chords(i), note, chord_type, note_value)
            if (note_value(1:1) == "q") d = quarter_note      ! quarter note
            if (note_value(1:1) == "h") d = 2*quarter_note    ! half note
            if (note_value(2:2) == ".") d = d + d/2           ! Dotted note

            n = get_MIDI_note(trim(note))

            select case(trim(chord_type))
            case("m")
                call midi%write_chord(0_i8, Note_MIDI=n, chord=MINOR_CHORD, velocity=80_i8, duration=d)
            case("M")
                call midi%write_chord(0_i8, Note_MIDI=n, chord=MAJOR_CHORD, velocity=80_i8, duration=d)
            case("7")
                call midi%write_chord(0_i8, Note_MIDI=n, chord=DOMINANT_7TH_CHORD, velocity=80_i8, duration=d)
            end select
        end do
    end do
    ! Outro:
    call midi%write_chord(0_i8, Note_MIDI=n, chord=MINOR_CHORD, velocity=80_i8, duration=d)

    call midi%write_end_of_track()

    ! Track 2: arpeggios by plucked strings on MIDI channel 1
    call midi%write_track_header()
    call midi%sequence_track_name("la Folia")
    call midi%Control_Change(1_i8, Effects_1_Depth, 64_i8)  ! Reverb
    call midi%Program_Change(1_i8, Electric_Guitar_clean)

    do j = 1, 3
        do i = 1, 17
            call analyze(chords(i), note, chord_type, note_value)
            if (note_value(1:1) == "q") d = quarter_note/2
            if (note_value(1:1) == "h") d = quarter_note
            if (note_value(2:2) == ".") d = d + d/2

            n = get_MIDI_note(trim(note))

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

            call midi%write_broken_chord(channel=1_i8, Note_MIDI=n, chord=arpeggio1, velocity=64_i8, duration=d)
            call midi%write_broken_chord(channel=1_i8, Note_MIDI=n, chord=arpeggio2, velocity=64_i8, duration=d)
        end do
    end do

    call midi%write_end_of_track()

    call midi%close()

contains

    ! Receives a string with an encoded chords, and returns its fundamental,
    ! the type of chord and its encoded duration
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
