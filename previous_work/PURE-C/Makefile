CC = gcc
CFLAGS = -Wall -std=c99
DBG = -ggdb -O0
O3 = -O3
O2 = -O2
OS = -Os

LFLAGS = -lm -fopenmp

OPT = ${O2}

shallow_base: shallow_base.c wtime.o
	${CC} ${CFLAGS} ${OPT} ${INCS} -o shallow_base wtime.c shallow_base.c ${LFLAGS}

wtime.o:
	${CC} -c ${CFLAGS} ${0PT} wtime.c

clean:
	rm *.o shallow_base
