! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2025-01-27

!> This is a test for MIDI format 0 (SMF 0). But except if you have a good reason,
!> you should always prefer format 1, even if you need only one track.
program format0
    use MIDI_file_class
    use music
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi

    !> The format SMF 0 can contain only one track (there is no metadata track):
    call midi%new("format0.mid", format=0, tracks=1, divisions=quarter_note, tempo=500000, &
                & text_event="This file was created with the ForMIDI Fortran project")

    ! There is only one track but you can still use up to 16 channels:
    call midi%Program_Change(channel=0, instrument=Pad_6_metallic)
    call midi%Program_Change(channel=1, instrument=Electric_Guitar_clean)

    call midi%play_note(channel=0, note=MIDI_Note("G4"), velocity=mf_level, value=quarter_note)
    call midi%play_note(channel=1, note=MIDI_Note("A4"), velocity=mf_level, value=quarter_note)
    call midi%play_note(channel=0, note=MIDI_Note("F4"), velocity=mf_level, value=quarter_note)
    call midi%play_note(channel=1, note=MIDI_Note("F3"), velocity=mf_level, value=quarter_note)
    call midi%play_note(channel=0, note=MIDI_Note("C4"), velocity=mf_level, value=half_note)

    !> With SMF 0, you must close the only track which was opened by the new() method:
    call midi%end_of_track()

    call midi%close()

    print *,"You can now play the file ", midi%get_name()
end program format0
