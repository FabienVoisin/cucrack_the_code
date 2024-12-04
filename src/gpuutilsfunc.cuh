#include "common.cuh"
__host__ void copy_to_constant_gpu_memory(unsigned int *hostcodedevice,unsigned int *devicememory,size_t offset);
__host__ void copy_input_to_device(unsigned int *hostdata, unsigned int *devicedata, unsigned int numelements);
__host__ void copy_device_to_output(unsigned int *devicedata, unsigned int *hostdata, unsigned int numelements);
__host__ unsigned int* allocate_device_memory(unsigned int numelements);