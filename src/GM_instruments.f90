! ForMIDI: a small Fortran MIDI sequencer for composing music, exploring
!          algorithmic music and music theory
! License GNU GPLv3
! Vincent Magnin
! Last modifications: 2022-11-30

module GM_instruments
    !---------------------------------------------------------------------------
    ! Contains the list of General MIDI instruments and percussions
    !---------------------------------------------------------------------------

    use, intrinsic :: iso_fortran_env, only: int8

    implicit none

    public

    !-----------------------------------
    ! GM instruments, grouped by family:
    !-----------------------------------
    ! Piano
    integer(int8), parameter :: Acoustic_Grand_Piano = 0
    integer(int8), parameter :: Bright_Acoustic_Piano = 1
    integer(int8), parameter :: Electric_Grand_Piano = 2
    integer(int8), parameter :: Honky_tonk_Piano = 3
    integer(int8), parameter :: Electric_Piano_1 = 4
    integer(int8), parameter :: Electric_Piano_2 = 5
    integer(int8), parameter :: Harpsichord = 6
    integer(int8), parameter :: Clavi = 7
    ! Chromatic Percussion
    integer(int8), parameter :: Celesta = 8
    integer(int8), parameter :: Glockenspiel = 9
    integer(int8), parameter :: Music_Box = 10
    integer(int8), parameter :: Vibraphone = 11
    integer(int8), parameter :: Marimba = 12
    integer(int8), parameter :: Xylophone = 13
    integer(int8), parameter :: Tubular_Bells = 14
    integer(int8), parameter :: Dulcimer = 15
    ! Organ
    integer(int8), parameter :: Drawbar_Organ = 16
    integer(int8), parameter :: Percussive_Organ = 17
    integer(int8), parameter :: Rock_Organ = 18
    integer(int8), parameter :: Church_Organ = 19
    integer(int8), parameter :: Reed_Organ = 20
    integer(int8), parameter :: Accordion = 21
    integer(int8), parameter :: Harmonica = 22
    integer(int8), parameter :: Tango_Accordion = 23
    ! Guitar
    integer(int8), parameter :: Acoustic_Guitar_nylon = 24
    integer(int8), parameter :: Acoustic_Guitar_steel = 25
    integer(int8), parameter :: Electric_Guitar_jazz = 26
    integer(int8), parameter :: Electric_Guitar_clean = 27
    integer(int8), parameter :: Electric_Guitar_muted = 28
    integer(int8), parameter :: Overdriven_Guitar = 29
    integer(int8), parameter :: Distortion_Guitar = 30
    integer(int8), parameter :: Guitar_harmonics = 31
    ! Bass
    integer(int8), parameter :: Acoustic_Bass = 32
    integer(int8), parameter :: Electric_Bass_finger = 33
    integer(int8), parameter :: Electric_Bass_pick = 34
    integer(int8), parameter :: Fretless_Bass = 35
    integer(int8), parameter :: Slap_Bass_1 = 36
    integer(int8), parameter :: Slap_Bass_2 = 37
    integer(int8), parameter :: Synth_Bass_1 = 38
    integer(int8), parameter :: Synth_Bass_2 = 39
    ! Strings
    integer(int8), parameter :: Violin = 40
    integer(int8), parameter :: Viola = 41
    integer(int8), parameter :: Cello = 42
    integer(int8), parameter :: Contrabass = 43
    integer(int8), parameter :: Tremolo_Strings = 44
    integer(int8), parameter :: Pizzicato_Strings = 45
    integer(int8), parameter :: Orchestral_Harp = 46
    integer(int8), parameter :: Timpani = 47
    ! Ensemble
    integer(int8), parameter :: String_Ensemble_1 = 48
    integer(int8), parameter :: String_Ensemble_2 = 49
    integer(int8), parameter :: SynthStrings_1 = 50
    integer(int8), parameter :: SynthStrings_2 = 51
    integer(int8), parameter :: Choir_Aahs = 52
    integer(int8), parameter :: Voice_Oohs = 53
    integer(int8), parameter :: Synth_Voice = 54
    integer(int8), parameter :: Orchestra_Hit = 55
    ! Brass
    integer(int8), parameter :: Trumpet = 56
    integer(int8), parameter :: Trombone = 57
    integer(int8), parameter :: Tuba = 58
    integer(int8), parameter :: Muted_Trumpet = 59
    integer(int8), parameter :: French_Horn = 60
    integer(int8), parameter :: Brass_Section = 61
    integer(int8), parameter :: SynthBrass_1 = 62
    integer(int8), parameter :: SynthBrass_2 = 63
    ! Reed
    integer(int8), parameter :: Soprano_Sax = 64
    integer(int8), parameter :: Alto_Sax = 65
    integer(int8), parameter :: Tenor_Sax = 66
    integer(int8), parameter :: Baritone_Sax = 67
    integer(int8), parameter :: Oboe = 68
    integer(int8), parameter :: English_Horn = 69
    integer(int8), parameter :: Bassoon = 70
    integer(int8), parameter :: Clarinet = 71
    ! Pipe
    integer(int8), parameter :: Piccolo = 72
    integer(int8), parameter :: Flute = 73
    integer(int8), parameter :: Recorder = 74
    integer(int8), parameter :: Pan_Flute = 75
    integer(int8), parameter :: Blown_Bottle = 76
    integer(int8), parameter :: Shakuhachi = 77
    integer(int8), parameter :: Whistle = 78
    integer(int8), parameter :: Ocarina = 79
    ! Synth Lead
    integer(int8), parameter :: Lead_1_square = 80
    integer(int8), parameter :: Lead_2_sawtooth = 81
    integer(int8), parameter :: Lead_3_calliope = 82
    integer(int8), parameter :: Lead_4_chiff = 83
    integer(int8), parameter :: Lead_5_charang = 84
    integer(int8), parameter :: Lead_6_voice = 85
    integer(int8), parameter :: Lead_7_fifths = 86
    integer(int8), parameter :: Lead_8_bass_lead = 87
    ! Synth Pad
    integer(int8), parameter :: Pad_1_new_age = 88
    integer(int8), parameter :: Pad_2_warm = 89
    integer(int8), parameter :: Pad_3_polysynth = 90
    integer(int8), parameter :: Pad_4_choir = 91
    integer(int8), parameter :: Pad_5_bowed = 92
    integer(int8), parameter :: Pad_6_metallic = 93
    integer(int8), parameter :: Pad_7_halo = 94
    integer(int8), parameter :: Pad_8_sweep = 95
    ! Synth Effects
    integer(int8), parameter :: FX_1_rain = 96
    integer(int8), parameter :: FX_2_soundtrack = 97
    integer(int8), parameter :: FX_3_crystal = 98
    integer(int8), parameter :: FX_4_atmosphere = 99
    integer(int8), parameter :: FX_5_brightness = 100
    integer(int8), parameter :: FX_6_goblins = 101
    integer(int8), parameter :: FX_7_echoes = 102
    integer(int8), parameter :: FX_8_sci_fi = 103
    ! Ethnic
    integer(int8), parameter :: Sitar = 104
    integer(int8), parameter :: Banjo = 105
    integer(int8), parameter :: Shamisen = 106
    integer(int8), parameter :: Koto = 107
    integer(int8), parameter :: Kalimba = 108
    integer(int8), parameter :: Bag_pipe = 109
    integer(int8), parameter :: Fiddle = 110
    integer(int8), parameter :: Shanai = 111
    ! Percussive
    integer(int8), parameter :: Tinkle_Bell = 112
    integer(int8), parameter :: Agogo = 113
    integer(int8), parameter :: Steel_Drums = 114
    integer(int8), parameter :: Woodblock = 115
    integer(int8), parameter :: Taiko_Drum = 116
    integer(int8), parameter :: Melodic_Tom = 117
    integer(int8), parameter :: Synth_Drum = 118
    integer(int8), parameter :: Reverse_Cymbal = 119
    ! Sound Effects
    integer(int8), parameter :: Guitar_Fret_Noise = 120
    integer(int8), parameter :: Breath_Noise = 121
    integer(int8), parameter :: Seashore = 122
    integer(int8), parameter :: Bird_Tweet = 123
    integer(int8), parameter :: Telephone_Ring = 124
    integer(int8), parameter :: Helicopter = 125
    integer(int8), parameter :: Applause = 126
    integer(int8), parameter :: Gunshot = 127

  ! Percussive instruments (canal 9). This  list is required by the GM standard,
  ! but more may be available:
    integer(int8), parameter :: Acoustic_Bass_Drum = 35
    integer(int8), parameter :: Bass_Drum_1 = 36
    integer(int8), parameter :: Side_Stick = 37
    integer(int8), parameter :: Acoustic_Snare = 38
    integer(int8), parameter :: Hand_Clap = 39
    integer(int8), parameter :: Electric_Snare = 40
    integer(int8), parameter :: Low_Floor_Tom = 41
    integer(int8), parameter :: Closed_Hi_Hat = 42
    integer(int8), parameter :: High_Floor_Tom = 43
    integer(int8), parameter :: Pedal_Hi_Hat = 44
    integer(int8), parameter :: Low_Tom = 45
    integer(int8), parameter :: Open_Hi_Hat = 46
    integer(int8), parameter :: Low_Mid_Tom = 47
    integer(int8), parameter :: Hi_Mid_Tom = 48
    integer(int8), parameter :: Crash_Cymbal_1 = 49
    integer(int8), parameter :: High_Tom = 50
    integer(int8), parameter :: Ride_Cymbal_1 = 51
    integer(int8), parameter :: Chinese_Cymbal = 52
    integer(int8), parameter :: Ride_Bell = 53
    integer(int8), parameter :: Tambourine = 54
    integer(int8), parameter :: Splash_Cymbal = 55
    integer(int8), parameter :: Cowbell = 56
    integer(int8), parameter :: Crash_Cymbal_2 = 57
    integer(int8), parameter :: Vibraslap = 58
    integer(int8), parameter :: Ride_Cymbal_2 = 59
    integer(int8), parameter :: Hi_Bongo = 60
    integer(int8), parameter :: Low_Bongo = 61
    integer(int8), parameter :: Mute_Hi_Conga = 62
    integer(int8), parameter :: Open_Hi_Conga = 63
    integer(int8), parameter :: Low_Conga = 64
    integer(int8), parameter :: High_Timbale = 65
    integer(int8), parameter :: Low_Timbale = 66
    integer(int8), parameter :: High_Agogo = 67
    integer(int8), parameter :: Low_Agogo = 68
    integer(int8), parameter :: Cabasa = 69
    integer(int8), parameter :: Maracas = 70
    integer(int8), parameter :: Short_Whistle = 71
    integer(int8), parameter :: Long_Whistle = 72
    integer(int8), parameter :: Short_Guiro = 73
    integer(int8), parameter :: Long_Guiro = 74
    integer(int8), parameter :: Claves = 75
    integer(int8), parameter :: Hi_Wood_Block = 76
    integer(int8), parameter :: Low_Wood_Block = 77
    integer(int8), parameter :: Mute_Cuica = 78
    integer(int8), parameter :: Open_Cuica = 79
    integer(int8), parameter :: Mute_Triangle = 80
    integer(int8), parameter :: Open_Triangle = 81

end module GM_instruments
