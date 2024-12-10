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


__host__ void codecheck(player &player,unsigned int *constcode){
    unsigned int blockspergrid=CODESIZE/THREADSPERBLOCK+1;
    unsigned int *devicecheck; //pointer to device hot encoding must return the index of invalid
    unsigned int *deviceswap;
    unsigned int *devicecode;
    unsigned int host_incorrect_number=0;
    unsigned int host_swapable_number=0;
    unsigned int *device_incorrect_number;
    unsigned int *device_incorrect_array;
    unsigned int *device_swapable_number;
    unsigned int *device_swapable_array;
    
    devicecheck=allocate_device_memory(CODESIZE);
    devicecode=allocate_device_memory(CODESIZE);
    deviceswap=allocate_device_memory(CODESIZE);

    device_incorrect_number=allocate_device_memory(sizeof(unsigned int));
    device_swapable_number=allocate_device_memory(sizeof(unsigned int));

    copy_input_to_device(player->currentcodeattempt,devicecode,CODESIZE);
    copy_input_to_device(&host_incorrect_number,device_incorrect_number,sizeof(unsigned int));
    copy_input_to_device(&host_swapable_number,device_swapable_number,sizeof(unsigned int));

    /*Now we need to create a new array tp store non zero values*/
    gpudevicecheckincorrect<<<blockspergrid,THREADSPERBLOCK>>>(devicecode,constcode,devicecheck,device_incorrect_number,CODESIZE);
    copy_device_to_output(device_incorrect_number,&host_incorrect_number,sizeof(int));
    device_incorrect_array=allocate_device_memory(host_incorrect_number);
    //I somehow need to push the zeros to the side so I can later use to resuce the array
    int incorrect_num_threads=max(host_incorrect_number,32); //32 being the adequate number of threads
    int incorrect_num_blocks=host_incorrect_number/incorrect_num_threads + 1 ; 

    place_incorrect_swap_value<<<incorrect_num_blocks,incorrect_num_threads>>>(devicecheck,device_incorrect_array, device_incorrect_number);
    /*Place the data back into the player values*/
    /*I will need to free these values before reinitialize them*/
    player.flagincorrect=new unsigned int[host_incorrect_numbers];
    copy_device_to_output(device_incorrect_number,&host_incorrect_number,sizeof(int));
    
    copy_device_to_output(device_incorrect_array,player.flagincorrect,host_incorrect_numbers*sizeof(unsigned int));

    gpudevicecheckswap<<<blockspergrid,THREADSPERBLOCK>>>(devicecode,constcode,deviceswapcheck,device_swapable_number,CODESIZE);
    copy_device_to_output(device_swapable_number)
    int incorrect_num_threads=max(host_incorrect_number,32); //32 being the adequate number of threads
    int incorrect_num_blocks=host_incorrect_number/incorrect_num_threads + 1 ; 
    place_incorrect_swap_value<<<incorrect_num_blocks,incorrect_num_threads>>>(devicecheck,device_swapable_array,device_swapable_number);
    player.flagswap=new unsigned int[host_swapable_number];
    copy_device_to_output(device_swapable_array,player.flagswap,host_swapable_number*sizeof(unsigned int));
    /* I need to free all pointers and CUDA variables*/
    cudafree(devicecheck);
    cudafree(devicecode);
    cudafree(deviceswap);
    cudafree(device_incorrect_number);
    cudafree(device_swapable_number);
}

/*What do I need to do?
First I need to make sure that we compare the playercode to the constcode
FOr every incorrect value, we need to store the key so that we can then copy the indices to modify*/
/*Another function will be used to swap indices
I can then output the number of elements that has incorrect (non-zero) values */
__global__ void gpudevicecheckincorrect(unsigned int *devicecode, unsigned int *constcode, unsigned int *devicecheck, unsigned int *incorrectnumber,int numelements){
    int blockId=blockIdx.z*(gridDim.x*gridDim.y)+blockIdx.y*(gridDim.x)+blockIdx.x;
    int index=blockId*(blockDim.x*blockDim.y*blockDim.z)+threadIdx.z*(blockDim.x*blockDim.y)+threadIdx.y*(blockDim.y)+threadIdx.x;

    __shared__ unsigned int incorrectnumbers;
    if (index<numelements){
        devicecheck[index]=(devicecode[index]!=constcode[index])*index;
        get_key_number_values(devicecheck,index,&incorrectnumbers);
    }
    
    

}
__device__ void get_key_number_values(unsigned int *devicecheck, int index,unsigned int *incorrectvalue){
    if (devicecheck[index] != 0){
        atomicAdd(&incorrectvalue,1);
    }
}

__global__ void place_incorrect_swap_values(unsigned int *devicecheck,unsigned int *device_incorrect_array, int numelements){
    int blockId=blockIdx.z*(gridDim.x*gridDim.y)+blockIdx.y*(gridDim.x)+blockIdx.x;
    int startindex=blockId*(blockDim.x*blockDim.y*blockDim.z)+threadIdx.z*(blockDim.x*blockDim.y)+threadIdx.y*(blockDim.y)+threadIdx.x;
    int index=startindex;
    //I need to incremenent by the number of threads which should equal the number of incorrect array.
    while (devicecheck[index]=0 && index < numelements){
         index +=numthreads; //increment by the number of threads
    }
    device_incorrect_array[startindex]=devicecheck[index];
    __syncthreads;
}

__global__ void gpudevicecheckswap(unsigned int *devicecode, unsigned int *constcode, unsigned int *deviceswapcheck, unsigned int *incorrectswapnumber,int numelements){
    int blockId=blockIdx.z*(gridDim.x*gridDim.y)+blockIdx.y*(gridDim.x)+blockIdx.x;
    int index=blockId*(blockDim.x*blockDim.y*blockDim.z)+threadIdx.z*(blockDim.x*blockDim.y)+threadIdx.y*(blockDim.y)+threadIdx.x;

    if (index<numelements){
        unsigned int temp=0; 
        unsigned int pasttemp=0;
        for (int i=0){
            temp=pasttemp+(devicecode[index]==constcode[i])*index;
            pasttemp=temp;
        }
         deviceswapcheck[index]=temp;
        get_key_number_values(deviceswapcheck,index,&incorrectswapnumbers);
    }

}

