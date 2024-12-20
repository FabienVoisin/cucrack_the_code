/*This file provides all the information data into constant, pinned memory and GPU memory*/
#include <iostream>
#include "common.cuh"
#include "gpuutilsfunc.cuh"
#include <string.h>
__constant__  unsigned int codetocrack1[CODESIZE]; //2 is for 2 players
__constant__  unsigned int codetocrack2[CODESIZE];

__global__ void testval(unsigned int *constantmemory1, unsigned int *constantmemory2,unsigned int *deviceval){
    int blockId=blockIdx.z*(gridDim.x*gridDim.y)+blockIdx.y*(gridDim.x)+blockIdx.x;
    int index=blockId*(blockDim.x*blockDim.y*blockDim.z)+threadIdx.z*(blockDim.x*blockDim.y)+threadIdx.y*(blockDim.y)+threadIdx.x;
    if (index==0) *deviceval=constantmemory1[0]+constantmemory2[2];
    
        
    }
__host__  void copy_to_constant_gpu_memory(player &player,int playernumber){
    /* a reminder that the constant memory is read only and 64kB wide.
     we may need to make sure whether we should set a function to make sure the total 
     codesize does not exceed this number for performance purposes */
     size_t size=CODESIZE*sizeof(unsigned int);
     if (playernumber==0){
        cudaError_t err=cudaMemcpyToSymbol(codetocrack1,player.hostcode,size);
        cudaGetSymbolAddress((void**)&player.constantmemory,codetocrack1);
     }

     else{
        cudaError_t err=cudaMemcpyToSymbol(codetocrack2,player.hostcode,size);
        cudaGetSymbolAddress((void**)&player.constantmemory,codetocrack2);
     }
    
        /*if(strcmp(deviceconstantmemory,"crack2")==0){
            std::cout<<"test"<<std::endl;
            cudaError_t err=cudaMemcpyToSymbol(codetocrack1,hostcodedevice,size);
            if (err!=cudaSuccess){
                printf("%s",cudaGetErrorString(err));
                exit(1);
        }
        
        }*/
       
        std::cout<<"test"<<std::endl;
    //We must make sure that if we end up with one GPU only, the offset gets propagated
}
template <typename T>
__host__ void copy_input_to_device(T *hostdata, T *devicedata, T numelements){
    cudaError_t error;
    size_t size=numelements*sizeof(T);
    error=cudaMemcpy(devicedata,hostdata,size,cudaMemcpyHostToDevice);

}
template <typename T>
__host__ void copy_device_to_output(T *devicedata, T *hostdata, T numelements){
    cudaError_t error;
    size_t size=numelements*sizeof(T);
    error=cudaMemcpy(hostdata,devicedata,size,cudaMemcpyDeviceToHost);
}

__host__ unsigned int* allocate_device_memory(unsigned int numelements){
    cudaError_t error;
    unsigned int *devicedata;
    size_t size=numelements*sizeof(unsigned int);
    error=cudaMalloc((void**)&devicedata,size);

    return devicedata;
}


__host__ void codecheck(player &player){
    get_incorrect_array(player);
    get_swap_array(player);


    /* I need to free all pointers and CUDA variables*/
    
}


__host__ void get_incorrect_array(player &player){
    unsigned int blockspergrid=CODESIZE/THREADSPERBLOCK+1;
    unsigned int *devicecode;
    unsigned int *device_incorrect_number;
    unsigned int *device_incorrect_array;
    unsigned int *devicecheck;
    unsigned int host_incorrect_number=0;
    
    devicecheck=allocate_device_memory(CODESIZE);
    devicecode=allocate_device_memory(CODESIZE);
    device_incorrect_number=allocate_device_memory(sizeof(unsigned int));
    copy_input_to_device<unsigned int>(player.currentcodeattempt,devicecode,CODESIZE);
    copy_input_to_device<unsigned int>(&player.flagincorrectnumber,device_incorrect_number,1);
    
    gpudevicecheckincorrect<<<blockspergrid,THREADSPERBLOCK>>>(devicecode,player.constantmemory,devicecheck,device_incorrect_number,CODESIZE);
    copy_device_to_output<unsigned int>(device_incorrect_number,&player.flagincorrectnumber,1);
    device_incorrect_array=allocate_device_memory(player.flagincorrectnumber);

    int incorrect_num_threads=max(player.flagincorrectnumber,32);
    int incorrect_num_blocks=player.flagincorrectnumber/incorrect_num_threads + 1 ; 
    int total_num_threads=incorrect_num_threads*incorrect_num_blocks;
    place_incorrect_swap_values<<<incorrect_num_blocks,incorrect_num_threads>>>(devicecheck,device_incorrect_array, device_incorrect_number, total_num_threads);
    /*Place the data back into the player values*/
    /*I will need to free these values before reinitialize them*/
    copy_device_to_output<unsigned int>(device_incorrect_number,&player.flagincorrectnumber,1);
    player.flagincorrect=new unsigned int[player.flagincorrectnumber];
      
    copy_device_to_output<unsigned int>(device_incorrect_array,player.flagincorrect,player.flagincorrectnumber);    
    cudaFree(devicecheck);
    cudaFree(device_incorrect_number);
    cudaFree(device_incorrect_array);
    cudaFree(devicecode);



}

