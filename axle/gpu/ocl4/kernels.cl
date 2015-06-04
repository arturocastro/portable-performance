#ifndef M
    #include "shallow.h"
#else
    #define N M
    #define M_LEN (M+1)
    #define N_LEN (N+1)
#endif

#pragma OPENCL EXTENSION cl_khr_fp64: enable

__kernel void init1(double a, double di, double dj, double pcf,
    __global double *p,  __global double *psi) 
{
    int x = get_global_id(0);
    int y = get_global_id(1);

    psi[y*M_LEN + x] = a * sin((y + 0.5) * di) * sin((x + 0.5) * dj);
    p[y*M_LEN + x] = pcf * (cos(2.0 * y * di) + cos(2.0 * x * dj)) + 50000.0;
}

__kernel void init2(double dx, double dy,
    __global double *u,  __global double *v, __global double *psi) 
{
    int x = get_global_id(0);
    int y = get_global_id(1);

    if(x < N && y < M) { // FIXME Any better way? 
      u[(y + 1)*M_LEN + x] = -(psi[(y + 1)*M_LEN + x + 1] - psi[(y + 1)*M_LEN + x]) / dy;
      v[y*M_LEN + x + 1] = (psi[(y + 1)*M_LEN + x + 1] - psi[y*M_LEN + x + 1]) / dx;
    }
}

__kernel void init_pc( __global double *u,  __global double *v,  __global double *p,
                       __global double *uold,  __global double *vold,  __global double *pold) 
{

    int x = get_global_id(0);
    int y = get_global_id(1);

    if(x < N) { // FIXME
        u[(0)*M_LEN + (x)] = u[(M)*M_LEN + (x)];
        v[(M)*M_LEN + (x + 1)] = v[(0)*M_LEN + (x + 1)];
    }

    if(y < M) { // FIXME
        u[(y + 1)*M_LEN + (N)] = u[(y + 1)*M_LEN + (0)];
        v[(y)*M_LEN + (0)] = v[(y)*M_LEN + (N)];
    }

    u[(0)*M_LEN + (N)] = u[(M)*M_LEN + (0)];
    v[(M)*M_LEN + (0)] = v[(0)*M_LEN + (N)];

    uold[(y)*M_LEN + (x)] = u[(y)*M_LEN + (x)];
    vold[(y)*M_LEN + (x)] = v[(y)*M_LEN + (x)];
    pold[(y)*M_LEN + (x)] = p[(y)*M_LEN + (x)];
}

__kernel void l100(double fsdx, double fsdy, 
     __global double *u,  __global double *v,  __global double *p,
     __global double *cu,  __global double *cv,  __global double *z,  __global double *h) 
{
    int x = get_global_id(0);
    int y = get_global_id(1);

    if(x < N && y < M) { // FIXME
        cu[(y + 1)*M_LEN + (x)] = .5 * (p[(y + 1)*M_LEN + (x)] + p[(y)*M_LEN + (x)]) * u[(y + 1)*M_LEN + (x)];
        cv[(y)*M_LEN + (x + 1)] = .5 * (p[(y)*M_LEN + (x + 1)] + p[(y)*M_LEN + (x)]) * v[(y)*M_LEN + (x + 1)];
        z[(y + 1)*M_LEN + (x + 1)] = (fsdx * (v[(y + 1)*M_LEN + (x + 1)] - v[(y)*M_LEN + (x + 1)]) - fsdy * (u[(y + 1)*M_LEN + (x + 1)] - u[(y + 1)*M_LEN + (x)])) / (p[(y)*M_LEN + (x)] + p[(y + 1)*M_LEN + (x)] + p[(y + 1)*M_LEN + (x + 1)] + p[(y)*M_LEN + (x + 1)]);
        h[(y)*M_LEN + (x)] = p[(y)*M_LEN + (x)] + .25 * (u[(y + 1)*M_LEN + (x)] * u[(y + 1)*M_LEN + (x)] + u[(y)*M_LEN + (x)] * u[(y)*M_LEN + (x)] + v[(y)*M_LEN + (x + 1)] * v[(y)*M_LEN + (x + 1)] + v[(y)*M_LEN + (x)] * v[(y)*M_LEN + (x)]);
    }
}

__kernel void l100_pc( __global double *cu,  __global double *cv, 
     __global double *z,  __global double *h) 
{
    int x = get_global_id(0);
    int y = get_global_id(1);

    cu[(0)*M_LEN + (N)] = cu[(M)*M_LEN + (0)];
    cv[(M)*M_LEN + (0)] = cv[(0)*M_LEN + (N)];
    z[(0)*M_LEN + (0)] = z[(M)*M_LEN + (N)];
    h[(M)*M_LEN + (N)] = h[(0)*M_LEN + (0)];

    if(x < N) { // FIXME
        cu[(0)*M_LEN + (x)] = cu[(M)*M_LEN + (x)];
        cv[(M)*M_LEN + (x + 1)] = cv[(0)*M_LEN + (x + 1)];
        z[(0)*M_LEN + (x + 1)] = z[(M)*M_LEN + (x + 1)];
        h[(M)*M_LEN + (x)] = h[(0)*M_LEN + (x)];
    }

    if(y < M) { // FIXME
        cu[(y + 1)*M_LEN + (N)] = cu[(y + 1)*M_LEN + (0)];
        cv[(y)*M_LEN + (0)] = cv[(y)*M_LEN + (N)];
        z[(y + 1)*M_LEN + (0)] = z[(y + 1)*M_LEN + (N)];
        h[(y)*M_LEN + (N)] = h[(y)*M_LEN + (0)];
    }
}

