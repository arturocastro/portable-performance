CC = gcc
CFLAGS = -ggdb -Wall -O0 -fpermissive
#CFLAGS = -ggdb -Wall -O0
#axleman:
ROOT = /usr/local/cuda-5.5/targets/x86_64-linux
# axleman:next is needed for LD_LIBRARY_PATH. Also have lib64.
#LIBROOT = /usr/lib/nvidia
#arndale2:
#ROOT = /scratch/Mali_OpenCL_SDK_v1.1.0
#INCS = -I /mnt/scratch/NVIDIA_GPU_Computing_SDK/OpenCL/common/inc/
INCS = -I$(ROOT)/include -I$(ROOT)/common -I/usr/lib64/nvidia -I.
#LFLAGS = -L$(ROOT)/lib -L$(ROOT)/common -L/usr/lib64/nvidia -lOpenCL -lCommon
LFLAGS = -L$(ROOT)/lib -L$(ROOT)/common -L/usr/lib64/nvidia -lOpenCL
#LFLAGS = -L /mnt/scratch/NVIDIA_GPU_Computing_SDK/OpenCL/common/lib/Linux64 -lOpenCL -lm

shallow: shallow.c shallow.h opencl_common.o wtime.o
	${CC} ${CFLAGS} ${INCS} -o shallow opencl_common.c wtime.c shallow.c ${LFLAGS}
	rm -rf ~/.nv/ComputeCache

opencl_common.o: opencl_common.c opencl_common.h
	${CC} -c ${CFLAGS} ${INCS} opencl_common.c

wtime.o:
	${CC} -c ${CFLAGS} wtime.c

devinfo: devinfo.c
	${CC} devinfo.c -o devinfo -I/usr/lib64/nvidia -I. -L/usr/lib64/nvidia -lOpenCL

clinfo: clInfo.c
	${CC} -ggdb -Wall -O0 -fpermissive clInfo.c -o clinfo -I/usr/lib64/nvidia -I. -L/usr/lib64/nvidia -lOpenCL

clean:
	rm *.o shallow
