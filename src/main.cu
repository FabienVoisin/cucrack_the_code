#include <iostream>
#include <thread>
#include <vector>
//#include "struct.cuh"
#include "gpuutilsfunc.cuh"
#include "testcode.cuh"
#include <unistd.h>


int main(){
/*First we need to check how many GPU devices this  */
    int numberofGPUdevice;
    cudaGetDeviceCount(&numberofGPUdevice);
    if (numberofGPUdevice<2){
        std::cout<<"We currently need two GPUs to play this game";
    }

//Now we set up the player classes, this will vreate a random code that
// we will need to send to symbol on each GPUs.
    player player1(1);
    player player2(4);
    player1.get_gpu(0);
    player1.get_gpu(1);
    
    /* Part of code to test and delete after*/
    printcode(player1);
    std::cout<<"Now for player 2" << std::endl;
    printcode(player2);
    /* Now we need to copy the data to symbol*/
    
    copy_to_constant_gpu_memory(player1,1);
    copy_to_constant_gpu_memory(player2,0);

    unsigned int *devicevalue;
    unsigned int hostvalue;

    devicevalue=allocate_device_memory<unsigned int>(1);
    //testval<<<8,32>>>(player1.constantmemory,player2.constantmemory,devicevalue);
    copy_device_to_output<unsigned int>(devicevalue,&hostvalue,1);
    //std::cout<<"val is "<<hostvalue<<std::endl;
    getcodeattempt(player1);
    codecheck(player1);
    //runtestkernel(player1.hostcode,player2.hos1tcode);
    // We then need to perform a simple operation
    std::cout<<"player generated code:"<<std::endl;
    for (int i=0; i<CODESIZE;i++){
    std::cout<<player1.currentcodeattempt[i]<<",";
    }
    std::cout<<std::endl;

    std::cout<<"player incorrect indices"<<std::endl;
    std::cout<<"player incorrect numbers: "<< player1.flagincorrectnumber<<std::endl;
    for (int i=0; i<player1.flagincorrectnumber;i++){
        std::cout<<player1.flagincorrect[i]<<",";
        }

    std::cout<<"player swap indices"<<std::endl;
    std::cout<<"player swap numbers: "<< player1.flagswapnumber<<std::endl;
    for (int i=0; i<player1.flagswapnumber;i++){
        std::cout<<player1.flagswap[i]<<",";
        }

}