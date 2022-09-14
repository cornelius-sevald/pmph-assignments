#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

void serial_map(float *in, float *out, unsigned int N) {
    for (unsigned int i = 0; i < N; ++i) {
        float x = in[i];
        float y = (x/(x-2.3))*(x/(x-2.3))*(x/(x-2.3)); // (x/(x-2.3))^3
        out[i] = y;
    }
}

__global__ void parallel_map(float *d_in, float *d_out, unsigned int N) {
    const unsigned int lid = threadIdx.x;
    const unsigned int gid = blockIdx.x*blockDim.x + lid;
    if (gid < N) {
        float x = d_in[gid];
        float y = (x/(x-2.3))*(x/(x-2.3))*(x/(x-2.3)); // (x/(x-2.3))^3
        d_out[gid] = y;
    }
}

int main(int argc, char** argv) {
    // size of array
    // can be set by command line args but defaults to 753411
    unsigned int N = 753411;
    if (argc > 1) {
        N = strtoul(argv[1], NULL, 10);
        assert(N != 0);
    }
    size_t mem_size = N*sizeof(float);
    unsigned int block_size = 256;
    unsigned int num_blocks = ((N + (block_size - 1)) / block_size);

    // allocate host memory
    float *h_in  = (float *) malloc(mem_size);
    float *h_out = (float *) malloc(mem_size);

    // initialize memory
    for (unsigned int i = 0; i < N; ++i) {
        h_in[i] = (float) (i+1);
    }

    // allocate device memory
    float *d_in;
    float *d_out;
    cudaMalloc((void **) &d_in,  mem_size);
    cudaMalloc((void **) &d_out, mem_size);

    // copy host memory to device
    cudaMemcpy(d_in, h_in, mem_size, cudaMemcpyHostToDevice);

    // preform parallel map
    parallel_map<<<num_blocks, block_size>>>(d_in, d_out, N);

    // copy host memory to device
    cudaMemcpy(h_out, d_out, mem_size, cudaMemcpyDeviceToHost);

    // print results for debugging
    for (unsigned int i = 0; i < N; ++i) {
        printf("%d\t%.2f\n", i, h_out[i]);
    }

    // clean up
    free(h_in);
    free(h_out);
    cudaFree(d_in);
    cudaFree(d_out);
}
