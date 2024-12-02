#include <iostream>
#include "gpuutilsfunc.cuh"
#include "testcode.cuh"
#include <stdio.h>
void printcode(player &player){
    
    for (int i =0;i <CODESIZE; i++){
        std::cout<<player.hostcode[i]<<",";
    }
    
    std::cout<<std::endl;
    
}
__host__ void runtestkernel(){
//This function is a test function meant to test whether the constant memory is correctly allocated.
    unsigned int blockspergrid=CODESIZE/THREADSPERBLOCK+1; //define the number
    unsigned int hostresult[CODESIZE];
    unsigned int *deviceresult;
    deviceresult=allocate_device_memory(CODESIZE);
    
    for (int i=0;i<CODESIZE;i++){
        hostresult[i]=0;
    }
    std::cout<<"hello world"<<std::endl;
    testkernel<<<blockspergrid,THREADSPERBLOCK>>>(deviceresult);
    copy_device_to_output(deviceresult,hostresult,CODESIZE);
    for (int i=0;i<CODESIZE;i++){
        std::cout<<hostresult[i]<<",";
    }
    std::cout<<std::endl;

}

__global__ void testkernel(unsigned int *deviceresult){
    // Set up index for the kernel
    int blockId=blockIdx.z*(gridDim.x*gridDim.y)+blockIdx.y*(gridDim.x)+blockIdx.x;
    int index=blockId*(blockDim.x*blockDim.y*blockDim.z)+threadIdx.z*(blockDim.x*blockDim.y)+threadIdx.y*(blockDim.y)+threadIdx.x;
    if (index<CODESIZE){ //The number of threads may exceed the CODESIZE
        //deviceresult[index]=codetocrack1[index]+2;
        deviceresult[index]=2;
    }

}