__kernel void l200(double tdts8, double tdtsdx, double tdtsdy,
     __global double *uold,  __global double *vold,  __global double *pold,
     __global double *unew,  __global double *vnew,  __global double *pnew,
     __global double *cu,  __global double *cv,  __global double *z,  __global double *h)
{
    int x = get_global_id(0);
    int y = get_global_id(1);

    if(y < M && x < N) { // FIXME
        unew[(y + 1)*M_LEN + (x)] = uold[(y + 1)*M_LEN + (x)] + tdts8 * (z[(y + 1)*M_LEN + (x + 1)] + z[(y + 1)*M_LEN + (x)]) * (cv[(y + 1)*M_LEN + (x + 1)] + cv[(y)*M_LEN + (x + 1)] + cv[(y)*M_LEN + (x)] + cv[(y + 1)*M_LEN + (x)]) - tdtsdx * (h[(y + 1)*M_LEN + (x)] - h[(y)*M_LEN + (x)]);
        vnew[(y)*M_LEN + (x + 1)] = vold[(y)*M_LEN + (x + 1)] - tdts8 * (z[(y + 1)*M_LEN + (x + 1)] + z[(y)*M_LEN + (x + 1)]) * (cu[(y + 1)*M_LEN + (x + 1)] + cu[(y)*M_LEN + (x + 1)] + cu[(y)*M_LEN + (x)] + cu[(y + 1)*M_LEN + (x)]) - tdtsdy * (h[(y)*M_LEN + (x + 1)] - h[(y)*M_LEN + (x)]);
        pnew[(y)*M_LEN + (x)] = pold[(y)*M_LEN + (x)] - tdtsdx * (cu[(y + 1)*M_LEN + (x)] - cu[(y)*M_LEN + (x)]) - tdtsdy * (cv[(y)*M_LEN + (x + 1)] - cv[(y)*M_LEN + (x)]); 
    }
}

__kernel void l200_pc( __global double *unew,  __global double *vnew, 
     __global double *pnew)
{
    int x = get_global_id(0);
    int y = get_global_id(1);

    if(x < N) { // FIXME
        unew[(0)*M_LEN + (x)] = unew[(M)*M_LEN + (x)];
        vnew[(M)*M_LEN + (x + 1)] = vnew[(0)*M_LEN + (x + 1)];
        pnew[(M)*M_LEN + (x)] = pnew[(0)*M_LEN + (x)];
    }

    if(y < M) { // FIXME
        unew[(y + 1)*M_LEN + (N)] = unew[(y + 1)*M_LEN + (0)];
        vnew[(y)*M_LEN + (0)] = vnew[(y)*M_LEN + (N)];
        pnew[(y)*M_LEN + (N)] = pnew[(y)*M_LEN + (0)];
    }

    unew[(0)*M_LEN + (N)] = unew[(M)*M_LEN + (0)];
    vnew[(M)*M_LEN + (0)] = vnew[(0)*M_LEN + (N)];
    pnew[(M)*M_LEN + (N)] = pnew[(0)*M_LEN + (0)];
}

__kernel void l300(double alpha,  __global double *u,  __global double *v,  __global double *p,
     __global double *uold,  __global double *vold,  __global double *pold,
     __global double *unew,  __global double *vnew,  __global double *pnew) 
{
    int x = get_global_id(0);
    int y = get_global_id(1);

    uold[(y)*M_LEN + (x)] = u[(y)*M_LEN + (x)] + alpha * (unew[(y)*M_LEN + (x)] - 2. * u[(y)*M_LEN + (x)] + uold[(y)*M_LEN + (x)]);
    vold[(y)*M_LEN + (x)] = v[(y)*M_LEN + (x)] + alpha * (vnew[(y)*M_LEN + (x)] - 2. * v[(y)*M_LEN + (x)] + vold[(y)*M_LEN + (x)]);
    pold[(y)*M_LEN + (x)] = p[(y)*M_LEN + (x)] + alpha * (pnew[(y)*M_LEN + (x)] - 2. * p[(y)*M_LEN + (x)] + pold[(y)*M_LEN + (x)]);

    u[(y)*M_LEN + (x)] = unew[(y)*M_LEN + (x)];
    v[(y)*M_LEN + (x)] = vnew[(y)*M_LEN + (x)];
    p[(y)*M_LEN + (x)] = pnew[(y)*M_LEN + (x)];
}

__kernel void l300_pc(__global double *u,  __global double *v,  __global double *p,
     __global double *uold,  __global double *vold,  __global double *pold,
     __global double *unew,  __global double *vnew,  __global double *pnew)
{

    int x = get_global_id(0);
    int y = get_global_id(1);

    uold[(y)*M_LEN + (x)] = u[(y)*M_LEN + (x)];
    vold[(y)*M_LEN + (x)] = v[(y)*M_LEN + (x)];
    pold[(y)*M_LEN + (x)] = p[(y)*M_LEN + (x)];

    u[(y)*M_LEN + (x)] = unew[(y)*M_LEN + (x)];
    v[(y)*M_LEN + (x)] = vnew[(y)*M_LEN + (x)];
    p[(y)*M_LEN + (x)] = pnew[(y)*M_LEN + (x)];
}
 
/* vim: set ft=opencl: */
