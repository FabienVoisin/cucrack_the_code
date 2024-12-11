#include "common.cuh"
#include "struct.cuh"
__host__ void copy_to_constant_gpu_memory(unsigned int *hostcodedevice,unsigned int *devicememory,size_t offset);
__host__ void copy_input_to_device(unsigned int *hostdata, unsigned int *devicedata, unsigned int numelements);
__host__ void copy_device_to_output(unsigned int *devicedata, unsigned int *hostdata, unsigned int numelements);
__host__ unsigned int* allocate_device_memory(unsigned int numelements);
__host__ void codecheck(player &player,unsigned int *constcode);
__host__ void get_incorrect_array(player &player,unsigned int *constcode);
__host__ void get_swap_array(player &player,unsigned int *constcode);
__global__ void gpudevicecheckincorrect(unsigned int *devicecode, unsigned int *constcode, unsigned int *devicecheck, unsigned int *incorrectnumber,int numelements);
__device__ void get_key_number_values(unsigned int *devicecheck, int index,unsigned int *incorrectvalue);
__global__ void place_incorrect_swap_values(unsigned int *devicecheck,unsigned int *device_incorrect_array, int numelements);
__global__ void gpudevicecheckswap(unsigned int *devicecode, unsigned int *constcode, unsigned int *deviceswapcheck, unsigned int *incorrectswapnumber,int numelements);

