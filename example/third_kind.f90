! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-09

program third_kind
    use, intrinsic :: iso_fortran_env, only: int8, int16, int32
    use MIDI_file_class
    use music
    use MIDI_control_changes
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi

    print *, "Output file: third_kind.mid"
    ! Create a file with 2 tracks (including the metadata track):
    call midi%create_MIDI_file("third_kind.mid", 1_int8, 2_int16, quarter_note)
    ! The first track is always a metadata track. Here, we just define the 
    ! tempo: a quarter note will last 500000 µs = 0.5 s => tempo = 120 bpm
    call midi%MIDI_tempo(500000)
    call midi%MIDI_text_event("This file was created with the ForMIDI Fortran project")
    call midi%write_end_of_MIDI_track()

    ! The music track:
    call midi%write_MIDI_track_header()

    ! Instrument (in the 0..127 range) :
    call midi%MIDI_Program_Change(0_int8, Pad_6_metallic)

    ! Close Encounters of the Third Kind:
    ! https://www.youtube.com/watch?v=S4PYI6TzqYk
    call midi%write_MIDI_note(0_int8, get_MIDI_note("G4"), 64_int8, quarter_note)
    call midi%write_MIDI_note(0_int8, get_MIDI_note("A4"), 64_int8, quarter_note)
    call midi%write_MIDI_note(0_int8, get_MIDI_note("F4"), 64_int8, quarter_note)
    call midi%write_MIDI_note(0_int8, get_MIDI_note("F3"), 64_int8, quarter_note)
    call midi%write_MIDI_note(0_int8, get_MIDI_note("C4"), 64_int8, 2*quarter_note)

    call midi%write_end_of_MIDI_track()
    ! The size of the track is now known and must be written in its header:
    call midi%write_MIDI_track_size()

    call midi%close_MIDI_file()

end program third_kind
