! ForMIDI: a small Fortran MIDI sequencer for composing music, exploring
!          algorithmic music and music theory
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-20

module MIDI_file_class
    use, intrinsic :: iso_fortran_env, only: int8, int16, int32, error_unit
    use utilities, only: checked_int8, checked_int16, checked_int32

    implicit none
    !------------------------
    ! Useful MIDI parameters
    !------------------------
    ! Timing resolution (number of MIDI ticks in a quarter note): the value 96
    ! is commonly used because it can be divided by 2 and 3.
    integer, parameter :: quarter_note = 96
    ! Percussions channel (in the 0..15 range):
    integer, parameter :: drums = 9
    ! Used by Note ON and Note OFF events:
    integer, parameter :: ON  = 144     ! z'90'
    integer, parameter :: OFF = 128     ! z'80'

    type MIDI_file
        character(len=:), private, allocatable :: filename
        ! Output unit and file status:
        integer, private :: unit
        integer, private :: status
        ! To store where to write the size of a track in the file:
        integer(int32), private :: size_pos
    contains
        procedure, private :: init_formidi
        procedure, private :: write_variable_length_quantity
        procedure :: new
        procedure :: track_header
        procedure :: set_tempo
        procedure :: set_time_signature
        procedure :: end_of_track
        procedure :: get_name
        procedure, private :: write_track_size
        procedure :: Program_Change
        procedure :: play_note
        procedure :: play_chord
        procedure :: play_broken_chord
        procedure :: close
        procedure :: Control_Change
        procedure :: Note_ON
        procedure :: Note_OFF
        procedure :: delta_time
        procedure, private :: write_string
        procedure :: text_event
        procedure, private :: copyright_notice
        procedure :: sequence_track_name
        procedure :: instrument_name
        procedure :: lyric
        procedure :: marker
        procedure :: cue_point
    end type MIDI_file

    private

    public :: MIDI_file, quarter_note, drums, ON, OFF

