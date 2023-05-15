! ForMIDI: a small Fortran MIDI sequencer for composing music, exploring
!          algorithmic music and music theory
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2022-11-28

module MIDI_control_changes
    ! MIDI 1.0 Control Change Messages and Registered Parameter Numbers (RPNs)

    use, intrinsic :: iso_fortran_env, only: int8

    implicit none

    public

    integer(int8), parameter :: Bank_Select = 0
    integer(int8), parameter :: Modulation_Wheel_or_Lever = 1
    integer(int8), parameter :: Breath_Controller = 2
    ! Undefined = 3
    integer(int8), parameter :: Foot_Controller = 4
    integer(int8), parameter :: Portamento_Time = 5
    integer(int8), parameter :: Data_Entry_MSB = 6
    integer(int8), parameter :: Channel_Volume = 7      ! (formerly_Main_Volume)
    integer(int8), parameter :: Balance = 8
    ! Undefined = 9
    integer(int8), parameter :: Pan = 10
    integer(int8), parameter :: Expression_Controller = 11
    integer(int8), parameter :: Effect_Control_1 = 12
    integer(int8), parameter :: Effect_Control_2 = 13
    ! Undefined 14-15
    integer(int8), parameter :: General_Purpose_Controller_1 = 16
    integer(int8), parameter :: General_Purpose_Controller_2 = 17
    integer(int8), parameter :: General_Purpose_Controller_3 = 18
    integer(int8), parameter :: General_Purpose_Controller_4 = 19
    ! Undefined 20-31
    integer(int8), parameter :: Bank_Select_LSB = 32
    integer(int8), parameter :: Modulation_Wheel_or_Lever_LSB = 33
    integer(int8), parameter :: Breath_Controller_LSB = 34
    ! Undefined = 35
    integer(int8), parameter :: Foot_Controller_LSB = 36
    integer(int8), parameter :: Portamento_Time_LSB = 37
    integer(int8), parameter :: Data_Entry_MSB_LSB = 38
    integer(int8), parameter :: Channel_Volume_LSB = 39 ! (formerly_Main_Volume)
    integer(int8), parameter :: Balance_LSB = 40
    ! Undefined = 41
    integer(int8), parameter :: Pan_LSB = 42
    integer(int8), parameter :: Expression_Controller_LSB = 43
    integer(int8), parameter :: Effect_Control_1_LSB = 44
    integer(int8), parameter :: Effect_Control_2_LSB = 45
    ! Undefined 46-47
    integer(int8), parameter :: General_Purpose_Controller_1_LSB = 48
    integer(int8), parameter :: General_Purpose_Controller_2_LSB = 49
    integer(int8), parameter :: General_Purpose_Controller_3_LSB = 50
    integer(int8), parameter :: General_Purpose_Controller_4_LSB = 51
    ! Undefined 52-63
    integer(int8), parameter :: Damper_Pedal_on_off = 64  ! (Sustain)
    integer(int8), parameter :: Portamento_On_Off = 65
    integer(int8), parameter :: Sostenuto_On_Off = 66
    integer(int8), parameter :: Soft_Pedal_On_Off = 67
    integer(int8), parameter :: Legato_Footswitch = 68
    integer(int8), parameter :: Hold_2 = 69
    integer(int8), parameter :: Sound_Controller_1 = 70   ! (default: Sound_Variation)
    integer(int8), parameter :: Sound_Controller_2 = 71   ! (default: Timbre_Harmonic_Intens.)
    integer(int8), parameter :: Sound_Controller_3 = 72   ! (default: Release_Time)
    integer(int8), parameter :: Sound_Controller_4 = 73   ! (default: Attack_Time)
    integer(int8), parameter :: Sound_Controller_5 = 74   ! (default: Brightness)
    integer(int8), parameter :: Sound_Controller_6 = 75   ! (default: Decay_Time - see_MMA_RP-021)
    integer(int8), parameter :: Sound_Controller_7 = 76   ! (default: Vibrato_Rate - see_MMA_RP-021)
    integer(int8), parameter :: Sound_Controller_8 = 77   ! (default: Vibrato_Depth - see_MMA_RP-021)
    integer(int8), parameter :: Sound_Controller_9 = 78   ! (default: Vibrato_Delay - see_MMA_RP-021)
    integer(int8), parameter :: Sound_Controller_10 = 79  ! (default_undefined - see_MMA_RP-021)
    integer(int8), parameter :: General_Purpose_Controller_5 = 80
    integer(int8), parameter :: General_Purpose_Controller_6 = 81
    integer(int8), parameter :: General_Purpose_Controller_7 = 82
    integer(int8), parameter :: General_Purpose_Controller_8 = 83
    integer(int8), parameter :: Portamento_Control = 84
    ! Undefined_85-87
    integer(int8), parameter :: High_Resolution_Velocity_Prefix = 88
    ! Undefined_89-90
    integer(int8), parameter :: Effects_1_Depth = 91  ! (default: Reverb_Send_Level - see_MMA_RP-023)  (formerly_External_Effects_Depth)
    integer(int8), parameter :: Effects_2_Depth = 92  ! (formerly_Tremolo_Depth)
    integer(int8), parameter :: Effects_3_Depth = 93  ! (default: Chorus_Send_Level - see_MMA_RP-023)  (formerly_Chorus_Depth)
    integer(int8), parameter :: Effects_4_Depth = 94  ! (formerly_Celeste [Detune] Depth)
    integer(int8), parameter :: Effects_5_Depth = 95  ! (formerly_Phaser_Depth)
    integer(int8), parameter :: Data_Increment = 96   ! (Data_Entry +1) (see_MMA_RP-018)
    integer(int8), parameter :: Data_Decrement = 97   ! (Data_Entry -1) (see_MMA_RP-018)
    integer(int8), parameter :: Non_Registered_Parameter_Number_LSB = 98   ! (NRPN) - LSB
    integer(int8), parameter :: Non_Registered_Parameter_Number_MSB = 99   ! (NRPN) - MSB
    integer(int8), parameter :: Registered_Parameter_Number_LSB = 100      ! (RPN) - LSB*
    integer(int8), parameter :: Registered_Parameter_Number_MSB = 101      ! (RPN) - MSB*
    ! Undefined_102-119
    integer(int8), parameter :: All_Sound_Off = 120         ! [Channel_Mode_Message]
    integer(int8), parameter :: Reset_All_Controllers = 121 ! [Channel_Mode_Message] (See_MMA_RP-015)
    integer(int8), parameter :: Local_Control_On_Off = 122  ! [Channel_Mode_Message]
    integer(int8), parameter :: All_Notes_Off = 123         ! [Channel_Mode_Message]
    integer(int8), parameter :: Omni_Mode_Off = 124  ! (+ all_notes_off) [Channel_Mode_Message]
    integer(int8), parameter :: Omni_Mode_On = 125   ! (+ all_notes_off) [Channel_Mode_Message]
    integer(int8), parameter :: Mono_Mode_On = 126   ! (+ poly_off, + all_notes_off) [Channel_Mode_Message]
    integer(int8), parameter :: Poly_Mode_On = 127   ! (+ mono_off, +all_notes_off) [Channel_Mode_Message]

end module MIDI_control_changes
