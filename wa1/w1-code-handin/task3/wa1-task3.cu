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

int main(int argc, char** argv) {
    // size of array
    // can be set by command line args but defaults to 753411
    unsigned int N = 753411;
    if (argc > 1) {
        N = strtoul(argv[1], NULL, 10);
        assert(N != 0);
    }
    size_t mem_size = N*sizeof(float);

    // allocate host memory
    float *h_in  = (float *) malloc(mem_size);
    float *h_out = (float *) malloc(mem_size);

    // initialize memory
    for (unsigned int i = 0; i < N; ++i) {
        h_in[i] = (float) (i+1);
    }

    // preform serial map
    serial_map(h_in, h_out, N);

    // print results for debugging
    for (unsigned int i = 0; i < N; ++i) {
        printf("%d\t%.2f\n", i, h_out[i]);
    }
}
