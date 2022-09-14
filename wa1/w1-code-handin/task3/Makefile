CC=nvcc
CFLAGS=-O3 -arch=compute_35 -I/opt/cuda/include -I/usr/local/cuda/include -Wno-deprecated-gpu-targets -Wno-deprecated-declarations
LDFLAGS=-L/opt/cuda/lib64 -L/usr/local/cuda/lib64

all: wa1-task3

wa1-task3.o: wa1-task3.cu
	$(CC) -c -o $@ $< $(CFLAGS)

wa1-task3: wa1-task3.o
	$(CC) -o $@ $^ $(LDFLAGS)

.PHONY: all clean

clean:
	rm -rf wa1-task3.o
	rm -rf wa1-task3
