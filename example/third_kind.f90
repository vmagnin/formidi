! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-14

program third_kind
    use MIDI_file_class
    use music, only: MIDI_Note
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi

    ! Create a file with 2 tracks (including the metadata track):
    ! The first track is always a metadata track. We define the 
    ! tempo: a quarter note will last 500000 µs = 0.5 s => tempo = 120 bpm
    call midi%new("third_kind.mid", format=1, tracks=2, division=quarter_note, tempo=500000, &
                & text_event="This file was created with the ForMIDI Fortran project")

    ! The music track:
    call midi%track_header()

    ! Instrument (in the 0..127 range) :
    call midi%Program_Change(channel=0, instrument=Pad_6_metallic)

    ! Close Encounters of the Third Kind:
    ! https://www.youtube.com/watch?v=S4PYI6TzqYk
    call midi%play_note(channel=0, note=MIDI_Note("G4"), velocity=64, value=quarter_note)
    call midi%play_note(channel=0, note=MIDI_Note("A4"), velocity=64, value=quarter_note)
    call midi%play_note(channel=0, note=MIDI_Note("F4"), velocity=64, value=quarter_note)
    call midi%play_note(channel=0, note=MIDI_Note("F3"), velocity=64, value=quarter_note)
    call midi%play_note(channel=0, note=MIDI_Note("C4"), velocity=64, value=2*quarter_note)

    call midi%end_of_track()

    call midi%close()

    print *,"You can now play the file ", midi%get_name()
end program third_kind
