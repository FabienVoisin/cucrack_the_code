#ifndef COMMON_H
#define COMMON_H
#define CODESIZE 256
#define ARRAYSIZE 1024
#define THREADSPERBLOCK 32
__constant__ unsigned int codetocrack1[CODESIZE]; //2 is for 2 players
__constant__ unsigned int codetocrack2[CODESIZE];
#endif 