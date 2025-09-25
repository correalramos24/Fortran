MODULE nopenmp

    !$ USE omp_lib
    IMPLICIT NONE
    PUBLIC
    INTEGER, SAVE :: nompthreads
    INTEGER, SAVE :: nompminval
    INTEGER, SAVE :: nompmaxval
    INTEGER, SAVE, ALLOCATABLE, DIMENSION(:,:) :: nompstas
    INTEGER, SAVE, ALLOCATABLE, DIMENSION(:,:) :: nompends
    INTEGER, SAVE :: nompopt = 0
    INTEGER, SAVE :: nompht  = 2
 CONTAINS
    
    SUBROUTINE nompinfo( ktid, kthreads )
 
       INTEGER, INTENT(out) :: ktid, kthreads
 
       ktid = 0
       kthreads = 1
       !$ ktid = omp_get_thread_num()
       !$ kthreads = omp_get_num_threads()
 
    END SUBROUTINE nompinfo
 
    SUBROUTINE nompsetstaend( kthreads, kminval, kmaxval )
 
       INTEGER, INTENT(in) :: kthreads, kminval, kmaxval
       INTEGER :: jk, jt, jh, jjsize, jjmiss
       INTEGER, DIMENSION(kthreads) :: jjsizes
 
       nompthreads = kthreads
       nompminval  = kminval
       nompmaxval  = kmaxval
 
       ALLOCATE( &
          & nompstas(0:nompthreads-1,nompminval:nompmaxval), &
          & nompends(0:nompthreads-1,nompminval:nompmaxval)  &
          & )
 
       IF ( nompopt == 0 ) THEN
          DO jk = kminval, kmaxval
             jjsize = jk/nompthreads
             IF ( jjsize * nompthreads < jk ) jjsize = jjsize + 1
             DO jt = 1, nompthreads
                nompstas(jt-1,jk) = ( jt -1 ) * jjsize + 1
                nompends(jt-1,jk) = MIN( jt * jjsize, jk )
             ENDDO
          ENDDO
       ELSEIF ( nompopt == 1 ) THEN
          DO jk = kminval, kmaxval
             jjsize = jk/nompthreads
             jjmiss = jk - jjsize * nompthreads
             DO jt = 1, nompthreads
                IF ( jt <= jjmiss ) THEN
                   jjsizes(jt) = jjsize + 1
                ELSE
                   jjsizes(jt) = jjsize
                ENDIF
             ENDDO
             DO jt = 1, nompthreads
                IF (jt==1) THEN
                   nompstas(jt-1,jk) = 1
                   nompends(jt-1,jk) = jjsizes(jt)
                ELSE
                   nompstas(jt-1,jk) = nompends(jt-2,jk)+1
                   nompends(jt-1,jk) = nompends(jt-2,jk)+jjsizes(jt)
                ENDIF
             ENDDO
          ENDDO
       ELSEIF ( nompopt == 2 ) THEN
          DO jk = kminval, kmaxval
             jjsize = jk/nompthreads
             jjmiss = jk - jjsize * nompthreads
             DO jh = 1, nompht
                DO jt = jh, nompthreads, nompht
                   IF ( jjmiss > 0 ) THEN
                      jjsizes(jt) = jjsize + 1
                      jjmiss = jjmiss - 1
                   ELSE
                      jjsizes(jt) = jjsize
                   ENDIF
                ENDDO
             ENDDO
             DO jt = 1, nompthreads
                IF (jt==1) THEN
                   nompstas(jt-1,jk) = 1
                   nompends(jt-1,jk) = jjsizes(jt)
                ELSE
                   nompstas(jt-1,jk) = nompends(jt-2,jk)+1
                   nompends(jt-1,jk) = nompends(jt-2,jk)+jjsizes(jt)
                ENDIF
             ENDDO
          ENDDO
       ELSE
          WRITE(0,*)'Unknown option in nompsetstaend'
          CALL abort
       ENDIF
 
    END SUBROUTINE nompsetstaend
 
 END MODULE nopenmp