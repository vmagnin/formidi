! ForMIDI: a small Fortran MIDI sequencer for composing music and exploring 
!          algorithmic music
! License GNU GPLv3
! Vincent Magnin, 2016-02-16 (C version)
! Fortran translation: 2021-03-01
! Last modifications: 2022-11-19

program main
    use formidi, only: init_formidi
    use demos, only: demo1, demo2, demo3

    implicit none

    call init_formidi()
    call demo1()
    call demo2()
    call demo3()
end program main
