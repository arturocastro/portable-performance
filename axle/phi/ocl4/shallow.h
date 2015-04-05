// GDR - had to put these explicitly in kernels.cl
// it seems include files in .cl files dpn't work on arndale2
#ifndef SHALLOW_H
#define SHALLOW_H

#define M 64
#define N 64
#define M_LEN (M+1)
#define N_LEN (N+1)

#define M_BLOCK_LEN 256
#define N_BLOCK_LEN 1

#endif


