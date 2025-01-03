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
    if(error!=cudaSuccess){
        printf("There is an error here %s\n",cudaGetErrorName(error));
        exit(1);
    }
}

template <typename T>
__host__ T* allocate_device_memory(unsigned int numelements){
    cudaError_t error;
    T *devicedata;
    size_t size=numelements*sizeof(unsigned int);
    error=cudaMalloc((void**)&devicedata,size);

    return devicedata;
}


__host__ void codecheck(player &player){
    get_incorrect_swap_array(player);
    //get_swap_array(player);


    /* I need to free all pointers and CUDA variables*/
    
}


__host__ void get_incorrect_swap_array(player &player){
    unsigned int blockspergrid=CODESIZE/THREADSPERBLOCK+1;
    unsigned int *devicecode;
    unsigned int *device_incorrect_number;
    unsigned int *device_incorrect_array;
    unsigned int *device_swap_number;
    unsigned int *device_swap_array;
    int *incorrectcheck; //array of integers to set -1 for correct values
    int *swapcheck;
    unsigned int host_incorrect_number=0;
    
    incorrectcheck=allocate_device_memory<int>(CODESIZE);
    swapcheck=allocate_device_memory<int>(CODESIZE);
    devicecode=allocate_device_memory<unsigned int>(CODESIZE);
    device_incorrect_number=allocate_device_memory<unsigned int>(1);
    device_swap_number=allocate_device_memory<unsigned int>(1);

    copy_input_to_device<unsigned int>(player.currentcodeattempt,devicecode,CODESIZE);
    copy_input_to_device<unsigned int>(&player.flagincorrectnumber,device_incorrect_number,1);
    copy_input_to_device<unsigned int>(&player.flagswapnumber,device_swap_number,1);
    gpudevicecheckswapincorrect<<<blockspergrid,THREADSPERBLOCK>>>(devicecode,player.constantmemory,incorrectcheck,swapcheck,device_incorrect_number,device_swap_number,CODESIZE);

    /*Place the data back into the player values*/
    /*I will need to free these values before reinitialize them*/
    std::cout<<"am I here?"<<std::endl;
    copy_device_to_output<unsigned int>(device_incorrect_number,&player.flagincorrectnumber,1);
    copy_device_to_output<unsigned int>(device_swap_number,&player.flagswapnumber,1);
    device_incorrect_array=allocate_device_memory<unsigned int>(player.flagincorrectnumber);
    device_swap_array=allocate_device_memory<unsigned int>(player.flagswapnumber);

    unsigned int incorrect_num_threads=min(32,player.flagincorrectnumber);
    unsigned int incorrect_num_blocks=CODESIZE/(incorrect_num_threads)+1;
    
    unsigned int swap_num_threads=min(32,player.flagswapnumber);
    unsigned int swap_num_blocks=CODESIZE/(swap_num_threads)+1;
    //std::cout<<"flagincorrectnumber="<<player.flagincorrectnumber<<std::endl;
    player.flagincorrect=new unsigned int[player.flagincorrectnumber];
    player.flagswap=new unsigned int[player.flagswapnumber];
    unsigned int *device_incorrect_indices;
    unsigned int *device_swap_indices;
    device_incorrect_indices=allocate_device_memory<unsigned int>(CODESIZE);
    device_swap_indices=allocate_device_memory<unsigned int>(CODESIZE);
    
    place_incorrect_swap_values<<<incorrect_num_blocks,incorrect_num_threads>>>(incorrectcheck,device_incorrect_array,device_incorrect_indices,device_incorrect_number,CODESIZE);
    //printdevicearray<<<1,1>>>(device_incorrect_array,player.flagincorrectnumber);
 
    //std::cout<<"Hold up"<<std::endl<<std::endl;
    place_incorrect_swap_values<<<swap_num_blocks,swap_num_threads>>>(swapcheck,device_swap_array,device_swap_indices,device_swap_number,CODESIZE);   
    //printdevicearray<<<1,1>>>(device_swap_array,player.flagswapnumber);
    std::cout<<"am I here 2?"<<std::endl;
    copy_device_to_output<unsigned int>(device_incorrect_array,player.flagincorrect,player.flagincorrectnumber);
    std::cout<<"am I here3?"<<std::endl;
    copy_device_to_output<unsigned int>(device_swap_array,player.flagswap,player.flagswapnumber);
    
    cudaFree(incorrectcheck);
    cudaFree(swapcheck);
    cudaFree(device_incorrect_indices);
    cudaFree(device_swap_indices);
    cudaFree(device_incorrect_number);
    cudaFree(device_incorrect_array);
    cudaFree(device_swap_number);
    cudaFree(device_swap_array);
    cudaFree(devicecode);



}


__global__ void printdevicearray(unsigned int *array,unsigned int number){
    
    for (int i=0;i<number;i++){
        printf("device incorrect[%d]=%u\n",i,array[i]);
    }
}

