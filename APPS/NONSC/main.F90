program calc_zbetup
  implicit none
  integer, parameter :: sp = kind(1.0)  ! single precision
  integer, parameter :: ni=40, nj=40, nk=40
  integer :: i, j, k
  real(sp) :: zbup(ni,nj,nk)
  real(sp) :: paft(ni,nj,nk)
  real(sp) :: zbetup(ni,nj,nk)
  real(sp) :: zpos, zrtrn, zbt
  real(sp) :: zup
  integer :: im1, ip1, jm1, jp1, km1, kp1

  ! Inicialización de variables de ejemplo
  zpos = 1.0_sp
  zrtrn = 0.5_sp
  zbt = 2.0_sp

  do i = 1, ni
     do j = 1, nj
        do k = 1, nk
           zbup(i,j,k) = real(i+j+k,sp)
           paft(i,j,k) = 0.1_sp * real(i+j+k,sp)
        end do
     end do
  end do

  ! Cálculo de zbetup
  do i = 1, ni - 1
     do j = 1, nj - 1
        do k = 1, nk - 1 
           zup = max(zbup(i,j,k), zbup(im1,j,k), zbup(ip1,j,k), &
                     zbup(i,jm1,k), zbup(i,jp1,k), zbup(i,j,km1), zbup(i,j,kp1))

           zbetup(i,j,k) = (zup - paft(i,j,k)) / (zpos + zrtrn) * zbt
        end do
     end do
  end do

  print *, 'zbetup(5,5,5) = ', zbetup(5,5,5)

end program calc_zbetup