__host__ void get_swap_array(player &player){
    unsigned int blockspergrid=CODESIZE/THREADSPERBLOCK+1;
    unsigned int *devicecode;
    unsigned int *devicecheck;
    unsigned int host_swapable_number=0;
    unsigned int *device_swapable_number;
    unsigned int *device_swapable_array;
     
    devicecheck=allocate_device_memory(CODESIZE);
    devicecode=allocate_device_memory(CODESIZE);
    device_swapable_number=allocate_device_memory(sizeof(unsigned int));
    copy_input_to_device<unsigned int>(player.currentcodeattempt,devicecode,CODESIZE);
    copy_input_to_device<unsigned int>(&player.flagswapnumber,device_swapable_number,1);

    gpudevicecheckswap<<<blockspergrid,THREADSPERBLOCK>>>(devicecode,player.constantmemory,devicecheck,device_swapable_number,CODESIZE);
    copy_device_to_output<unsigned int>(device_swapable_number,&player.flagswapnumber,1);    
    device_swapable_array=allocate_device_memory(player.flagswapnumber);
    
    int swap_num_threads=max(player.flagswapnumber,32); //32 being the adequate number of threads
    int swap_num_blocks=player.flagswapnumber/swap_num_threads + 1 ; 
    std::cout<<"num blocks: "<< swap_num_blocks<<std::endl;
    int total_num_threads=swap_num_threads*swap_num_blocks;


    place_incorrect_swap_values<<<swap_num_blocks,swap_num_threads>>>(devicecheck,device_swapable_array,device_swapable_number,total_num_threads);
    player.flagswap=new unsigned int[player.flagswapnumber];
    copy_device_to_output<unsigned int>(device_swapable_array,player.flagswap,player.flagswapnumber);

    cudaFree(devicecode);
    cudaFree(devicecheck);
    cudaFree(device_swapable_number);
    cudaFree(device_swapable_array);
}

/*What do I need to do?
First I need to make sure that we compare the playercode to the constcode
FOr every incorrect value, we need to store the key so that we can then copy the indices to modify*/
/*Another function will be used to swap indices
I can then output the number of elements that has incorrect (non-zero) values */
__global__ void gpudevicecheckincorrect(unsigned int *devicecode, unsigned int *constcode, unsigned int *devicecheck, unsigned int *incorrectnumber,int numelements){
    int blockId=blockIdx.z*(gridDim.x*gridDim.y)+blockIdx.y*(gridDim.x)+blockIdx.x;
    int index=blockId*(blockDim.x*blockDim.y*blockDim.z)+threadIdx.z*(blockDim.x*blockDim.y)+threadIdx.y*(blockDim.y)+threadIdx.x;

    __global__ unsigned int incorrectnumbers;
    //printf("%u ",devicecheck[index]);
    if (index<numelements){
        devicecheck[index]=(devicecode[index]!=constcode[index])*index;
        
        get_key_number_values(devicecheck,index,incorrectnumber);
    }
    __syncthreads;
    //*incorrectnumber=incorrectnumbers;
    
}
__device__ void get_key_number_values(unsigned int *devicecheck, int index,unsigned int *incorrectvalue){
    if (devicecheck[index] != 0){
        unsigned int val=1;
        atomicAdd(incorrectvalue,val);
    }
}

__global__ void place_incorrect_swap_values(unsigned int *devicecheck,unsigned int *device_incorrect_array, unsigned int *numelements,int numthreads){
    int blockId=blockIdx.z*(gridDim.x*gridDim.y)+blockIdx.y*(gridDim.x)+blockIdx.x;
    int startindex=blockId*(blockDim.x*blockDim.y*blockDim.z)+threadIdx.z*(blockDim.x*blockDim.y)+threadIdx.y*(blockDim.y)+threadIdx.x;
    unsigned int index=startindex;
    //I need to incremenent by the number of threads which should equal the number of incorrect array.
    while (devicecheck[index]==0 && startindex < *numelements && index < CODESIZE){
         index +=numthreads; //increment by the number of threads
         //printf("%u ",devicecheck[index]);
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
        for (int i=0;i<CODESIZE;i++){
            temp=pasttemp+(devicecode[index]==constcode[i])*index;
            pasttemp=temp;
        }
         deviceswapcheck[index]=temp;
        get_key_number_values(deviceswapcheck,index,incorrectswapnumber);
    }

}


__host__ void getcodeattempt(player &player){
/*This will generate a code attempt...Ideally this is done on the CPU stream whilst the other player do their attempt*/
    std::cout<<"another test"<<std::endl;
    if (player.flagincorrectnumber ==0 && player.flagswapnumber ==0){
        for (int i=0;i<CODESIZE;i++){
            
            int key=rand()%player.unused_values.size();
            player.currentcodeattempt[i]=player.unused_values[key];
            player.unused_values.erase(player.unused_values.begin()+key);
        }

    }

    else {
        /*I need to check the swap array*/
        int tempval;
        for (int i=0;i<player.flagswapnumber;i++){
            if (i==0){
                tempval=player.flagswap[i];
            }
            else if (i==player.flagswapnumber-1){
                int index=player.flagswap[i];
                int nextindex=tempval; 
                player.currentcodeattempt[index]=player.currentcodeattempt[nextindex];
            }
            else{
                int index=player.flagswap[i];
                int nextindex=player.flagswap[i+1];
                player.currentcodeattempt[index]=player.currentcodeattempt[nextindex];
            }

            player.currentcodeattempt[i];
        }
    /*Then I need to replace the incorrect values*/
        for (int i=player.flagincorrectnumber;i>=0;i++){
            int index=player.flagincorrect[i];
            int key=rand()%player.unused_values.size();
            player.currentcodeattempt[index]=player.unused_values[key];
            player.unused_values.erase(player.unused_values.begin()+key);   
        }

    }
}
