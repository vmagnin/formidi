! ForMIDI: a small Fortran MIDI sequencer for composing music, exploring
!          algorithmic music and music theory
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-14

!---------------------------------------------------------------------------
! Contains the list of General MIDI 128 instruments and 47 percussions
!---------------------------------------------------------------------------
module GM_instruments
    implicit none

    public

    !-----------------------------------
    ! GM instruments, grouped by family:
    !-----------------------------------
    ! Piano
    integer, parameter :: Acoustic_Grand_Piano = 0
    integer, parameter :: Bright_Acoustic_Piano = 1
    integer, parameter :: Electric_Grand_Piano = 2
    integer, parameter :: Honky_tonk_Piano = 3
    integer, parameter :: Electric_Piano_1 = 4
    integer, parameter :: Electric_Piano_2 = 5
    integer, parameter :: Harpsichord = 6
    integer, parameter :: Clavi = 7
    ! Chromatic Percussion
    integer, parameter :: Celesta = 8
    integer, parameter :: Glockenspiel = 9
    integer, parameter :: Music_Box = 10
    integer, parameter :: Vibraphone = 11
    integer, parameter :: Marimba = 12
    integer, parameter :: Xylophone = 13
    integer, parameter :: Tubular_Bells = 14
    integer, parameter :: Dulcimer = 15
    ! Organ
    integer, parameter :: Drawbar_Organ = 16
    integer, parameter :: Percussive_Organ = 17
    integer, parameter :: Rock_Organ = 18
    integer, parameter :: Church_Organ = 19
    integer, parameter :: Reed_Organ = 20
    integer, parameter :: Accordion = 21
    integer, parameter :: Harmonica = 22
    integer, parameter :: Tango_Accordion = 23
    ! Guitar
    integer, parameter :: Acoustic_Guitar_nylon = 24
    integer, parameter :: Acoustic_Guitar_steel = 25
    integer, parameter :: Electric_Guitar_jazz = 26
    integer, parameter :: Electric_Guitar_clean = 27
    integer, parameter :: Electric_Guitar_muted = 28
    integer, parameter :: Overdriven_Guitar = 29
    integer, parameter :: Distortion_Guitar = 30
    integer, parameter :: Guitar_harmonics = 31
    ! Bass
    integer, parameter :: Acoustic_Bass = 32
    integer, parameter :: Electric_Bass_finger = 33
    integer, parameter :: Electric_Bass_pick = 34
    integer, parameter :: Fretless_Bass = 35
    integer, parameter :: Slap_Bass_1 = 36
    integer, parameter :: Slap_Bass_2 = 37
    integer, parameter :: Synth_Bass_1 = 38
    integer, parameter :: Synth_Bass_2 = 39
    ! Strings
    integer, parameter :: Violin = 40
    integer, parameter :: Viola = 41
    integer, parameter :: Cello = 42
    integer, parameter :: Contrabass = 43
    integer, parameter :: Tremolo_Strings = 44
    integer, parameter :: Pizzicato_Strings = 45
    integer, parameter :: Orchestral_Harp = 46
    integer, parameter :: Timpani = 47
    ! Ensemble
    integer, parameter :: String_Ensemble_1 = 48
    integer, parameter :: String_Ensemble_2 = 49
    integer, parameter :: SynthStrings_1 = 50
    integer, parameter :: SynthStrings_2 = 51
    integer, parameter :: Choir_Aahs = 52
    integer, parameter :: Voice_Oohs = 53
    integer, parameter :: Synth_Voice = 54
    integer, parameter :: Orchestra_Hit = 55
    ! Brass
    integer, parameter :: Trumpet = 56
    integer, parameter :: Trombone = 57
    integer, parameter :: Tuba = 58
    integer, parameter :: Muted_Trumpet = 59
    integer, parameter :: French_Horn = 60
    integer, parameter :: Brass_Section = 61
    integer, parameter :: SynthBrass_1 = 62
    integer, parameter :: SynthBrass_2 = 63
    ! Reed
    integer, parameter :: Soprano_Sax = 64
    integer, parameter :: Alto_Sax = 65
    integer, parameter :: Tenor_Sax = 66
    integer, parameter :: Baritone_Sax = 67
    integer, parameter :: Oboe = 68
    integer, parameter :: English_Horn = 69
    integer, parameter :: Bassoon = 70
    integer, parameter :: Clarinet = 71
    ! Pipe
    integer, parameter :: Piccolo = 72
    integer, parameter :: Flute = 73
    integer, parameter :: Recorder = 74
    integer, parameter :: Pan_Flute = 75
    integer, parameter :: Blown_Bottle = 76
    integer, parameter :: Shakuhachi = 77
    integer, parameter :: Whistle = 78
    integer, parameter :: Ocarina = 79
    ! Synth Lead
    integer, parameter :: Lead_1_square = 80
    integer, parameter :: Lead_2_sawtooth = 81
    integer, parameter :: Lead_3_calliope = 82
    integer, parameter :: Lead_4_chiff = 83
    integer, parameter :: Lead_5_charang = 84
    integer, parameter :: Lead_6_voice = 85
    integer, parameter :: Lead_7_fifths = 86
    integer, parameter :: Lead_8_bass_lead = 87
    ! Synth Pad
    integer, parameter :: Pad_1_new_age = 88
    integer, parameter :: Pad_2_warm = 89
    integer, parameter :: Pad_3_polysynth = 90
    integer, parameter :: Pad_4_choir = 91
    integer, parameter :: Pad_5_bowed = 92
    integer, parameter :: Pad_6_metallic = 93
    integer, parameter :: Pad_7_halo = 94
    integer, parameter :: Pad_8_sweep = 95
    ! Synth Effects
    integer, parameter :: FX_1_rain = 96
    integer, parameter :: FX_2_soundtrack = 97
    integer, parameter :: FX_3_crystal = 98
    integer, parameter :: FX_4_atmosphere = 99
    integer, parameter :: FX_5_brightness = 100
    integer, parameter :: FX_6_goblins = 101
    integer, parameter :: FX_7_echoes = 102
    integer, parameter :: FX_8_sci_fi = 103
    ! Ethnic
    integer, parameter :: Sitar = 104
    integer, parameter :: Banjo = 105
    integer, parameter :: Shamisen = 106
    integer, parameter :: Koto = 107
    integer, parameter :: Kalimba = 108
    integer, parameter :: Bag_pipe = 109
    integer, parameter :: Fiddle = 110
    integer, parameter :: Shanai = 111
    ! Percussive
    integer, parameter :: Tinkle_Bell = 112
    integer, parameter :: Agogo = 113
    integer, parameter :: Steel_Drums = 114
    integer, parameter :: Woodblock = 115
    integer, parameter :: Taiko_Drum = 116
    integer, parameter :: Melodic_Tom = 117
    integer, parameter :: Synth_Drum = 118
    integer, parameter :: Reverse_Cymbal = 119
    ! Sound Effects
    integer, parameter :: Guitar_Fret_Noise = 120
    integer, parameter :: Breath_Noise = 121
    integer, parameter :: Seashore = 122
    integer, parameter :: Bird_Tweet = 123
    integer, parameter :: Telephone_Ring = 124
    integer, parameter :: Helicopter = 125
    integer, parameter :: Applause = 126
    integer, parameter :: Gunshot = 127

  ! Percussive instruments (channel 9). This  list is required by the GM standard,
  ! but more may be available:
    integer, parameter :: Acoustic_Bass_Drum = 35
    integer, parameter :: Bass_Drum_1 = 36
    integer, parameter :: Side_Stick = 37
    integer, parameter :: Acoustic_Snare = 38
    integer, parameter :: Hand_Clap = 39
    integer, parameter :: Electric_Snare = 40
    integer, parameter :: Low_Floor_Tom = 41
    integer, parameter :: Closed_Hi_Hat = 42
    integer, parameter :: High_Floor_Tom = 43
    integer, parameter :: Pedal_Hi_Hat = 44
    integer, parameter :: Low_Tom = 45
    integer, parameter :: Open_Hi_Hat = 46
    integer, parameter :: Low_Mid_Tom = 47
    integer, parameter :: Hi_Mid_Tom = 48
    integer, parameter :: Crash_Cymbal_1 = 49
    integer, parameter :: High_Tom = 50
    integer, parameter :: Ride_Cymbal_1 = 51
    integer, parameter :: Chinese_Cymbal = 52
    integer, parameter :: Ride_Bell = 53
    integer, parameter :: Tambourine = 54
    integer, parameter :: Splash_Cymbal = 55
    integer, parameter :: Cowbell = 56
    integer, parameter :: Crash_Cymbal_2 = 57
    integer, parameter :: Vibraslap = 58
    integer, parameter :: Ride_Cymbal_2 = 59
    integer, parameter :: Hi_Bongo = 60
    integer, parameter :: Low_Bongo = 61
    integer, parameter :: Mute_Hi_Conga = 62
    integer, parameter :: Open_Hi_Conga = 63
    integer, parameter :: Low_Conga = 64
    integer, parameter :: High_Timbale = 65
    integer, parameter :: Low_Timbale = 66
    integer, parameter :: High_Agogo = 67
    integer, parameter :: Low_Agogo = 68
    integer, parameter :: Cabasa = 69
    integer, parameter :: Maracas = 70
    integer, parameter :: Short_Whistle = 71
    integer, parameter :: Long_Whistle = 72
    integer, parameter :: Short_Guiro = 73
    integer, parameter :: Long_Guiro = 74
    integer, parameter :: Claves = 75
    integer, parameter :: Hi_Wood_Block = 76
    integer, parameter :: Low_Wood_Block = 77
    integer, parameter :: Mute_Cuica = 78
    integer, parameter :: Open_Cuica = 79
    integer, parameter :: Mute_Triangle = 80
    integer, parameter :: Open_Triangle = 81

end module GM_instruments
