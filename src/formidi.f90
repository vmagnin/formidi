! ForMIDI: a small Fortran MIDI sequencer for composing music, exploring
!          algorithmic music and music theory
! License GNU GPLv3
! Vincent Magnin
! Last modifications: 2022-12-03

module formidi
    use, intrinsic :: iso_fortran_env, only: int8, int16, int32, error_unit

    implicit none
    ! Output unit:
    integer :: u
    integer :: status

    integer(int32), parameter :: quarter_note = 128
    ! Percussions channel (0..15 range):
    integer(int8), parameter :: drums = 9_int8
    integer(int8) :: ON
    integer(int8) :: OFF

    private

    public :: init_formidi, create_MIDI_file, quarter_note, drums, ON, OFF,&
            & write_MIDI_track_header, MIDI_tempo, &
            & write_end_of_MIDI_track, write_MIDI_track_size, &
            & MIDI_Program_Change, write_MIDI_note, close_MIDI_file, &
            & MIDI_Control_Change, MIDI_Note, MIDI_delta_time, &
            & get_MIDI_note, MIDI_text_event, MIDI_copyright_notice, &
            & MIDI_sequence_track_name, MIDI_instrument_name, MIDI_lyric, &
            & MIDI_marker, MIDI_cue_point

contains

    subroutine init_formidi()
        ! Initializes some parameters and verify the needed data types.

        ! We need those kinds for writing MIDI files.
        if ((int8 < 0) .or. (int16 < 0) .or. (int32 < 0)) then
            write(error_unit, *) "ERROR 1: int8 and/or int16 and/or int32 not supported!"
            error stop 1
        end if

        ! Initializing some useful MIDI parameters:
        ON = int(z'90', int8)
        OFF = int(z'80', int8)
    end subroutine


    subroutine write_variable_length_quantity(i)
        ! MIDI delta times are composed of one to four bytes, depending on their
        ! values. If there is still bytes to write, the most significant bit of
        ! the current byte is 1, else 0.
        ! https://en.wikipedia.org/wiki/Variable-length_quantity
        integer(int32), intent(in) :: i
        integer(int32) :: j, filo, again

        ! We use j because i has intent(in):
        j = i
        if (j > int(z'0FFFFFFF', int32)) then
            write(error_unit, *) "ERROR 2: delay > 0x0FFFFFFF !"
            error stop 2
        end if

        filo = iand(j, z'7F')
        j = ishft(j, -7)
        do
            if (j == 0) exit

            filo = ishft(filo, 8) + ior(iand(j, z'7F'), z'80')
            j = ishft(j, -7)
        end do

        do
            write(u, iostat=status) int(filo, int8)
            again = iand(filo, z'80')
            if (again /= 0) then
                filo = ishft(filo, 8)
            else
                exit
            end if
        end do
    end subroutine


    subroutine MIDI_delta_time(duration)
        ! Each MIDI event must be preceded by a delay called "delta time",
        ! expressed in MIDI ticks.
        integer(int32), intent(in) :: duration

        call write_variable_length_quantity(duration)
    end subroutine


    subroutine create_MIDI_file(file_name, SMF, tracks, q_ticks)
        character(len=*), intent(in) :: file_name
        integer(int8), intent(in) :: SMF
        integer(int16), intent(in) :: tracks
        integer(int32), intent(in) :: q_ticks
        integer(int8) :: octets(0:13)

        ! Header chunk: "MThd"
        octets(0) = int(z'4d', int8)
        octets(1) = int(z'54', int8)
        octets(2) = int(z'68', int8)
        octets(3) = int(z'64', int8)
        ! Remaining size of the header (6 bytes):
        octets(4) = int(z'00', int8)
        octets(5) = int(z'00', int8)
        octets(6) = int(z'00', int8)
        octets(7) = int(z'06', int8)
        ! SMF format:
        ! 0: only one track in the file
        ! 1: several tracks played together (generally used)
        ! 2: several tracks played sequentially
        if ((SMF == 0) .and. (tracks > 1)) then
            write(error_unit, *) "ERROR 3: you can use only one track with SMF 0"
            stop 3
        end if
        octets(8)  = 0
        octets(9)  = SMF
        ! Number of tracks (<=65535)
        octets(10) = int(ishft(tracks, -8), int8)
        octets(11) = int(tracks, int8)
        ! MIDI ticks per quarter note:
        octets(12) = int(ishft(q_ticks, -8), int8)
        octets(13) = int(q_ticks, int8)

        open(newunit=u, file=file_name, access='stream', status='replace', &
           & action='write', iostat=status)
        write(u, iostat=status) octets
    end subroutine


    subroutine close_MIDI_file()
        close(u, iostat=status)
    end subroutine


    integer(int32) function write_MIDI_track_header()
        ! Writes a track header and returns the position where the size of the
        ! track must be written when known.
        integer(int8) :: octets(0:7)
        integer(int32) :: pos_of_size

        ! The chunk begin with "MTrk":
        octets(0) = int(z'4d', int8)
        octets(1) = int(z'54', int8)
        octets(2) = int(z'72', int8)
        octets(3) = int(z'6b', int8)
        write(u, iostat=status) octets(0:3)
        ! Size of the data. Unknown for the moment.
        ! We memorize the position and will write the size when known.
        inquire(unit=u, POS=pos_of_size)
        octets(4) = int(z'00', int8)
        octets(5) = int(z'00', int8)
        octets(6) = int(z'00', int8)
        octets(7) = int(z'00', int8)
        write(u, iostat=status) octets(4:7)

        write_MIDI_track_header = pos_of_size
    end function


    subroutine MIDI_tempo(duration)
        ! Writes the duration of a quarter note expressed in µs. It is coded
        ! on 3 bytes: from 1 µs to 256**3 µs ~ 16.7 s.
        ! The tempo is in fact the number of quarter notes per second:
        ! a duration of 500000 µs = 0.5 s is equivalent to a 120 bpm tempo.
        ! https://en.wikipedia.org/wiki/Tempo
        integer(int32), intent(in) :: duration
        integer(int8) :: octets(0:5)

        ! Metadata always begin by 0xFF. Here, these codes mean we will define
        ! the music tempo:
        octets(0) = int(z'FF', int8)
        octets(1) = int(z'51', int8)
        octets(2) = int(z'03', int8)

        ! MIDI events must always be preceded by a "delta time", even if null:
        call MIDI_delta_time(0)

        ! Writes the tempo value:
        octets(3) = int(ishft(duration, -16), int8)
        octets(4) = int(ishft(duration, -8), int8)
        octets(5) = int(duration, int8)
        write(u, iostat=status) octets
    end subroutine


    subroutine MIDI_Program_Change(channel, instrument)
        ! Each channel (0..15) can use one General MIDI instrument (0..127) at
        ! a time.
        integer(int8), intent(in) :: channel, instrument
        integer(int8) :: octets(0:1)

        call MIDI_delta_time(0)

        octets(0) = int(z'C0', int8) + channel
        octets(1) = instrument
        write(u, iostat=status) octets
    end subroutine


    subroutine MIDI_Control_Change(channel, type, ctl_value)
        ! Many MIDI parameters can be set by Control Change. See the list.
        integer(int8), intent(in) :: channel, type, ctl_value
        integer(int8) :: octets(0:2)

        call MIDI_delta_time(0)

        octets(0) = int(z'B0', int8) + channel
        octets(1) = type
        octets(2) = ctl_value
        write(u, iostat=status) octets
    end subroutine


    subroutine MIDI_Note(event, channel, Note_MIDI, velocity)
        ! Writes a Note ON or Note OFF event. MIDI notes are in the range 0..127
        ! Velocity is in the range 1..127 and will set the volume.
        integer(int8), intent(in) :: event, channel, Note_MIDI, velocity
        integer(int8) :: octets(0:2)

        octets(0) = event + channel
        octets(1) = Note_MIDI
        octets(2) = velocity
        write(u, iostat=status) octets
    end subroutine


    subroutine write_MIDI_note(channel, Note_MIDI, velocity, duration)
        ! Write a Note ON event, waits for its duration, and writes a Note OFF.
        integer(int8), intent(in) :: channel, Note_MIDI, velocity
        integer(int32), intent(in) :: duration

        call MIDI_delta_time(0)
        call MIDI_Note(ON,  channel, Note_MIDI, velocity)
        call MIDI_delta_time(duration)
        call MIDI_Note(OFF, channel, Note_MIDI, 0_int8)
    end subroutine


    subroutine write_end_of_MIDI_track()
        ! A track must end with 0xFF2F00.
        integer(int8) :: octets(0:2)

        call MIDI_delta_time(0)

        octets(0) = int(z'FF', int8)
        octets(1) = int(z'2F', int8)
        octets(2) = int(z'00', int8)
        write(u, iostat=status) octets
    end subroutine


    subroutine write_MIDI_track_size(size_pos)
        ! Must be called when the track is finished. It writes its size at the
        ! memorized position in the track header.
        integer(int32), intent(in) :: size_pos
        integer(int8) :: octets(0:3)
        integer(int32) :: track_size
        integer(int32) :: pos_end_of_file

        ! Computes its size in bytes:
        inquire(unit=u, POS=pos_end_of_file)
        track_size = pos_end_of_file - (size_pos+4)

        octets(0) = int(ishft(track_size, -24), int8)
        octets(1) = int(ishft(track_size, -16), int8)
        octets(2) = int(ishft(track_size, -8), int8)
        octets(3) = int(track_size, int8)

        write(u, iostat=status, POS=size_pos) octets

        ! Back to the current end of the file:
        write(u, iostat=status, POS=pos_end_of_file)
    end subroutine


    subroutine write_string(event, text)
        integer(int8), intent(in) :: event
        character(len=*), intent(in) :: text
        integer(int8) :: octets(0:2)
        integer :: i

        call MIDI_delta_time(0)

        octets(0) = int(z'FF', int8)
        octets(1) = event
        write(u, iostat=status) octets(0:1)

        call write_variable_length_quantity(len(text))

        do i = 1, len(text)
           ! We suppose the system is using ASCII:
           write(u, iostat=status) iachar(text(i:i), int8)
        end do
    end subroutine


    subroutine MIDI_text_event(text)
        character(len=*), intent(in) :: text
        ! Text event: FF 01 len text
        call write_string(1_int8, text)
    end subroutine


    subroutine MIDI_copyright_notice(text)
        character(len=*), intent(in) :: text
        ! Copyright Notice event: FF 02 len text
        call write_string(2_int8, text)
    end subroutine


    subroutine MIDI_sequence_track_name(text)
        character(len=*), intent(in) :: text
        ! Sequence/Track Name event: FF 03 len text
        call write_string(3_int8, text)
    end subroutine


    subroutine MIDI_instrument_name(text)
        character(len=*), intent(in) :: text
        ! Instrument Name event: FF 04 len text
        call write_string(4_int8, text)
    end subroutine


    subroutine MIDI_lyric(text)
        character(len=*), intent(in) :: text
        ! Lyric event: FF 05 len text
        call write_string(5_int8, text)
    end subroutine


    subroutine MIDI_marker(text)
        character(len=*), intent(in) :: text
        ! Marker event: FF 06 len text
        call write_string(6_int8, text)
    end subroutine


    subroutine MIDI_cue_point(text)
        character(len=*), intent(in) :: text
        ! Cue Point event: FF 07 len text
        call write_string(7_int8, text)
    end subroutine


    integer(int8) function get_MIDI_note(note)
        ! Returns the MIDI note number, from 12 (C0) to 127 (G9).
        ! The note name is composed of two or three characters, 
        ! for example "A4", "A#4", "Ab4", where the final character is 
        ! the octave.
        character(*), intent(in) :: note
        ! 0 <= octave <=9
        integer(int8) :: octave
        ! Gap relative to A4 (note 69) in semitones:
        integer(int8) :: gap
        ! ASCII code of the 0 character:
        integer(int8), parameter :: zero = iachar('0')

        select case (note(1:1))
            case ('C')
                gap = -9
            case ('D')
                gap = -7
            case ('E')
                gap = -5
            case ('F')
                gap = -4
            case ('G')
                gap = -2
            case ('A') 
                gap = 0
            case ('B')
                gap = +2
            case default
                write(error_unit, *) "ERROR 4: unknown note name!"
                error stop 4
        end select

        ! Treating accidentals (sharp, flat) and computing the octave:
        select case (note(2:2))
            case ('b')
                gap = gap - 1_int8
                octave = iachar(note(3:3), int8) - zero
            case ('#')
                gap = gap + 1_int8
                octave = iachar(note(3:3), int8) - zero
            case default
                octave = iachar(note(2:2), int8) - zero
        end select

        if ((octave >= 0) .and. (octave <= 9)) then
            gap = gap + (octave - 4_int8) * 12_int8
        else
            write(error_unit, *) "ERROR 5: octave out of bounds [0; 9]"
            error stop 5
        end if

        ! Computing and returning the MIDI note number (A4 is 69):
        get_MIDI_note = 69_int8 + gap
    end function get_MIDI_note

end module formidi
