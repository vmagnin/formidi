! ForMIDI: a small Fortran MIDI sequencer for composing music, exploring
!          algorithmic music and music theory
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-09

module MIDI_file_class
    use, intrinsic :: iso_fortran_env, only: int8, int16, int32, error_unit

    implicit none
    ! Useful MIDI parameters:
    integer(int32), parameter :: quarter_note = 128
    ! Percussions channel (in the 0..15 range):
    integer(int8), parameter :: drums = 9_int8
    integer(int8) :: ON
    integer(int8) :: OFF

    type MIDI_file
        character(len=:), allocatable :: filename
        ! Output unit:
        integer, private :: unit
        integer, private :: status
        integer(int32), private :: size_pos
    contains
        procedure, private :: init_formidi
        procedure, private :: write_variable_length_quantity
        procedure :: create_MIDI_file
        procedure :: write_MIDI_track_header
        procedure :: MIDI_tempo
        procedure :: write_end_of_MIDI_track
        procedure :: write_MIDI_track_size
        procedure :: MIDI_Program_Change
        procedure :: write_MIDI_note
        procedure :: write_chord
        procedure :: write_broken_chord
        procedure :: close_MIDI_file
        procedure :: MIDI_Control_Change
        procedure :: MIDI_Note
        procedure :: MIDI_delta_time
        procedure, private :: write_string
        procedure :: MIDI_text_event
        procedure :: MIDI_copyright_notice
        procedure :: MIDI_sequence_track_name
        procedure :: MIDI_instrument_name
        procedure :: MIDI_lyric
        procedure :: MIDI_marker
        procedure :: MIDI_cue_point
    end type MIDI_file

    private

    public :: MIDI_file, quarter_note, drums, ON, OFF

