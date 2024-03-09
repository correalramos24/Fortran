program saxpy_program
    implicit none
    real(8), allocatable    :: vec_x(:), vec_y(:), result(:)
    real(8)                 :: a
    integer                 :: N
    real(8)                 :: start_time, end_time, elapsed_time
    
    ! Read the size from the STDIN:
    write(*,*) 'Ingrese el tamaño N:'
    read(*,*) N

    ! Alloc & fill data:
    allocate(vec_x(N), vec_y(N), result(N))

    call random_number(vec_x)
    call random_number(vec_y)
    a = 2.0

    ! Call sAXpY
    call cpu_time(start_time)
    call saxpy(vec_x, vec_y, a, result)
    call cpu_time(end_time)
    elapsed_time = end_time - start_time

    write(*,*) 'SAXPY execution time:', elapsed_time, 'ms'

    ! Freee data:
    deallocate(vec_x, vec_y, result)

contains

    subroutine saxpy(vec_x, vec_y, a, result)
        real(8), allocatable, intent(in)    :: vec_x(:), vec_y(:)
        real(8), allocatable, intent(inout) :: result(:)
        real(8), intent(in)                 :: a
        integer                             :: i
        
        ! Do SAXPY
        do i = 1, size(vec_x)
            result(i) = a * vec_x(i) + vec_y(i)
        end do        
    end subroutine saxpy

end program saxpy_program