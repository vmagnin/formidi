! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-10

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
    ! The first track is always a metadata track. We define the 
    ! tempo: a quarter note will last 500000 µs = 0.5 s => tempo = 120 bpm
    call midi%new("third_kind.mid", SMF=1_int8, tracks=2_int16, q_ticks=quarter_note, tempo=500000)
    call midi%text_event("This file was created with the ForMIDI Fortran project")
    call midi%write_end_of_track()

    ! The music track:
    call midi%write_track_header()

    ! Instrument (in the 0..127 range) :
    call midi%Program_Change(channel=0_int8, instrument=Pad_6_metallic)

    ! Close Encounters of the Third Kind:
    ! https://www.youtube.com/watch?v=S4PYI6TzqYk
    call midi%write_note(channel=0_int8, note=get_MIDI_note("G4"), velocity=64_int8, duration=quarter_note)
    call midi%write_note(channel=0_int8, note=get_MIDI_note("A4"), velocity=64_int8, duration=quarter_note)
    call midi%write_note(channel=0_int8, note=get_MIDI_note("F4"), velocity=64_int8, duration=quarter_note)
    call midi%write_note(channel=0_int8, note=get_MIDI_note("F3"), velocity=64_int8, duration=quarter_note)
    call midi%write_note(channel=0_int8, note=get_MIDI_note("C4"), velocity=64_int8, duration=2*quarter_note)

    call midi%write_end_of_track()

    call midi%close()

end program third_kind
