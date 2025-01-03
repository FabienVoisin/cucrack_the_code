#include "common.cuh"
#include "struct.cuh"
__global__ void testval(unsigned int *constantmemory1,unsigned int *constantmemory2, unsigned int *devicevalue);
__host__ void copy_to_constant_gpu_memory(player &player,int playernumber);
template <typename T> __host__ void copy_input_to_device(T *hostdata, T *devicedata, T numelements);
template <typename T> __host__ void copy_device_to_output(T *devicedata,T *hostdata, T numelements);
template <typename T> __host__ T* allocate_device_memory(unsigned int numelements);
__global__ void printdevicearray(unsigned int *array,unsigned int number);
__host__ void codecheck(player &player);
__host__ void get_incorrect_swap_array(player &player);
__host__ void get_swap_array(player &player);
__global__ void gpudevicecheckswapincorrect(unsigned int *devicecode, unsigned int *constcode, int *incorrectcheck, int *swapcheck, unsigned int *incorrectnumber,unsigned int *swapnumber,int numelements);
inline __device__ void gpucheckincorrect(int index, unsigned int *devicecode, unsigned int *constcode, int *incorrectcheck);
__device__ void gpucheckswap(int index, unsigned int *devicecode, unsigned int *constcode, int *swapcheck);
inline __device__ void get_key_number_values_add(int arrayvalue, unsigned int *atomicvalue);
inline __device__ void reduceincorrectonswap(int index, int *incorrectcheck, int *swapcheck);
__global__ void place_incorrect_swap_values(int *devicecheck,unsigned int *device_incorrect_swap_array, unsigned int *device_incorrect_swap_indices, unsigned int *device_incorrect_swap_number,unsigned int numelements);
__host__ void getcodeattempt(player &player);
