#include "struct.cuh"
void printcode(player &player);
__host__ void runtestkernel(unsigned int *playercode);
__global__ void testkernel(unsigned int *deviceresult);
