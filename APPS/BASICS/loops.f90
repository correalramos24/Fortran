program fort_loops
    implicit none
    integer :: array(40)
    integer :: i
    integer, parameter :: N = 40


    do i = 1, N
        array(i) = i*10
        print *, i, array(i)
    end do

    
end program fort_loops