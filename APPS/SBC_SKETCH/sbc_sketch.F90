module sbc_sketch
    USE nopenmp
    implicit none
    
    PUBLIC   sbc_stokes
contains
    subroutine sbc_stokes(jpj, jpi, jpz)
        integer, intent(in) :: jpj, jpi, jpz
        INTEGER  ::   jj, ji, jk   ! dummy loop argument
        INTEGER  ::   ik           ! local integer 
        INTEGER  ::   jj1, jj2, itid, ithreads ! openmp variables
        REAL(8), ALLOCATABLE :: zk_t(:,:), zk_u(:,:), zk_v(:,:), e2u(:,:), e1v(:,:)
        REAL(8), ALLOCATABLE :: usd(:,:,:), vsd(:,:,:), ze3divh(:,:,:), e3u_n(:,:,:), e3v_n(:,:,:)
        
        ALLOCATE(zk_t(jpi, jpj)); ALLOCATE(zk_u(jpi, jpj)); ALLOCATE(zk_v(jpi, jpj))
        ALLOCATE(e2u(jpi,jpj)); ALLOCATE(e1v(jpi, jpj));
        ALLOCATE(usd(jpi, jpj, jpz)); ALLOCATE(vsd(jpi, jpj, jpz))
        ALLOCATE(ze3divh(jpi, jpj, jpz)); ALLOCATE(e3u_n(jpi, jpj, jpz)); ALLOCATE(e3v_n(jpi, jpj, jpz))
        
        !$omp parallel private(ithreads, itid, jj1, jj2)
        CALL nompinfo( itid, ithreads )
        jj1 = nompstas(itid,jpj)
        jj2 = nompends(itid,jpj)

        DO jj = MAX(1,jj1), MIN(jj2,jpj)
            DO ji = 1, jpi
                zk_t(ji,jj) = itid
            END DO
        END DO

        !$omp barrier

        DO jj = MAX(1,jj1), MIN(jj2,jpj - 1)
            DO ji = 1, jpi - 1 
               zk_u(ji,jj) = 0.5 * ( zk_t(ji,jj) + zk_t(ji+1,jj) )
               zk_v(ji,jj) = 0.5 * ( zk_t(ji,jj) + zk_t(ji,jj+1) )
            END DO
        END DO

        DO jk = 1, jpz-1
            DO jj = MAX(2,jj1), MIN(jj2,jpj-1)
               DO ji = 2, jpi-1
                usd(ji,jj,jk) = itid * 10
                vsd(ji,jj,jk) = itid * 10
               END DO
            END DO
        END DO


        !$omp master
        print *, "MPI COMMUNICATION HAPPENDS FOR USD & VSD -> 1s sleep"
        call sleep(1)
        !$omp end master 
        !$omp barrier

        ze3divh(:,jj1:jj2,:) = 0.0
        DO jk = 1, jpz-1
            DO jj = MAX(2,jj1), MIN(jj2,jpj)
               DO ji = 2, jpi
                ze3divh(ji,jj,jk) = (  e2u(ji  ,jj) * e3u_n(ji  ,jj,jk) * usd(ji  ,jj,jk)    &
                  &                 - e2u(ji-1,jj) * e3u_n(ji-1,jj,jk) * usd(ji-1,jj,jk)    &
                  &                 + e1v(ji,jj  ) * e3v_n(ji,jj  ,jk) * vsd(ji,jj  ,jk)    &
                  &                 - e1v(ji,jj-1) * e3v_n(ji,jj-1,jk) * vsd(ji,jj-1,jk)  )
               END DO 
            END DO
        END DO
        
        !$omp barrier
        !$omp master
        print *, "MPI COMMUNICATION HAPPENDS FOR ze3divh -> 1s sleep"
        call sleep(1)
        !$omp end master
        !$omp barrier


        !$omp end parallel  
    end subroutine sbc_stokes
end module sbc_sketch