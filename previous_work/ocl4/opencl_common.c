#include "opencl_common.h"
#include <string.h>

/**
 * Initialise platform / device. We assume we already know which resources we
 * wish to use.
 */
void cl_init(unsigned int platform_id, unsigned int dev_id, cl_int queue_flags) {

    cl_int status;

    //
    // check platform
    // 
    CL_CHECK(clGetPlatformIDs(0, NULL, &num_platforms));

    if((platforms = (cl_platform_id *)malloc(num_platforms * sizeof(cl_platform_id))) == NULL) {
        HANDLE_ERROR("malloc");
    }

    CL_CHECK(clGetPlatformIDs(num_platforms, platforms, NULL));

    //
    // check device
    //
    CL_CHECK(clGetDeviceIDs(platforms[platform_id], CL_DEVICE_TYPE_ALL, 0, NULL, &num_devices));

    if((devices = (cl_device_id *)malloc(num_devices * sizeof(cl_device_id))) == NULL) {
        HANDLE_ERROR("malloc");
    }

    CL_CHECK(clGetDeviceIDs(platforms[platform_id], CL_DEVICE_TYPE_ALL, num_devices, devices, NULL));

    //
    // create context
    //
    context = clCreateContext(NULL, num_devices, devices, NULL, NULL, &status);
    CL_CHECK(status != CL_SUCCESS);

    //
    // initialise device
    //
    dev_init(dev_id, queue_flags);
}

/**
 * Initialise a device
 *
 */
void dev_init(unsigned int dev_id, cl_int queue_flags) {

    cl_int status;

    //
    // Create command queue
    //
    cmd_queue = clCreateCommandQueue(context, devices[dev_id], queue_flags, &status);

    CL_CHECK(status != CL_SUCCESS);
}

/**
 * Load program source from file.
 */
void load_program_src(char *program_fname) {

    FILE *fp;
    unsigned int src_size;

    if(!(fp = fopen(program_fname, "r"))) {
        HANDLE_ERROR("fopen");
    }

    // malloc program_src
    fseek(fp, 0, SEEK_END);
    src_size = ftell(fp);
    program_src = malloc(src_size * sizeof(char));

    // read into program_src
    fseek(fp, 0, SEEK_SET);
    if(fread(program_src, sizeof(char), src_size, fp) != src_size) {
        HANDLE_ERROR("fread");
    }

    fclose(fp);
}

/**
 * Build program on device
 */
void build_program(unsigned int dev_id) {

    cl_int status;
    char *build_log;
    size_t log_size;

    char str_size[8 * sizeof(int) + 1];

    sprintf(str_size, "%d", M);

    char flags[255] = "-w -DM=";

    strcat(flags, str_size);

    program = clCreateProgramWithSource(context, 1, (const char **)&program_src, NULL, &status);
    CL_CHECK(status);

    //status = clBuildProgram(program, num_devices, devices, "-w -cl-nv-verbose", NULL, NULL);
    status = clBuildProgram(program, num_devices, devices, flags, NULL, NULL);

    if(status != CL_SUCCESS) {
        printf("Compilation failed:\n\n");
    }

    CL_CHECK(clGetProgramBuildInfo(program, devices[dev_id], CL_PROGRAM_BUILD_LOG, 0, NULL, &log_size));
    build_log = malloc(log_size + 1);
    CL_CHECK(clGetProgramBuildInfo(program, devices[dev_id], CL_PROGRAM_BUILD_LOG, log_size, build_log, NULL));
    build_log[log_size] = '\0';
    //GDR
    printf("GDR at build log print!\n");
    printf("%s\n\n", build_log);
}

void cl_free() {

    // opencl stuff
    clReleaseContext(context);
    clReleaseProgram(program);
    clReleaseCommandQueue(cmd_queue);

    // malloc stuff
    free(devices);
    free(platforms);
    free(program_src);
}

/**
 * Originally included in John the Ripper jumbo patch by various authors.
 */
char *get_error_name(cl_int cl_error) {
	static char *err_1[] =
	    { "CL_SUCCESS", "CL_DEVICE_NOT_FOUND", "CL_DEVICE_NOT_AVAILABLE",
		"CL_COMPILER_NOT_AVAILABLE",
		"CL_MEM_OBJECT_ALLOCATION_FAILURE", "CL_OUT_OF_RESOURCES",
		"CL_OUT_OF_HOST_MEMORY",
		"CL_PROFILING_INFO_NOT_AVAILABLE", "CL_MEM_COPY_OVERLAP",
		"CL_IMAGE_FORMAT_MISMATCH",
		"CL_IMAGE_FORMAT_NOT_SUPPORTED", "CL_BUILD_PROGRAM_FAILURE",
		"CL_MAP_FAILURE"
	};
	static char *err_invalid[] = {
		"CL_INVALID_VALUE", "CL_INVALID_DEVICE_TYPE",
		"CL_INVALID_PLATFORM", "CL_INVALID_DEVICE",
		"CL_INVALID_CONTEXT", "CL_INVALID_QUEUE_PROPERTIES",
		"CL_INVALID_COMMAND_QUEUE", "CL_INVALID_HOST_PTR",
		"CL_INVALID_MEM_OBJECT", "CL_INVALID_IMAGE_FORMAT_DESCRIPTOR",
		"CL_INVALID_IMAGE_SIZE", "CL_INVALID_SAMPLER",
		"CL_INVALID_BINARY", "CL_INVALID_BUILD_OPTIONS",
		"CL_INVALID_PROGRAM", "CL_INVALID_PROGRAM_EXECUTABLE",
		"CL_INVALID_KERNEL_NAME", "CL_INVALID_KERNEL_DEFINITION",
		"CL_INVALID_KERNEL", "CL_INVALID_ARG_INDEX",
		"CL_INVALID_ARG_VALUE", "CL_INVALID_ARG_SIZE",
		"CL_INVALID_KERNEL_ARGS", "CL_INVALID_WORK_DIMENSION",
		"CL_INVALID_WORK_GROUP_SIZE", "CL_INVALID_WORK_ITEM_SIZE",
		"CL_INVALID_GLOBAL_OFFSET", "CL_INVALID_EVENT_WAIT_LIST",
		"CL_INVALID_EVENT", "CL_INVALID_OPERATION",
		"CL_INVALID_GL_OBJECT", "CL_INVALID_BUFFER_SIZE",
		"CL_INVALID_MIP_LEVEL", "CL_INVALID_GLOBAL_WORK_SIZE"
	};

	if (cl_error <= 0 && cl_error >= -12) {
		cl_error = -cl_error;
		return err_1[cl_error];
	}
	if (cl_error <= -30 && cl_error >= -63) {
		cl_error = -cl_error;
		return err_invalid[cl_error - 30];
	}

	return "UNKNOWN ERROR";
}

