! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-14

! This is your starting point in the ForMIDI world.
! Close Encounters of the Third Kind: https://www.youtube.com/watch?v=S4PYI6TzqYk
program third_kind
    ! The main class you need to create music:
    use MIDI_file_class
    ! The function MIDI_Note() returns the MIDI number of a note from 12 (C0)
    ! to 127 (G9). The A4 (440 Hz tuning standard) is the note 69.
    use music, only: MIDI_Note
    ! Contains the list of General MIDI 128 instruments and 47 percussions:
    use GM_instruments

    implicit none
    type(MIDI_file) :: midi

    ! You will generally use the format SMF 1 which allows several tracks
    ! to be played together.
    ! We will use only one musical track but we need 2 tracks, as there is
    ! always a metadata track automatically created by the new() method.
    ! Divisions is the number of ticks ("metrical timing" MIDI scheme) in
    ! a quarter note, and can be considered as the time resolution of your file.
    ! We define the tempo: a quarter note will last 500000 µs = 0.5 s => tempo=120 bpm
    call midi%new("third_kind.mid", format=1, tracks=2, divisions=quarter_note, tempo=500000, &
                & text_event="This file was created with the ForMIDI Fortran project")

    ! (1) The single musical track:
    call midi%track_header()

    ! Choosing the instrument (in the 0..127 range):
    call midi%Program_Change(channel=0, instrument=Pad_6_metallic)

    ! Playing a sequence of five notes on MIDI channel 0:
    call midi%play_note(channel=0, note=MIDI_Note("G4"), velocity=64, value=quarter_note)
    call midi%play_note(channel=0, note=MIDI_Note("A4"), velocity=64, value=quarter_note)
    call midi%play_note(channel=0, note=MIDI_Note("F4"), velocity=64, value=quarter_note)
    call midi%play_note(channel=0, note=MIDI_Note("F3"), velocity=64, value=quarter_note)
    call midi%play_note(channel=0, note=MIDI_Note("C4"), velocity=64, value=2*quarter_note)
    ! The MIDI velocity is the speed at which you type on the keyboard and
    ! can be considered equivalent to the volume. As many MIDI values, it is
    ! defined in the 0..127 range.
    ! There are 16 channels (0..15).
    ! The value (duration) of a note is expressed in MIDI ticks.

    call midi%end_of_track()

    call midi%close()

    print *,"You can now play the file ", midi%get_name()
end program third_kind
