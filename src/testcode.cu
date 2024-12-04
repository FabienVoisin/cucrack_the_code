#include <iostream>
#include "gpuutilsfunc.cuh"
#include "testcode.cuh"
#include <stdio.h>

__constant__  unsigned int codetocrack1[CODESIZE]; //2 is for 2 players
__constant__  unsigned int codetocrack2[CODESIZE];

void printcode(player &player){
    
    for (int i =0;i <CODESIZE; i++){
        std::cout<<player.hostcode[i]<<",";
    }
    
    std::cout<<std::endl;
    
}
__host__ void runtestkernel(unsigned int *playercode1,unsigned int *playercode2){
//This function is a test function meant to test whether the constant memory is correctly allocated.
    unsigned int blockspergrid=CODESIZE/THREADSPERBLOCK+1; //define the number
    unsigned int hostresult[CODESIZE];
    unsigned int *deviceresult;
    deviceresult=allocate_device_memory(CODESIZE);
    size_t size=CODESIZE*sizeof(unsigned int);
    cudaError_t err=cudaMemcpyToSymbol(codetocrack1,playercode1,size);
    err=cudaMemcpyToSymbol(codetocrack2,playercode2,size);
    //std::cout<<"hello world"<<std::endl;
    testkernel1<<<blockspergrid,THREADSPERBLOCK>>>(deviceresult);
    copy_device_to_output(deviceresult,hostresult,CODESIZE);
    for (int i=0;i<CODESIZE;i++){
        std::cout<<hostresult[i]<<","<<playercode1[i]<<std::endl;
    }
    std::cout<<std::endl;
    std::cout<<"kernel 2" <<std::endl;
    testkernel2<<<blockspergrid,THREADSPERBLOCK>>>(deviceresult);
    copy_device_to_output(deviceresult,hostresult,CODESIZE);
    for (int i=0;i<CODESIZE;i++){
        std::cout<<hostresult[i]<<","<<playercode2[i]<<std::endl;
    }
    
}

__global__ void testkernel1(unsigned int *deviceresult){
    // Set up index for the kernel
    int blockId=blockIdx.z*(gridDim.x*gridDim.y)+blockIdx.y*(gridDim.x)+blockIdx.x;
    int index=blockId*(blockDim.x*blockDim.y*blockDim.z)+threadIdx.z*(blockDim.x*blockDim.y)+threadIdx.y*(blockDim.y)+threadIdx.x;
    //printf("%u",codetocrack1[index]);
    if (index<CODESIZE){ //The number of threads may exceed the CODESIZE
        deviceresult[index]=codetocrack1[index]+100;
        //deviceresult[index]=2;
    }
}
__global__ void testkernel2(unsigned int *deviceresult){
    // Set up index for the kernel
    int blockId=blockIdx.z*(gridDim.x*gridDim.y)+blockIdx.y*(gridDim.x)+blockIdx.x;
    int index=blockId*(blockDim.x*blockDim.y*blockDim.z)+threadIdx.z*(blockDim.x*blockDim.y)+threadIdx.y*(blockDim.y)+threadIdx.x;
    //printf("%u",codetocrack1[index]);
    if (index<CODESIZE){ //The number of threads may exceed the CODESIZE
        deviceresult[index]=codetocrack2[index]+100;
        //deviceresult[index]=2;
    }
}