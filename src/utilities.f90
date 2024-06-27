! ForMIDI: a small Fortran MIDI sequencer for composing music, exploring
!          algorithmic music and music theory
! License GPL-3.0-or-later
! Vincent Magnin
! Last modifications: 2024-06-14

module utilities
    use, intrinsic :: iso_fortran_env, only: int8, int16, int32, error_unit

    implicit none

    public :: checked_int8, checked_int16, checked_int32

contains

    !> Receives a default kind integer, checks its MIDI bounds (15 or 127),
    !> fixes it if needed, and returns an int8:
    function checked_int8(i, upper) result(i8)
        integer, intent(in) :: i
        integer, optional, intent(in) :: upper      !  The upper limit
        integer :: u
        integer(int8) :: i8

        if (present(upper)) then
            u = upper
        else
            u = 127
        end if

        if ((i < 0).or.(i > u)) then
            if (i < 0) i8 = 0_int8
            if (i > u) i8 = int(u, kind=int8)
            write(error_unit, '("WARNING: int8 out of range [0 ; ", I0, "] => corrected to ", I0)') u, i8
        else
            i8 = int(i, kind=int8)
        end if
    end function

    !> Receives a default kind integer, checks its bounds (Fortran signed int),
    !> fixes it if needed, and returns an int16:
    function checked_int16(i) result(i16)
        integer, intent(in) :: i
        integer(int16) :: i16

        if ((i < 0).or.(i > 32767)) then
            if (i < 0) i16 = 0_int16
            if (i > 32767) i16 = 32767_int16
            write(error_unit, *) "WARNING: int16 out of range [0 ; 32767] => corrected to ", i16
        else
            i16 = int(i, kind=int16)
        end if
    end function

    !> Receives a default kind integer, checks its bounds (Fortran signed int),
    !> fixes it if needed, and returns an int32.
    function checked_int32(i) result(i32)
        integer, intent(in) :: i
        integer(int32) :: i32

        if ((i < 0).or.(i > 2147483647)) then
            if (i < 0) i32 = 0_int32
            if (i > 2147483647) i32 = 2147483647_int32
            write(error_unit, *) "WARNING: int32 out of range [0 ; 2147483647] => corrected to ", i32
        else
            i32 = int(i, kind=int32)
        end if
    end function

end module utilities