/*What do I need to do?
First I need to make sure that we compare the playercode to the constcode
FOr every incorrect value, we need to store the key so that we can then copy the indices to modify*/
/*Another function will be used to swap indices
I can then output the number of elements that has incorrect (non-zero) values */
__global__ void gpudevicecheckswapincorrect(unsigned int *devicecode, unsigned int *constcode, int *incorrectcheck, int *swapcheck, unsigned int *incorrectnumber,unsigned int *swapnumber,int numelements){
    int blockId=blockIdx.z*(gridDim.x*gridDim.y)+blockIdx.y*(gridDim.x)+blockIdx.x;
    int index=blockId*(blockDim.x*blockDim.y*blockDim.z)+threadIdx.z*(blockDim.x*blockDim.y)+threadIdx.y*(blockDim.y)+threadIdx.x;

    //__device__ unsigned int incorrectnumbers;
    if(index<numelements){
        gpucheckincorrect(index,devicecode,constcode,incorrectcheck);
        gpucheckswap(index,devicecode,constcode,swapcheck); 
        /*Now we compare whether swap is good*/ 
        
        reduceincorrectonswap(index,incorrectcheck,swapcheck);
        get_key_number_values_add(incorrectcheck[index],incorrectnumber);
        get_key_number_values_add(swapcheck[index],swapnumber);
        /*We now count the number of incorrect elements swap*/

    }
   
    __syncthreads;
    /*Set up the incorrect indices and device_incorrect_swap_array*/

    //*incorrectnumber=incorrectnumbers;
    
}

inline __device__ void gpucheckincorrect(int index, unsigned int *devicecode, unsigned int *constcode, int *incorrectcheck){
    
    incorrectcheck[index]=(devicecode[index]!=constcode[index])*index+(devicecode[index]==constcode[index])*-1;

}

__device__ void gpucheckswap(int index, unsigned int *devicecode, unsigned int *constcode, int *swapcheck){
    
    swapcheck[index]=0;
    int temp=0; 
    int pasttemp=0;
    for (int i=0;i<CODESIZE;i++){
        temp=pasttemp+(devicecode[index]==constcode[i])*(index+1);
        pasttemp=temp;
    }
    temp=pasttemp -1 ;
    swapcheck[index]=temp;
     //printf("hell %d",deviceswapcheck[index]);
    
    __syncthreads;
}

inline __device__ void reduceincorrectonswap(int index, int *incorrectcheck, int *swapcheck){
    unsigned int temp=(swapcheck[index]>=0)*-1+(swapcheck[index]<0)*incorrectcheck[index];
    incorrectcheck[index]=temp;
}

inline __device__ void get_key_number_values_add(int arrayvalue, unsigned int *atomicvalue){
    if (arrayvalue != -1){
        unsigned int val=1;
        atomicAdd(atomicvalue,val);
    }
}


__global__ void place_incorrect_swap_values(int *devicecheck,unsigned int *device_incorrect_swap_array, unsigned int *device_incorrect_swap_indices, unsigned int *device_incorrect_swap_number,unsigned int numelements){
    int blockId=blockIdx.z*(gridDim.x*gridDim.y)+blockIdx.y*(gridDim.x)+blockIdx.x;
    int index=blockId*(blockDim.x*blockDim.y*blockDim.z)+threadIdx.z*(blockDim.x*blockDim.y)+threadIdx.y*(blockDim.y)+threadIdx.x;
    /*I need to make sure the number of threads does not exceed the number of elements*/
    unsigned int range=numelements/(*device_incorrect_swap_number)+1;

    unsigned int start=index*range;
    if (start<numelements){
        unsigned int temp; 
        unsigned int end=(range*(1+index)<numelements)*(range*(1+index))+(range*(1+index)>=numelements)*numelements;
        device_incorrect_swap_indices[index]=0;
        for (int i=start;i<end;i++){
            temp=device_incorrect_swap_indices[index]+(devicecheck[i]>=0); //increment value by 1 if true
            device_incorrect_swap_indices[index]=temp;
        }

        __syncthreads;
        unsigned int newindex=0;
        for (int i=0;i<index;i++){
            temp=newindex+device_incorrect_swap_indices[i];
            newindex=temp;
        }
        unsigned int j=start; //start is a different location in the devicecheck
        for (int i=newindex;i<newindex+device_incorrect_swap_indices[index];i++){
            //device_incorrect_swap_array[i]=1;
            while (devicecheck[j]<0) j++   ;
            device_incorrect_swap_array[i]=(unsigned int)devicecheck[j];
            j++;
            //printf("device_incorrect_swap_array[%d]=%u\n",i,device_incorrect_swap_array[i]);
        }
        
    }
    
    __syncthreads;
        
}

    //I need to incremenent by the number of threads which should equal the number of incorrect array.
    



/* TO PLACE IN A HOST FUNCTION
    //const __global__ unsigned int incorrectnumbers=*incorrectswapnumber;
    /*Set up the incorrect indices and device_incorrect_swap_array
    __global__ unsigned int swap_number_per_thread[incorrectnumbers];
    __global__ unsigned int device_swap[incorrectnumbers];
    if (index<*incorrectswapnumber){
        place_incorrect_swap_values(index,deviceswapcheck,device_swap,swap_number_per_thread,incorrectswapnumber,numelements);
    }
    final_incorrect_array=device_swap;
}
*/ 

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
