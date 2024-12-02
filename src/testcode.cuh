#include "struct.cuh"
void printcode(player &player);
__host__ void runtestkernel();
__global__ void testkernel(unsigned int *deviceresult);