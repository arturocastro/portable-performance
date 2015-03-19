#ifndef OPENCL_COMMON_H
#define OPENCL_COMMON_H

#include <stdlib.h>
#include <stdio.h>

#ifdef __APPLE__
    #include <OpenCL/opencl.h>
#else
    #include <CL/cl.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

void cl_init(unsigned int platform_id, unsigned int dev_id, cl_int queue_flags); 
void dev_init(unsigned int dev_id, cl_int queue_flags);
void load_program_src(char *program_fname);
void build_program(unsigned int dev_id);
void cl_free();
char *get_error_name(cl_int cl_error);

#define HANDLE_ERROR(msg) \
    do { perror(msg); exit(EXIT_FAILURE); } while(0)

#define CL_CHECK(_expr)                                                       \
   do {                                                                       \
     cl_int _err = _expr;                                                     \
     if (_err == CL_SUCCESS)                                                  \
       break;                                                                 \
     fprintf(stderr, "OpenCL Error: '%s' returned %s (%d)\n", #_expr,         \
             get_error_name(_err), (int)_err);                                \
     abort();                                                                 \
   } while (0)

#ifdef __cplusplus
}
#endif

#endif

#ifdef MAIN_FILE
#define EXTERN
#else
#define EXTERN extern
#endif

EXTERN unsigned int platform_id;
EXTERN unsigned int dev_id;
EXTERN cl_uint num_platforms;
EXTERN cl_platform_id *platforms;
EXTERN cl_context context;
EXTERN cl_uint num_devices;
EXTERN cl_device_id *devices;
EXTERN char *program_src;
EXTERN cl_device_id id;
EXTERN cl_command_queue cmd_queue;
EXTERN cl_program program;


