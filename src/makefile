CC=nvcc
.PHONY: default
default: test
testcode.o:	testcode.cu
	$(CC) -c -o $@ $< 

gpuutilsfunc.o: gpuutilsfunc.cu
	$(CC) -c -o $@ $<

main.o:	main.cu
	$(CC) -c -o $@ $<

test:	main.o testcode.o gpuutilsfunc.o
	$(CC) -o $@ main.o testcode.o gpuutilsfunc.o


clean: 
	rm test  *.o