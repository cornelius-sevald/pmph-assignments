#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

int main(int argc, char** argv) {
    // Size of array
    // Can be set by command line args but defaults to 753411
    unsigned long N = 753411;

    if (argc > 1) {
        N = strtoul(argv[1], NULL, 10);
        assert(N != 0);
    }

    printf("N = %lu\n", N);
}
