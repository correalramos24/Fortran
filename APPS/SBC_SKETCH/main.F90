

program sbc_main
    USE iso_fortran_env
    USE sbc_sketch

    implicit none
    integer :: jpj, jpi, jpz ! cols, rows, depth
    INTEGER :: itid, ithreads, nomplats
    ! dummy:
    integer :: count
    character(len=10) :: arg1_str, arg2_str, arg3_str
    
    ! Get parameters of execution
    count = command_argument_count()
    if (count /= 3) then
        print *, "Error: You must enter three parameters (x,y,z)."
        stop
    end if

    call get_command_argument(1, arg1_str)
    call get_command_argument(2, arg2_str)
    call get_command_argument(3, arg3_str)
    read(arg1_str, *) jpj
    read(arg2_str, *) jpi
    read(arg3_str, *) jpz

    if (jpj > 0 .and. jpi > 0 .and. jpz > 0) then
        print *, "jpj:", jpj, "jpi:", jpi, "jpz:", jpz
    else
        print *, "Error: Todos los valores deben ser enteros mayores que 0."
    end if
    
    ! INIT OMP:
    !$omp parallel private(ithreads,itid,nomplats)
    CALL nompinfo( itid, ithreads )
    !$omp master
    CALL nompsetstaend( ithreads, 0, jpi*jpj )
    !$omp end master
    !$omp barrier
    nomplats = nompends(itid,jpj) - nompstas(itid,jpj) + 1
    print *,'thread ',itid,' of ',ithreads,&
       & ' nompstas(itid,jpj) = ',nompstas(itid,jpj),&
       & ' nompends(itid,jpj) ',nompends(itid,jpj),' nlats = ', nomplats
    !$omp end parallel

    call sbc_stokes(jpj,jpi,jpz)


end program sbc_main