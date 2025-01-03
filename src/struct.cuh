#include <iostream>
#include <vector>
#include "common.cuh"

#ifndef STRUCT_H
#define STRUCT_H
class player
{        

    public:

        cudaEvent_t playerevent; // we can get this for a specific turn by turn event 
        cudaDeviceProp gpuprop; // Stucture to get the GPU property
        int gpuindex;
        std::vector<unsigned int> unused_values;
        unsigned int hostcode[CODESIZE];
        unsigned int currentcodeattempt[CODESIZE];
        unsigned int flagincorrectnumber=0;
        unsigned int  flagswapnumber=0;
        unsigned int *flagincorrect; // check the value in the index is correct 1 if yes 0 if not
        unsigned int *flagswap; // check if the value needs to be swapped
        unsigned int *constantmemory; // Pointer to constant memory

        void playergencodetocrack(int seed){
            /*The goal here is to generate a random set of number of size codesize
            The code number MUST BE a unique set of number*/
            srand(seed);
            std::vector<int> tempvector(ARRAYSIZE);
            //we first need to set up a temparray to set all values possible, each value in the code needs to be unique
            for(int i=0; i<ARRAYSIZE; i++){
                tempvector[i]=i;
            }
            for(int i=0; i<CODESIZE; i++){
                int key=rand()%tempvector.size();
                hostcode[i]=tempvector[key];
                //Now we need to remove the index
                tempvector.erase(tempvector.begin()+key);
            } 

        } // This will need to be updated to main
        player(int seed):
        unused_values{std::vector<unsigned int>(ARRAYSIZE,0)}{
            for (int i = 0 ; i<ARRAYSIZE; i++){
                unused_values[i]=i; // give the vector all the available values
            }
        playergencodetocrack(seed); //fill up the hostcode that will be needed to be sent to the stream player 2

        }     
         
    void initiate_gpu(){
            /*set up the device based on the index initially allocated*/
            cudaSetDevice(gpuindex);
        }
    void get_gpu(int index){
            gpuindex=index;
            initiate_gpu();
            cudaGetDeviceProperties(&gpuprop,index);
        }   
        
};
#endif