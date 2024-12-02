#include <findgpu.h>
#include <common.cuh>

int findGPU(player &player){
    int currentchosendevicenumber=-1;
    int ndevices; // number of GPU devices 
    cudaGetDeviceCount(&ndevices);
    for (int i; i<ndevices; i++){
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop);
    cudaSetDevice(i);
    }
    /*Check whether the GPU has already been taken*/


    
}