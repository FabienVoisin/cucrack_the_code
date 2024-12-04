/*This file provides all the information data into constant, pinned memory and GPU memory*/
#include <iostream>
#include "common.cuh"
__constant__  unsigned int codetocrack1[CODESIZE]; //2 is for 2 players
__constant__  unsigned int codetocrack2[CODESIZE];

__host__ void copy_to_constant_gpu_memory(unsigned int *hostcodedevice,unsigned int *devicememory,size_t offset){
    /* a reminder that the constant memory is read only and 64kB wide.
     we may need to make sure whether we should set a function to make sure the total 
     codesize does not exceed this number for performance purposes */
     size_t size=CODESIZE*sizeof(unsigned int);
     cudaMemcpyToSymbol((void**)&devicememory,(void**)&hostcodedevice,size,0,cudaMemcpyHostToDevice);
    //We must make sure that if we end up with one GPU only, the offset gets propagated
}

__host__ void copy_input_to_device(unsigned int *hostdata, unsigned int *devicedata, unsigned int numelements){
    cudaError_t error;
    size_t size=numelements*sizeof(unsigned int);
    error=cudaMemcpy(devicedata,hostdata,size,cudaMemcpyHostToDevice);

}

__host__ void copy_device_to_output(unsigned int *devicedata, unsigned int *hostdata, unsigned int numelements){
    cudaError_t error;
    size_t size=numelements*sizeof(unsigned int);
    error=cudaMemcpy(hostdata,devicedata,size,cudaMemcpyDeviceToHost);
}

__host__ unsigned int* allocate_device_memory(unsigned int numelements){
    cudaError_t error;
    unsigned int *devicedata;
    size_t size=numelements*sizeof(unsigned int);
    error=cudaMalloc((void**)&devicedata,size);

    return devicedata;
}



