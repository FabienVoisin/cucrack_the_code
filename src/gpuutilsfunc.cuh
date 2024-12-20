#include "common.cuh"
#include "struct.cuh"
__global__ void testval(unsigned int *constantmemory1,unsigned int *constantmemory2, unsigned int *devicevalue);
__host__ void copy_to_constant_gpu_memory(player &player,int playernumber);
template <typename T> __host__ void copy_input_to_device(T *hostdata, T *devicedata, T numelements);
template <typename T> __host__ void copy_device_to_output(T *devicedata,T *hostdata, T numelements);
__host__ unsigned int* allocate_device_memory(unsigned int numelements);
__host__ void codecheck(player &player);
__host__ void get_incorrect_array(player &player);
__host__ void get_swap_array(player &player);
__global__ void gpudevicecheckincorrect(unsigned int *devicecode, unsigned int *constcode, unsigned int *devicecheck, unsigned int *incorrectnumber,int numelements);
__device__ void get_key_number_values(unsigned int *devicecheck, int index,unsigned int *incorrectvalue);
__global__ void place_incorrect_swap_values(unsigned int *devicecheck,unsigned int *device_incorrect_array, unsigned int *numelements, int numthreads);
__global__ void gpudevicecheckswap(unsigned int *devicecode, unsigned int *constcode, unsigned int *deviceswapcheck, unsigned int *incorrectswapnumber,int numelements);
__host__ void getcodeattempt(player &player);
