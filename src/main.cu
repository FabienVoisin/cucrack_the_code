#include <iostream>
#include <thread>
#include <vector>
//#include "struct.cuh"
#include "gpuutilsfunc.cuh"
#include "testcode.cuh"


int main(){
/*First we need to check how many GPU devices this  */
    int numberofGPUdevice;
    cudaGetDeviceCount(&numberofGPUdevice);
    if (numberofGPUdevice<2){
        std::cout<<"We currently need two GPUs to play this game";
    }

//Now we set up the player classes, this will vreate a random code that
// we will need to send to symbol on each GPUs.
    player player1;
    player player2;
    player1.get_gpu(0);
    player1.get_gpu(1);
    
    /* Part of code to test and delete after*/
    //printcode(player1);
    std::cout<<"Now for player 2" << std::endl;
    //printcode(player2);
    /* Now we need to copy the data to symbol*/
    copy_to_constant_gpu_memory(player2.hostcode,codetocrack1,0);
    //copy_to_constant_gpu_memory(player1.hostcode,codetocrack2,0);
    runtestkernel();
    // We then need to perform a simple operation

}