contains

    ! Create a new MIDI file and its metadata track.
    ! Concerning the "divisions" argument, ForMIDI uses the "metrical timing"
    ! scheme, defining the number of ticks in a quarter note. The "timecode"
    ! scheme is not implemented.
    subroutine new(self, file_name, format, tracks, divisions, tempo, time_signature, copyright, text_event)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: file_name
        integer, intent(in) :: format    ! 8 bits
        integer, intent(in) :: tracks    ! 16 bits
        integer, intent(in) :: divisions  ! 32 bits
        integer, intent(in) :: tempo     ! 32 bits
        integer, optional, intent(in) :: time_signature(:)
        character(len=*), optional, intent(in) :: copyright
        character(len=*), optional, intent(in) :: text_event
        integer(int8)  :: octets(0:13)
        integer(int16) :: t
        integer(int32) :: d

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
        if ((format == 0) .and. (tracks > 1)) then
            write(error_unit, *) "ERROR 3: you can use only one track with SMF 0"
            stop 3
        end if
        octets(8)  = 0
        octets(9)  = checked_int8(format)
        ! Number of tracks (<=65535)
        t = checked_int16(tracks)
        octets(10) = int(ishft(t, -8), int8)
        octets(11) = int(t, int8)
        ! MIDI ticks per quarter note ("metrical timing" scheme):
        d = checked_int32(divisions)
        octets(12) = int(ishft(d, -8), int8)
        octets(13) = int(d, int8)

        open(newunit=self%unit, file=file_name, access='stream', status='replace', &
           & action='write', iostat=self%status)

        write(self%unit, iostat=self%status) octets

        ! Starting with the metadata track:
        call self%track_header()

        if (present(copyright)) call self%copyright_notice(copyright)
        if (present(text_event)) call self%text_event(text_event)

        if (.not.present(time_signature)) then
            ! Default values 4/4 and 24 MIDI clocks (a quarter note) for the metronome:
            call set_time_signature(self, numerator=4, denominator=4, metronome=24)
        else
            if (size(time_signature) == 2) then
                ! The default metronome is 24 MIDI clocks (a quarter note):
                call set_time_signature(self, numerator=time_signature(1), denominator=time_signature(2), metronome=24)
            else
                call set_time_signature(self, numerator=time_signature(1), denominator=time_signature(2), &
                                      & metronome=time_signature(3))
            end if
        end if

        call self%set_tempo(checked_int32(tempo))
        ! Closing the metadata track:
        call self%end_of_track()
    end subroutine

    ! Verifies the needed data types.
    subroutine init_formidi(self)
        class(MIDI_file), intent(in) :: self

        ! We need those kinds for writing MIDI files.
        if ((int8 < 0) .or. (int16 < 0) .or. (int32 < 0)) then
            write(error_unit, *) "ERROR 1: int8 and/or int16 and/or int32 not supported!"
            error stop 1
        end if
    end subroutine

    ! MIDI delta times are composed of one to four bytes, depending on their
    ! values. If there is still bytes to write, the MSB (most significant bit)
    ! of the current byte is 1, else 0.
    ! https://en.wikipedia.org/wiki/Variable-length_quantity
    subroutine write_variable_length_quantity(self, i)
        class(MIDI_file), intent(inout) :: self
        integer(int32), intent(in) :: i
        integer(int32) :: j, again
        ! A First In Last Out 4 bytes stack (or Last In First Out):
        integer(int32) :: filo

        ! The maximum possible MIDI value:
        if (i > int(z'0FFFFFFF', int32)) then
            write(error_unit, *) "ERROR 2: delay > 0x0FFFFFFF ! ", i
            error stop 2
        end if

        ! We use a variable j because i has intent(in):
        j = i
        filo = 0
        ! The 7 least significant bits are placed in filo (0x7F = 0b01111111):
        filo = iand(j, z'7F')
        ! They are now eliminated from j by shifting bits of j 7 places
        ! to the right (zeros are introduced on the left):
        j = ishft(j, -7)
        ! The same process is a applied until j is empty:
        do
            if (j == 0) exit
            ! The bits already in filo are shifted 1 byte to the left:
            filo = ishft(filo, +8)
            ! A byte of j with the most signicant bit set to 1 (0x80 = 0b10000000)
            ! can now be added on the right of filo:
            filo = filo + ior(iand(j, z'7F'), z'80')
            ! Preparing next iteration:
            j = ishft(j, -7)
        end do

        ! The bytes accumulated in filo are now written in the file
        ! in the reverse order:
        do
            ! Writing the LSB of filo:
            write(self%unit, iostat=self%status) int(filo, int8)
            ! Is the bit 8 a 1? (meaning there is still other bytes to read):
            again = iand(filo, z'80')
            if (again /= 0) then
                ! The written LSB can now be eliminated before next iteration:
                filo = ishft(filo, -8)
            else
                ! Nothing left to write:
                exit
            end if
        end do
    end subroutine

    ! Each MIDI event must be preceded by a delay called "delta time",
    ! expressed in MIDI ticks.
    subroutine delta_time(self, ticks)
        class(MIDI_file), intent(inout) :: self
        integer, intent(in) :: ticks

        call self%write_variable_length_quantity(checked_int32(ticks))
    end subroutine


    subroutine close(self)
        class(MIDI_file), intent(inout) :: self

        close(self%unit, iostat=self%status)
    end subroutine

    ! Writes a track header and stores the position where the size of the
    ! track will be written when the track will be closed.
    subroutine track_header(self, track_name, text_event)
        class(MIDI_file), intent(inout) :: self
        character(len=*), optional, intent(in) :: track_name
        character(len=*), optional, intent(in) :: text_event
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

        if (present(track_name)) call self%sequence_track_name(track_name)
        if (present(text_event)) call self%text_event(text_event)
    end subroutine

    ! Returns the name of the MIDI file:
    function get_name(self)
        class(MIDI_file), intent(in) :: self
        character(len(self%filename)) :: get_name

        get_name = self%filename
    end function

    ! Specifies a tempo change by writing the duration of a quarter note
    ! expressed in µs. It is coded on 3 bytes: from 1 µs to 256**3 µs ~ 16.7 s.
    ! A duration of 500000 µs = 0.5 s is equivalent to a 120 bpm tempo.
    ! https://en.wikipedia.org/wiki/Tempo
    subroutine set_tempo(self, duration)
        class(MIDI_file), intent(inout) :: self
        integer, intent(in) :: duration     ! 32 bits
        integer(int32) :: d
        integer(int8) :: octets(0:5)

        ! MIDI events must always be preceded by a "delta time", even if null:
        call self%delta_time(0)

        ! Metadata always begin by 0xFF. Here, these codes mean we will define
        ! the music tempo:
        octets(0) = int(z'FF', int8)
        octets(1) = int(z'51', int8)
        octets(2) = int(z'03', int8)

        ! Writes the tempo value:
        d = checked_int32(duration)
        octets(3) = int(ishft(d, -16), int8)
        octets(4) = int(ishft(d, -8), int8)
        octets(5) = int(d, int8)
        write(self%unit, iostat=self%status) octets
    end subroutine

    ! The time signature includes the numerator,  the denominator,
    ! the number of MIDI clocks between metronome ticks,
    ! (there are 24 MIDI clocks per quarter note)
    ! and the number of 32nd notes in a quarter note.
    ! The number of "MIDI clocks" between metronome clicks.
    subroutine set_time_signature(self, numerator, denominator, metronome, tsnotes)
        class(MIDI_file), intent(inout) :: self
        integer, intent(in) :: numerator, denominator, metronome  ! 8 bits
        integer, optional, intent(in) :: tsnotes                  ! 8 bits
        integer(int8) :: octets(0:6)

        ! MIDI events must always be preceded by a "delta time", even if null:
        call self%delta_time(0)

        ! Metadata always begin by 0xFF. Here, these bytes mean we will define
        ! the time signature:
        octets(0) = int(z'FF', int8)
        octets(1) = int(z'58', int8)
        octets(2) = int(z'04', int8)
        ! The data:
        octets(3) = checked_int8(numerator)
        ! That byte is the power of 2 of the denominator, for example 3 for
        ! a denominator whose value is 8:
        octets(4) = checked_int8(nint(log(real(denominator))/log(2.0)))
        octets(5) = checked_int8(metronome)
        if (present(tsnotes)) then
            octets(6) = checked_int8(tsnotes)
        else
            octets(6) = 8_int8     ! Default value
        end if

        write(self%unit, iostat=self%status) octets
    end subroutine set_time_signature

    ! Each channel (0..15) can use one General MIDI instrument (0..127) at
    ! a time.
    subroutine Program_Change(self, channel, instrument)
        class(MIDI_file), intent(inout) :: self
        integer, intent(in) :: channel, instrument      ! 8 bits
        integer(int8) :: octets(0:1)

        call self%delta_time(0)

        octets(0) = int(z'C0', int8) + checked_int8(channel, upper=15)
        octets(1) = checked_int8(instrument)
        write(self%unit, iostat=self%status) octets
    end subroutine

    ! Many MIDI parameters can be set by Control Change. See the list.
    subroutine Control_Change(self, channel, type, ctl_value)
        class(MIDI_file), intent(inout) :: self
        integer, intent(in) :: channel, type, ctl_value       ! 8 bits
        integer(int8) :: octets(0:2)

        call self%delta_time(0)

        octets(0) = int(z'B0', int8) + checked_int8(channel, upper=15)
        octets(1) = checked_int8(type)
        octets(2) = checked_int8(ctl_value)
        write(self%unit, iostat=self%status) octets
    end subroutine

    ! Writes a Note ON event. MIDI notes are in the range 0..127
    ! The attack velocity is in the range 1..127 and will set the volume.
    ! A Note ON event with a zero velocity is equivalent to a Note OFF.
    subroutine Note_ON(self, channel, note, velocity)
        class(MIDI_file), intent(inout) :: self
        integer, intent(in) :: channel, note, velocity    ! 8 bits
        integer(int8) :: octets(0:2)

        octets(0) = ON + checked_int8(channel, upper=15)
        octets(1) = checked_int8(note)
        octets(2) = checked_int8(velocity)
        write(self%unit, iostat=self%status) octets
    end subroutine Note_ON

    ! Writes a Note OFF event. MIDI notes are in the range 0..127
    ! The release velocity is in the range 0..127.
    subroutine Note_OFF(self, channel, note, velocity)
        class(MIDI_file), intent(inout) :: self
        integer, intent(in) :: channel, note         ! 8 bits
        integer, optional, intent(in) :: velocity    ! 8 bits
        integer(int8) :: octets(0:2)

        octets(0) = OFF + checked_int8(channel, upper=15)
        octets(1) = checked_int8(note)
        if (present(velocity)) then
            octets(2) = checked_int8(velocity)
        else
            octets(2) = 64      ! Default value if no velocity captor
        end if
        write(self%unit, iostat=self%status) octets
    end subroutine Note_OFF

    ! Write a Note ON event, waits for its duration, and writes a Note OFF.
    subroutine play_note(self, channel, note, velocity, value)
        class(MIDI_file), intent(inout) :: self
        integer, intent(in) :: channel, note, velocity    ! 8 bits
        integer, intent(in) :: value    ! 32 bits

        call self%delta_time(0)
        call self%Note_ON(channel, note, velocity)
        call self%delta_time(checked_int32(value))
        call self%Note_OFF(channel, note)
    end subroutine

    ! A track must end with 0xFF2F00.
    subroutine end_of_track(self)
        class(MIDI_file), intent(inout) :: self
        integer(int8) :: octets(0:2)

        call self%delta_time(0)

        octets(0) = int(z'FF', int8)
        octets(1) = int(z'2F', int8)
        octets(2) = int(z'00', int8)
        write(self%unit, iostat=self%status) octets

        ! Then write the size of the track at its beginning:
        call self%write_track_size()
    end subroutine

    ! Must be called when the track is finished. It writes its size at the
    ! memorized position in the track header.
    subroutine write_track_size(self)
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

    ! This subroutine is used my many events.
    ! The text must be coded in ASCII (7 bits).
    subroutine write_string(self, event, text)
        class(MIDI_file), intent(inout) :: self
        integer, intent(in) :: event      ! 8 bits
        character(len=*), intent(in) :: text
        integer(int8) :: octets(0:1)
        integer :: i

        call self%delta_time(0)

        octets(0) = int(z'FF', int8)
        octets(1) = checked_int8(event)
        write(self%unit, iostat=self%status) octets

        call self%write_variable_length_quantity(len(text))

        do i = 1, len(text)
           ! We suppose the system is using ASCII:
           write(self%unit, iostat=self%status) iachar(text(i:i), int8)
        end do
    end subroutine


    ! Text event: FF 01 len text
    subroutine text_event(self, text)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: text

        call self%write_string(event=1, text=text)
    end subroutine

    ! Copyright Notice event: FF 02 len text
    subroutine copyright_notice(self, text)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: text

        call self%write_string(event=2, text=text)
    end subroutine

    ! Sequence or Track Name event: FF 03 len text
    subroutine sequence_track_name(self, text)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: text

        call self%write_string(event=3, text=text)
    end subroutine

    ! Instrument Name event: FF 04 len text
    subroutine instrument_name(self, text)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: text

        call self%write_string(event=4, text=text)
    end subroutine

    ! Lyric event: FF 05 len text
    subroutine lyric(self, text)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: text

        call self%write_string(event=5, text=text)
    end subroutine

    ! Marker event: FF 06 len text
    subroutine marker(self, text)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: text

        call self%write_string(event=6, text=text)
    end subroutine

    ! Cue Point event: FF 07 len text
    subroutine cue_point(self, text)
        class(MIDI_file), intent(inout) :: self
        character(len=*), intent(in) :: text

        call self%write_string(event=7, text=text)
    end subroutine

    ! Writes a chord, waits for its duration, and writes the OFF events
    subroutine play_chord(self, channel, note, chord, velocity, value)
        class(MIDI_file), intent(inout) :: self
        integer, intent(in)  :: channel, note     ! 8 bits
        integer, dimension(:), intent(in) :: chord
        integer, intent(in) :: velocity           ! 8 bits
        integer, intent(in) :: value              ! 32 bits
        integer :: i

        do i = 1, size(chord)
            call self%delta_time(0)
            call self%Note_ON(channel, note + chord(i), velocity)
        end do

        call self%delta_time(checked_int32(value))

        do i = 1, size(chord)
            call self%Note_OFF(channel, note + chord(i))
            if (i < size(chord)) call self%delta_time(0)
        end do
    end subroutine

    ! Writes a broken chord using an array containing the intervals
    ! (see the music_common module).
    ! For the moment, each note has the same duration.
    ! https://en.wikipedia.org/wiki/Arpeggio
    subroutine play_broken_chord(self, channel, note, chord, velocity, value)
        class(MIDI_file), intent(inout) :: self
        integer, intent(in)  :: channel, note     ! 8 bits
        integer, dimension(:), intent(in) :: chord
        integer, intent(in) :: velocity           ! 8 bits
        integer, intent(in) :: value              ! 32 bits
        integer(int32) :: dnote, residual
        integer :: i

        dnote = nint(real(checked_int32(value)) / size(chord))
        ! The MIDI duration being an integer, the last note of the chord may
        ! have a slightly different duration to keep the total duration exact:
        residual = checked_int32(value) - dnote*(size(chord) - 1)

        call self%delta_time(0)
        do i = 1, size(chord)
            call self%Note_ON(channel, note + chord(i), velocity)
            if (i < size(chord)) then 
                call self%delta_time(dnote)
            else
                call self%delta_time(residual)
            end if
        end do

        do i = 1, size(chord)
            call self%Note_OFF(channel, note + chord(i))
            ! The delta time must always be placed before a note:
            if (i < size(chord)) call self%delta_time(0)
        end do
    end subroutine play_broken_chord

end module MIDI_file_class
