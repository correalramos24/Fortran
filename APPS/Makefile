
FC = gfortran
FFLAGS = -Wall -Wextra -Wconversion -O1


all: saxpy.exe


saxpy.exe: SAXPY/main.F90
	$(FC) $(FFLAGS) -o $@ $^