contains

    ! Initializes some parameters and verify the needed data types.
    subroutine init_formidi(self)
        class(MIDI_file), intent(inout) :: self

        ! We need those kinds for writing MIDI files.
        if ((int8 < 0) .or. (int16 < 0) .or. (int32 < 0)) then
            write(error_unit, *) "ERROR 1: int8 and/or int16 and/or int32 not supported!"
            error stop 1
        end if

        ! Initializing some useful MIDI parameters:
        ON = int(z'90', int8)
        OFF = int(z'80', int8)
    end subroutine


    ! MIDI delta times are composed of one to four bytes, depending on their
    ! values. If there is still bytes to write, the most significant bit of
    ! the current byte is 1, else 0.
    ! https://en.wikipedia.org/wiki/Variable-length_quantity
    subroutine write_variable_length_quantity(self, i)
        class(MIDI_file), intent(inout) :: self
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
            write(self%unit, iostat=self%status) int(filo, int8)
            again = iand(filo, z'80')
            if (again /= 0) then
                filo = ishft(filo, 8)
            else
                exit
            end if
        end do
    end subroutine

    ! Each MIDI event must be preceded by a delay called "delta time",
    ! expressed in MIDI ticks.
    subroutine MIDI_delta_time(self, duration)
        class(MIDI_file), intent(inout) :: self
        integer(int32), intent(in) :: duration

        call self%write_variable_length_quantity(duration)
    end subroutine


    subroutine create_MIDI_file(self, file_name, SMF, tracks, q_ticks)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: file_name
        integer(int8), intent(in) :: SMF
        integer(int16), intent(in) :: tracks
        integer(int32), intent(in) :: q_ticks
        integer(int8) :: octets(0:13)

        call self%init_formidi()

        self%filename = file_name

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

        open(newunit=self%unit, file=file_name, access='stream', status='replace', &
           & action='write', iostat=self%status)

        write(self%unit, iostat=self%status) octets

        ! Starting with the metadata track:
        call self%write_MIDI_track_header()
    end subroutine


    subroutine close_MIDI_file(self)
        class(MIDI_file), intent(inout) :: self

        close(self%unit, iostat=self%status)
    end subroutine

    ! Writes a track header and returns the position where the size of the
    ! track must be written when known.
    subroutine write_MIDI_track_header(self)
        class(MIDI_file), intent(inout) :: self
        integer(int8) :: octets(0:7)

        ! The chunk begin with "MTrk":
        octets(0) = int(z'4d', int8)
        octets(1) = int(z'54', int8)
        octets(2) = int(z'72', int8)
        octets(3) = int(z'6b', int8)
        write(self%unit, iostat=self%status) octets(0:3)
        ! Size of the data. Unknown for the moment.
        ! We memorize the position and will write the size when known.
        inquire(unit=self%unit, POS=self%size_pos)
        octets(4) = int(z'00', int8)
        octets(5) = int(z'00', int8)
        octets(6) = int(z'00', int8)
        octets(7) = int(z'00', int8)
        write(self%unit, iostat=self%status) octets(4:7)
    end subroutine

    ! Writes the duration of a quarter note expressed in µs. It is coded
    ! on 3 bytes: from 1 µs to 256**3 µs ~ 16.7 s.
    ! The tempo is in fact the number of quarter notes per second:
    ! a duration of 500000 µs = 0.5 s is equivalent to a 120 bpm tempo.
    ! https://en.wikipedia.org/wiki/Tempo
    subroutine MIDI_tempo(self, duration)
        class(MIDI_file), intent(inout) :: self
        integer(int32), intent(in) :: duration
        integer(int8) :: octets(0:5)

        ! Metadata always begin by 0xFF. Here, these codes mean we will define
        ! the music tempo:
        octets(0) = int(z'FF', int8)
        octets(1) = int(z'51', int8)
        octets(2) = int(z'03', int8)

        ! MIDI events must always be preceded by a "delta time", even if null:
        call self%MIDI_delta_time(0)

        ! Writes the tempo value:
        octets(3) = int(ishft(duration, -16), int8)
        octets(4) = int(ishft(duration, -8), int8)
        octets(5) = int(duration, int8)
        write(self%unit, iostat=self%status) octets
    end subroutine

    ! Each channel (0..15) can use one General MIDI instrument (0..127) at
    ! a time.
    subroutine MIDI_Program_Change(self, channel, instrument)
        class(MIDI_file), intent(inout) :: self
        integer(int8), intent(in) :: channel, instrument
        integer(int8) :: octets(0:1)

        call self%MIDI_delta_time(0)

        octets(0) = int(z'C0', int8) + channel
        octets(1) = instrument
        write(self%unit, iostat=self%status) octets
    end subroutine

    ! Many MIDI parameters can be set by Control Change. See the list.
    subroutine MIDI_Control_Change(self, channel, type, ctl_value)
        class(MIDI_file), intent(inout) :: self
        integer(int8), intent(in) :: channel, type, ctl_value
        integer(int8) :: octets(0:2)

        call self%MIDI_delta_time(0)

        octets(0) = int(z'B0', int8) + channel
        octets(1) = type
        octets(2) = ctl_value
        write(self%unit, iostat=self%status) octets
    end subroutine

    ! Writes a Note ON or Note OFF event. MIDI notes are in the range 0..127
    ! Velocity is in the range 1..127 and will set the volume.
    subroutine MIDI_Note(self, event, channel, Note_MIDI, velocity)
        class(MIDI_file), intent(inout) :: self
        integer(int8), intent(in) :: event, channel, Note_MIDI, velocity
        integer(int8) :: octets(0:2)

        octets(0) = event + channel
        octets(1) = Note_MIDI
        octets(2) = velocity
        write(self%unit, iostat=self%status) octets
    end subroutine

    ! Write a Note ON event, waits for its duration, and writes a Note OFF.
    subroutine write_MIDI_note(self, channel, Note_MIDI, velocity, duration)
        class(MIDI_file), intent(inout) :: self
        integer(int8), intent(in) :: channel, Note_MIDI, velocity
        integer(int32), intent(in) :: duration

        call self%MIDI_delta_time(0)
        call self%MIDI_Note(ON,  channel, Note_MIDI, velocity)
        call self%MIDI_delta_time(duration)
        call self%MIDI_Note(OFF, channel, Note_MIDI, 0_int8)
    end subroutine

    ! A track must end with 0xFF2F00.
    subroutine write_end_of_MIDI_track(self)
        class(MIDI_file), intent(inout) :: self
        integer(int8) :: octets(0:2)

        call self%MIDI_delta_time(0)

        octets(0) = int(z'FF', int8)
        octets(1) = int(z'2F', int8)
        octets(2) = int(z'00', int8)
        write(self%unit, iostat=self%status) octets

        ! Then write the size of the track at its beginning:
        call self%write_MIDI_track_size()
    end subroutine

    ! Must be called when the track is finished. It writes its size at the
    ! memorized position in the track header.
    subroutine write_MIDI_track_size(self)
        class(MIDI_file), intent(inout) :: self
        integer(int8) :: octets(0:3)
        integer(int32) :: track_size
        integer(int32) :: pos_end_of_file

        ! Computes its size in bytes:
        inquire(unit=self%unit, POS=pos_end_of_file)
        track_size = pos_end_of_file - (self%size_pos+4)

        octets(0) = int(ishft(track_size, -24), int8)
        octets(1) = int(ishft(track_size, -16), int8)
        octets(2) = int(ishft(track_size, -8), int8)
        octets(3) = int(track_size, int8)

        write(self%unit, iostat=self%status, POS=self%size_pos) octets

        ! Back to the current end of the file:
        write(self%unit, iostat=self%status, POS=pos_end_of_file)
    end subroutine


    subroutine write_string(self, event, text)
        class(MIDI_file), intent(inout) :: self
        integer(int8), intent(in) :: event
        character(len=*), intent(in) :: text
        integer(int8) :: octets(0:2)
        integer :: i

        call self%MIDI_delta_time(0)

        octets(0) = int(z'FF', int8)
        octets(1) = event
        write(self%unit, iostat=self%status) octets(0:1)

        call self%write_variable_length_quantity(len(text))

        do i = 1, len(text)
           ! We suppose the system is using ASCII:
           write(self%unit, iostat=self%status) iachar(text(i:i), int8)
        end do
    end subroutine


    ! Text event: FF 01 len text
    subroutine MIDI_text_event(self, text)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: text

        call self%write_string(1_int8, text)
    end subroutine

    ! Copyright Notice event: FF 02 len text
    subroutine MIDI_copyright_notice(self, text)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: text

        call self%write_string(2_int8, text)
    end subroutine


    ! Sequence/Track Name event: FF 03 len text
    subroutine MIDI_sequence_track_name(self, text)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: text

        call self%write_string(3_int8, text)
    end subroutine

    ! Instrument Name event: FF 04 len text
    subroutine MIDI_instrument_name(self, text)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: text

        call self%write_string(4_int8, text)
    end subroutine

    ! Lyric event: FF 05 len text
    subroutine MIDI_lyric(self, text)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: text

        call self%write_string(5_int8, text)
    end subroutine

    ! Marker event: FF 06 len text
    subroutine MIDI_marker(self, text)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: text

        call self%write_string(6_int8, text)
    end subroutine

    ! Cue Point event: FF 07 len text
    subroutine MIDI_cue_point(self, text)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: text

        call self%write_string(7_int8, text)
    end subroutine

    ! Writes a chord, waits for its duration, and writes the OFF events
    subroutine write_chord(self, channel, Note_MIDI, chord, velocity, duration)
        class(MIDI_file), intent(inout) :: self
        integer(int8), intent(in)  :: channel, Note_MIDI
        integer, dimension(:), intent(in) :: chord
        integer(int8),  intent(in) :: velocity
        integer(int32), intent(in) :: duration
        integer :: i

        do i = 1, size(chord)
            call self%MIDI_delta_time(0)
            call self%MIDI_Note(ON,  channel, Note_MIDI + int(chord(i), kind=int8), velocity)
        end do

        call self%MIDI_delta_time(duration)

        do i = 1, size(chord)
            call self%MIDI_Note(OFF, channel, Note_MIDI + int(chord(i), kind=int8), 0_int8)
            if (i < size(chord)) call self%MIDI_delta_time(0)
        end do
    end subroutine

    ! Writes a broken chord using an array containing the intervals
    ! (see the music_common module).
    ! For the moment, each note has the same duration.
    ! https://en.wikipedia.org/wiki/Arpeggio
    subroutine write_broken_chord(self, channel, Note_MIDI, chord, velocity, duration)
        class(MIDI_file), intent(inout) :: self
        integer(int8), intent(in)  :: channel, Note_MIDI
        integer, dimension(:), intent(in) :: chord
        integer(int8),  intent(in) :: velocity
        integer(int32), intent(in) :: duration
        integer(int32) :: dnote, residual
        integer :: i

        dnote = nint(real(duration) / size(chord))
        ! The MIDI duration being an integer, the last note of the chord may
        ! have a slightly different duration to keep the total duration exact:
        residual = duration - dnote*(size(chord) - 1)

        call self%MIDI_delta_time(0)
        do i = 1, size(chord)
            call self%MIDI_Note(ON,  channel, Note_MIDI + int(chord(i), kind=int8), velocity)
            if (i < size(chord)) then 
                call self%MIDI_delta_time(dnote)
            else
                call self%MIDI_delta_time(residual)
            end if
        end do

        do i = 1, size(chord)
            call self%MIDI_Note(OFF, channel, Note_MIDI + int(chord(i), kind=int8), 0_int8)
            ! The delta time must always be placed before a note:
            if (i < size(chord)) call self%MIDI_delta_time(0)
        end do
    end subroutine write_broken_chord

end module MIDI_file_class
