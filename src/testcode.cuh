#include "struct.cuh"
void printcode(player &player);
__host__ void runtestkernel(unsigned int *playercode1, unsigned int *playercode2);
__global__ void testkernel1(unsigned int *deviceresult);
__global__ void testkernel2(unsigned int *deviceresult);
