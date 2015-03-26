/*
 * On axleman, run the 'devinfo' exe in the distribution directory.
 * (The queue_flags arg can be left at 0).
 * This will list the platform and device id information.
 * Use the platform id and device id you wish to exectute on in the
 * call to cl_init(platform id, device id, queue_flags) below.
 * (The queue_flags arg can be left at 0).
 * 
 * NB. The devinfo.c file can be built on any system. See the header
 * for compilation details for axleman.
*/
#define MAIN_FILE

#include "opencl_common.h" // 
#include "shallow.h"       // define M, N, M_LEN, N_LEN
//#include "common.h"

//#include <CL/cl.h>
#include <stdio.h>
#include <math.h>
#include <stdbool.h>
//#include <pthread.h>


// Configuration for Intel Xeon CPUs on Axleman
#define PLATFORM_ID 0
#define DEVICE_ID 0

#define ITMAX   4000
#define L_OUT   true

#define PRINT_ALLOCS true
#define PRINT_RESULTS true
#define PRINT_TIMINGS true

#define MIN(x,y) ((x)>(y)?(y):(x))
#define MAX(x,y) ((x)>(y)?(x):(y))

extern double wtime();

int main(int argc, char **argv) {
 
    // solution arrays
    double u[M_LEN * N_LEN];
    double v[M_LEN * N_LEN];
    double p[M_LEN * N_LEN];

    double unew[M_LEN * N_LEN];
    double vnew[M_LEN * N_LEN];
    double pnew[M_LEN * N_LEN];

    double uold[M_LEN * N_LEN];
    double vold[M_LEN * N_LEN];
    double pold[M_LEN * N_LEN];

    double cu[M_LEN * N_LEN];
    double cv[M_LEN * N_LEN];

    double z[M_LEN * N_LEN];
    double h[M_LEN * N_LEN];

    double psi[M_LEN * N_LEN];

    double dt,tdt,dx,dy,a,alpha,el,pi;
    double tpi,di,dj,pcf;
    double tdts8,tdtsdx,tdtsdy,fsdx,fsdy;

    int ncycle;
    int i, j;

    // timer variables 
    double mfs100,mfs200,mfs300,mfs310;
    double t100,t200,t300;
    double tstart,ctime,tcyc,time,ptime;
    double t100i,t200i,t300i;
    double c1,c2;

    // opencl variables
    cl_int status;

    cl_kernel kernel_init1;
    cl_kernel kernel_init2;
    cl_kernel kernel_init_pc;
    cl_kernel kernel_l100;
    cl_kernel kernel_l100_pc;
    cl_kernel kernel_l200;
    cl_kernel kernel_l200_pc;
    cl_kernel kernel_l300;
    cl_kernel kernel_l300_pc;

    cl_mem buf_u, buf_v, buf_p;
    cl_mem buf_uold, buf_vold, buf_pold;
    cl_mem buf_unew, buf_vnew, buf_pnew;
    cl_mem buf_cu, buf_cv;
    cl_mem buf_z, buf_h, buf_psi;

    size_t global_worksize[2] = {M_LEN, N_LEN};

    int elements = M_LEN * N_LEN;
    int datasize = elements * sizeof(double);
    printf("elements %d\n", elements);
    // ** Initialise vars ** 

    // Note below that two delta t (tdt) is set to dt on the first
    // cycle after which it is reset to dt+dt.
    dt = 90.;
    tdt = dt;

    dx = 100000.;
    dy = 100000.;
    fsdx = 4. / dx;
    fsdy = 4. / dy;

    a = 1000000.;
    alpha = .001;

    el = N * dx;
    pi = 4. * atanf(1.);
    tpi = pi + pi;
    di = tpi / M;
    dj = tpi / N;
    pcf = pi * pi * a * a / (el * el);

    // ** Initialise OpenCL ** 

    // initialise opencl platform / device
    // (see header for usage of cl_init())
    cl_init(PLATFORM_ID, DEVICE_ID, 0);

    // load and build program
    load_program_src("./kernels.cl");
    build_program(0);

    //
    // Create device buffers
    //
    //GDR
    printf("Start of buffer alloc\n");
    //GDR
    buf_u = clCreateBuffer(context, CL_MEM_READ_WRITE, elements*sizeof(cl_double), NULL, &status);
    CL_CHECK(status != CL_SUCCESS);
    buf_v = clCreateBuffer(context, CL_MEM_READ_WRITE, elements*sizeof(cl_double), NULL, &status);
    CL_CHECK(status != CL_SUCCESS);
    buf_p = clCreateBuffer(context, CL_MEM_READ_WRITE, elements*sizeof(cl_double), NULL, &status);
    CL_CHECK(status != CL_SUCCESS);

    buf_uold = clCreateBuffer(context, CL_MEM_READ_WRITE, elements*sizeof(cl_double), NULL, &status);
    CL_CHECK(status != CL_SUCCESS);
    buf_vold = clCreateBuffer(context, CL_MEM_READ_WRITE, elements*sizeof(cl_double), NULL, &status);
    CL_CHECK(status != CL_SUCCESS);
    buf_pold = clCreateBuffer(context, CL_MEM_READ_WRITE, elements*sizeof(cl_double), NULL, &status);
    CL_CHECK(status != CL_SUCCESS);

    buf_unew = clCreateBuffer(context, CL_MEM_READ_WRITE, elements*sizeof(cl_double), NULL, &status);
    CL_CHECK(status != CL_SUCCESS);
    buf_vnew = clCreateBuffer(context, CL_MEM_READ_WRITE, elements*sizeof(cl_double), NULL, &status);
    CL_CHECK(status != CL_SUCCESS);
    buf_pnew = clCreateBuffer(context, CL_MEM_READ_WRITE, elements*sizeof(cl_double), NULL, &status);
    CL_CHECK(status != CL_SUCCESS);

    buf_cu = clCreateBuffer(context, CL_MEM_READ_WRITE, elements*sizeof(cl_double), NULL, &status);
    CL_CHECK(status != CL_SUCCESS);
    buf_cv = clCreateBuffer(context, CL_MEM_READ_WRITE, elements*sizeof(cl_double), NULL, &status);
    CL_CHECK(status != CL_SUCCESS);

    buf_z = clCreateBuffer(context, CL_MEM_READ_WRITE, elements*sizeof(cl_double), NULL, &status);
    CL_CHECK(status != CL_SUCCESS);
    buf_h = clCreateBuffer(context, CL_MEM_READ_WRITE, elements*sizeof(cl_double), NULL, &status);
    CL_CHECK(status != CL_SUCCESS);
    buf_psi = clCreateBuffer(context, CL_MEM_READ_WRITE, elements*sizeof(cl_double), NULL, &status);
    CL_CHECK(status != CL_SUCCESS);
    //GDR
    printf("End of buffer alloc\n");
    //GDR
    // *** Initialise kernels ***
    //GDR
    printf("Start of create kernel init1\n");
    //GDR
    // init1: create kernel
    kernel_init1 = clCreateKernel(program, "init1", &status);
    CL_CHECK(status);
    //GDR
    printf("End of create kernel init1\n");
    //GDR
    //GDR

    //GDR
    printf("Sart of set kernel args\n");
    //GDR
    // init1: set kernel args
    CL_CHECK(clSetKernelArg(kernel_init1, 0, sizeof(double), (void *)&a));
    CL_CHECK(clSetKernelArg(kernel_init1, 1, sizeof(double), (void *)&di));
    CL_CHECK(clSetKernelArg(kernel_init1, 2, sizeof(double), (void *)&dj));
    CL_CHECK(clSetKernelArg(kernel_init1, 3, sizeof(double), (void *)&pcf));
    CL_CHECK(clSetKernelArg(kernel_init1, 4, sizeof(cl_mem), (void *)&buf_p));
    CL_CHECK(clSetKernelArg(kernel_init1, 5, sizeof(cl_mem), (void *)&buf_psi));
    //GDR
    printf("End of set kernel args\n");
    //GDR
    // init2: create kernel
    kernel_init2 = clCreateKernel(program, "init2", &status);
    CL_CHECK(status);

    // init2: set kernel args
    CL_CHECK(clSetKernelArg(kernel_init2, 0, sizeof(double), (void *)&dx));
    CL_CHECK(clSetKernelArg(kernel_init2, 1, sizeof(double), (void *)&dy));
    CL_CHECK(clSetKernelArg(kernel_init2, 2, sizeof(cl_mem), (void *)&buf_u));
    CL_CHECK(clSetKernelArg(kernel_init2, 3, sizeof(cl_mem), (void *)&buf_v));
    CL_CHECK(clSetKernelArg(kernel_init2, 4, sizeof(cl_mem), (void *)&buf_psi));
   //GDR
    printf("Start of creat kernel\n");
    //GDR
    // init_pc: create kernel
    kernel_init_pc = clCreateKernel(program, "init_pc", &status);
    CL_CHECK(status);
   //GDR
    printf("End of creat kernel\n");
    //GDR
    // init_pc: set kernel args
    CL_CHECK(clSetKernelArg(kernel_init_pc, 0, sizeof(cl_mem), (void *)&buf_u));
    CL_CHECK(clSetKernelArg(kernel_init_pc, 1, sizeof(cl_mem), (void *)&buf_v));
    CL_CHECK(clSetKernelArg(kernel_init_pc, 2, sizeof(cl_mem), (void *)&buf_p));
    CL_CHECK(clSetKernelArg(kernel_init_pc, 3, sizeof(cl_mem), (void *)&buf_uold));
    CL_CHECK(clSetKernelArg(kernel_init_pc, 4, sizeof(cl_mem), (void *)&buf_vold));
    CL_CHECK(clSetKernelArg(kernel_init_pc, 5, sizeof(cl_mem), (void *)&buf_pold));

    // l100: create kernel
    kernel_l100 = clCreateKernel(program, "l100", &status);
    CL_CHECK(status);
    //GDR
    printf("Start of set kernel args\n");
    //GDR
    // l100: set kernel args
    CL_CHECK(clSetKernelArg(kernel_l100, 0, sizeof(double), (void *)&fsdx));
    CL_CHECK(clSetKernelArg(kernel_l100, 1, sizeof(double), (void *)&fsdy));
    CL_CHECK(clSetKernelArg(kernel_l100, 2, sizeof(cl_mem), (void *)&buf_u));
    CL_CHECK(clSetKernelArg(kernel_l100, 3, sizeof(cl_mem), (void *)&buf_v));
    CL_CHECK(clSetKernelArg(kernel_l100, 4, sizeof(cl_mem), (void *)&buf_p));
    CL_CHECK(clSetKernelArg(kernel_l100, 5, sizeof(cl_mem), (void *)&buf_cu));
    CL_CHECK(clSetKernelArg(kernel_l100, 6, sizeof(cl_mem), (void *)&buf_cv));
    CL_CHECK(clSetKernelArg(kernel_l100, 7, sizeof(cl_mem), (void *)&buf_z));
    CL_CHECK(clSetKernelArg(kernel_l100, 8, sizeof(cl_mem), (void *)&buf_h));
    //GDR
    printf("End of set kernel args\n");
    //GDR
    // l100_pc: create kernel
    kernel_l100_pc = clCreateKernel(program, "l100_pc", &status);
    CL_CHECK(status);

    // l100: set kernel args
    CL_CHECK(clSetKernelArg(kernel_l100_pc, 0, sizeof(cl_mem), (void *)&buf_cu));
    CL_CHECK(clSetKernelArg(kernel_l100_pc, 1, sizeof(cl_mem), (void *)&buf_cv));
    CL_CHECK(clSetKernelArg(kernel_l100_pc, 2, sizeof(cl_mem), (void *)&buf_z));
    CL_CHECK(clSetKernelArg(kernel_l100_pc, 3, sizeof(cl_mem), (void *)&buf_h));

    // l200: create kernel
    kernel_l200 = clCreateKernel(program, "l200", &status);
    CL_CHECK(status);

    // l200: set kernel args
    CL_CHECK(clSetKernelArg(kernel_l200,  0, sizeof(double), (void *)&tdts8));
    CL_CHECK(clSetKernelArg(kernel_l200,  1, sizeof(double), (void *)&tdtsdx));
    CL_CHECK(clSetKernelArg(kernel_l200,  2, sizeof(double), (void *)&tdtsdy));
    CL_CHECK(clSetKernelArg(kernel_l200,  3, sizeof(cl_mem), (void *)&buf_uold));
    CL_CHECK(clSetKernelArg(kernel_l200,  4, sizeof(cl_mem), (void *)&buf_vold));
    CL_CHECK(clSetKernelArg(kernel_l200,  5, sizeof(cl_mem), (void *)&buf_pold));
    CL_CHECK(clSetKernelArg(kernel_l200,  6, sizeof(cl_mem), (void *)&buf_unew));
    CL_CHECK(clSetKernelArg(kernel_l200,  7, sizeof(cl_mem), (void *)&buf_vnew));
    CL_CHECK(clSetKernelArg(kernel_l200,  8, sizeof(cl_mem), (void *)&buf_pnew));
    CL_CHECK(clSetKernelArg(kernel_l200,  9, sizeof(cl_mem), (void *)&buf_cu));
    CL_CHECK(clSetKernelArg(kernel_l200, 10, sizeof(cl_mem), (void *)&buf_cv));
    CL_CHECK(clSetKernelArg(kernel_l200, 11, sizeof(cl_mem), (void *)&buf_z));
    CL_CHECK(clSetKernelArg(kernel_l200, 12, sizeof(cl_mem), (void *)&buf_h));

    // l200_pc: create kernel
    kernel_l200_pc = clCreateKernel(program, "l200_pc", &status);
    CL_CHECK(status);

    // l200: set kernel args
    CL_CHECK(clSetKernelArg(kernel_l200_pc,  0, sizeof(cl_mem), (void *)&buf_unew));
    CL_CHECK(clSetKernelArg(kernel_l200_pc,  1, sizeof(cl_mem), (void *)&buf_vnew));
    CL_CHECK(clSetKernelArg(kernel_l200_pc,  2, sizeof(cl_mem), (void *)&buf_pnew));

    // l300: create kernel
    kernel_l300 = clCreateKernel(program, "l300", &status);
    CL_CHECK(status);

    // l300: set kernel args
    CL_CHECK(clSetKernelArg(kernel_l300, 0, sizeof(double), (void *)&alpha));
    CL_CHECK(clSetKernelArg(kernel_l300, 1, sizeof(cl_mem), (void *)&buf_u));
    CL_CHECK(clSetKernelArg(kernel_l300, 2, sizeof(cl_mem), (void *)&buf_v));
    CL_CHECK(clSetKernelArg(kernel_l300, 3, sizeof(cl_mem), (void *)&buf_p));
    CL_CHECK(clSetKernelArg(kernel_l300, 4, sizeof(cl_mem), (void *)&buf_uold));
    CL_CHECK(clSetKernelArg(kernel_l300, 5, sizeof(cl_mem), (void *)&buf_vold));
    CL_CHECK(clSetKernelArg(kernel_l300, 6, sizeof(cl_mem), (void *)&buf_pold));
    CL_CHECK(clSetKernelArg(kernel_l300, 7, sizeof(cl_mem), (void *)&buf_unew));
    CL_CHECK(clSetKernelArg(kernel_l300, 8, sizeof(cl_mem), (void *)&buf_vnew));
    CL_CHECK(clSetKernelArg(kernel_l300, 9, sizeof(cl_mem), (void *)&buf_pnew));

    // l300_pc: create kernel
    kernel_l300_pc = clCreateKernel(program, "l300_pc", &status);
    CL_CHECK(status);

    // l300_pc: set kernel args
    CL_CHECK(clSetKernelArg(kernel_l300_pc, 0, sizeof(cl_mem), (void *)&buf_u));
    CL_CHECK(clSetKernelArg(kernel_l300_pc, 1, sizeof(cl_mem), (void *)&buf_v));
    CL_CHECK(clSetKernelArg(kernel_l300_pc, 2, sizeof(cl_mem), (void *)&buf_p));
    CL_CHECK(clSetKernelArg(kernel_l300_pc, 3, sizeof(cl_mem), (void *)&buf_uold));
    CL_CHECK(clSetKernelArg(kernel_l300_pc, 4, sizeof(cl_mem), (void *)&buf_vold));
    CL_CHECK(clSetKernelArg(kernel_l300_pc, 5, sizeof(cl_mem), (void *)&buf_pold));
    CL_CHECK(clSetKernelArg(kernel_l300_pc, 6, sizeof(cl_mem), (void *)&buf_unew));
    CL_CHECK(clSetKernelArg(kernel_l300_pc, 7, sizeof(cl_mem), (void *)&buf_vnew));
    CL_CHECK(clSetKernelArg(kernel_l300_pc, 8, sizeof(cl_mem), (void *)&buf_pnew));

    // *** Initialise grids ***

    // Enqueue kernel for execution
    CL_CHECK(clEnqueueNDRangeKernel(cmd_queue, kernel_init1, 2, NULL, global_worksize, NULL, 0, NULL, NULL));
    CL_CHECK(clFinish(cmd_queue));
    CL_CHECK(clEnqueueNDRangeKernel(cmd_queue, kernel_init2, 2, NULL, global_worksize, NULL, 0, NULL, NULL));
    CL_CHECK(clEnqueueNDRangeKernel(cmd_queue, kernel_init_pc, 2, NULL, global_worksize, NULL, 0, NULL, NULL));

    // Start timer
    tstart = wtime();
    time = 0.0;
    t100 = 0.0;
    t200 = 0.0;
    t300 = 0.0;

    // ** Start of time loop ** 
    for (ncycle=1; ncycle <= ITMAX; ncycle++) {

        // l100: Compute capital u, capital v, z and h
        CL_CHECK(clEnqueueNDRangeKernel(cmd_queue, kernel_l100, 2, NULL, global_worksize, NULL, 0, NULL, NULL));

        // Periodic continuation
        CL_CHECK(clEnqueueNDRangeKernel(cmd_queue, kernel_l100_pc, 2, NULL, global_worksize, NULL, 0, NULL, NULL));

        // Compute new values u,v and p
        tdts8 = tdt / 8.0;
        tdtsdx = tdt / dx;
        tdtsdy = tdt / dy;

        // l200
        CL_CHECK(clSetKernelArg(kernel_l200,  0, sizeof(double), (void *)&tdts8));
        CL_CHECK(clSetKernelArg(kernel_l200,  1, sizeof(double), (void *)&tdtsdx));
        CL_CHECK(clSetKernelArg(kernel_l200,  2, sizeof(double), (void *)&tdtsdy));

        CL_CHECK(clEnqueueNDRangeKernel(cmd_queue, kernel_l200, 2, NULL, global_worksize, NULL, 0, NULL, NULL));

        // Periodic continuation
        CL_CHECK(clEnqueueNDRangeKernel(cmd_queue, kernel_l200_pc, 2, NULL, global_worksize, NULL, 0, NULL, NULL));
        time = time + dt;

        // Time smoothing and update for next cycle
        if ( ncycle > 1 ) {
            // l300
            CL_CHECK(clEnqueueNDRangeKernel(cmd_queue, kernel_l300, 2, NULL, global_worksize, NULL, 0, NULL, NULL));
        } else {
            tdt = tdt + tdt;
            CL_CHECK(clEnqueueNDRangeKernel(cmd_queue, kernel_l300_pc, 2, NULL, global_worksize, NULL, 0, NULL, NULL));
        }
    }
    // ** End of time loop ** 

    // Read output buffer back to host. Again, blocking reads will force sync to host.
    CL_CHECK(clEnqueueReadBuffer(cmd_queue, buf_p, CL_TRUE, 0, datasize, p, 0, NULL, NULL));
    CL_CHECK(clEnqueueReadBuffer(cmd_queue, buf_u, CL_TRUE, 0, datasize, u, 0, NULL, NULL));
    CL_CHECK(clEnqueueReadBuffer(cmd_queue, buf_v, CL_TRUE, 0, datasize, v, 0, NULL, NULL));

    // Output p, u, v fields and run times.
    if (L_OUT) {
        ptime = time / 3600.;
        t100 = t100 / 1000000000;
        t200 = t200 / 1000000000;
        t300 = t300 / 1000000000;
        printf(" cycle number %d model time in hours %f\n", ITMAX, ptime);
        printf(" diagonal elements of p\n");
        for (i=0, j=0; j < N; j++) {
            printf("%f ", p[j + i]);
            i += M_LEN;
        }
        printf("\n diagonal elements of u\n");
        for (i=0, j=0; j < N; j++) {
            printf("%f ",u[j + i]);
            i += M_LEN;
        }
        printf("\n diagonal elements of v\n");
        for (i=0, j=0; j < N; j++) {
            printf("%f ",v[j + i]);
            i += M_LEN;
        }
        printf("\n");
        mfs100 = 0.0;
        mfs200 = 0.0;
        mfs300 = 0.0;

        // gdr t100 etc. now an accumulation of all l100 time
        if ( t100 > 0 ) { mfs100 = ITMAX * 24. * M * N / t100 / 1000000; }
        if ( t200 > 0 ) { mfs200 = ITMAX * 26. * M * N / t200 / 1000000; }
        if ( t300 > 0 ) { mfs300 = ITMAX * 15. * M * N / t300 / 1000000; }

        c2 = wtime(); // <---- FIXME why here and not at the end of the loop?
        ctime = c2 - tstart;
        tcyc = ctime / ITMAX;

        printf(" cycle number %d total computer time %f time per cycle %f\n", ITMAX, ctime, tcyc);
        printf(" time and megaflops for loop 100 %.6f %.6f\n", t100, mfs100);
        printf(" time and megaflops for loop 200 %.6f %.6f\n", t200, mfs200);
        printf(" time and megaflops for loop 300 %.6f %.6f\n", t300, mfs300);
    }

    //
    // Release resources
    //
    clReleaseKernel(kernel_init1);
    clReleaseKernel(kernel_init2);
    clReleaseKernel(kernel_init_pc);
    clReleaseKernel(kernel_l100);
    clReleaseKernel(kernel_l100_pc);
    clReleaseKernel(kernel_l200);
    clReleaseKernel(kernel_l200_pc);
    clReleaseKernel(kernel_l300);
    clReleaseKernel(kernel_l300_pc);

    clReleaseMemObject(buf_u);
    clReleaseMemObject(buf_v);
    clReleaseMemObject(buf_p);
    clReleaseMemObject(buf_uold);
    clReleaseMemObject(buf_vold);
    clReleaseMemObject(buf_pold);
    clReleaseMemObject(buf_unew);
    clReleaseMemObject(buf_vnew);
    clReleaseMemObject(buf_pnew);
    clReleaseMemObject(buf_cu);
    clReleaseMemObject(buf_cv);
    clReleaseMemObject(buf_z);
    clReleaseMemObject(buf_h);
    clReleaseMemObject(buf_psi);

    cl_free();

    return EXIT_SUCCESS;
}

