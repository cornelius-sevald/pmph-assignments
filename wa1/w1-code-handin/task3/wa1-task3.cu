#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <assert.h>
#include <sys/time.h>
#include <time.h>

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

bool check_equal(float *arr1, float *arr2, unsigned int N) {
    const float epsilon = 0.00001;
    bool are_equal = true;

    for (unsigned int i = 0; i < N; ++i) {
        are_equal = are_equal && fabs(arr1[i] - arr2[i]) < epsilon;
    }

    return are_equal;
}

int timeval_subtract(
        struct timeval *result,
        struct timeval *t2,
        struct timeval *t1
        ) {
    unsigned int resolution = 1000000;
    long int diff = (t2->tv_usec + resolution * t2->tv_sec) -
                    (t1->tv_usec + resolution * t1->tv_sec);
    result->tv_sec  = diff / resolution;
    result->tv_usec = diff % resolution;
    return diff < 0;
}

#define CPU_RUNS 100
#define GPU_RUNS 100

int main(int argc, char** argv) {
    unsigned long int cpu_elapsed, gpu_elapsed;
    struct timeval t_start, t_end, t_diff;

    // size of array
    // can be set by command line args but defaults to 753411
    unsigned int N = 753411;
    if (argc > 1) {
        N = strtoul(argv[1], NULL, 10);
        assert(N != 0);
    }
    size_t mem_size = N*sizeof(float);
    unsigned int block_size = 1024;
    unsigned int num_blocks = ((N + (block_size - 1)) / block_size);

    // allocate host memory
    float *h_in    = (float *) malloc(mem_size);
    float *h_out_s = (float *) malloc(mem_size); // serial output
    float *h_out_p = (float *) malloc(mem_size); // parallel output

    // initialize memory
    for (unsigned int i = 0; i < N; ++i) {
        h_in[i] = (float) (i+1);
    }

    // preform serial map and time it
    gettimeofday(&t_start, NULL);
    for (int i = 0; i < CPU_RUNS; i++) {
        serial_map(h_in, h_out_s, N);
    }
    gettimeofday(&t_end, NULL);
    timeval_subtract(&t_diff, &t_end, &t_start);
    cpu_elapsed = (t_diff.tv_sec*1e6 + t_diff.tv_usec) / CPU_RUNS;

    // allocate device memory
    float *d_in;
    float *d_out;
    cudaMalloc((void **) &d_in,  mem_size);
    cudaMalloc((void **) &d_out, mem_size);

    // copy host memory to device
    cudaMemcpy(d_in, h_in, mem_size, cudaMemcpyHostToDevice);

    // preform parallel map
    gettimeofday(&t_start, NULL);
    for (int i = 0; i < GPU_RUNS; i++) {
        parallel_map<<<num_blocks, block_size>>>(d_in, d_out, N);
    } cudaThreadSynchronize();
    gettimeofday(&t_end, NULL);
    timeval_subtract(&t_diff, &t_end, &t_start);
    gpu_elapsed = (t_diff.tv_sec*1e6 + t_diff.tv_usec) / GPU_RUNS;

    // copy host memory to device
    cudaMemcpy(h_out_p, d_out, mem_size, cudaMemcpyDeviceToHost);

    if (check_equal(h_out_s, h_out_p, N)) {
        printf("VALID\n");
    } else {
        printf("INVALID\n");
    }

    printf("CPU runtime %d (ms)\n", cpu_elapsed);
    printf("GPU runtime %d (ms)\n", gpu_elapsed);

    // clean up
    free(h_in);
    free(h_out_s);
    free(h_out_p);
    cudaFree(d_in);
    cudaFree(d_out);
}
