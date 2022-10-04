#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<math.h>

#define N 10
#define M 20

int main() {
    float A[2*M]      = {0};
    float B[N+1][M+1] = {0};
    float C[N+1][M+1] = {0};

    float *A_ = calloc(2*M*N, sizeof(float));
    for (int i = 0; i < N; i++) {
        memcpy(A_+i*2*M, A, N*sizeof(float));
        A_[i*2*M+0] = N;
    }
    for (int i = 0; i < N; i++) {
        for (int k = 1; k < 2*M; k++) {
            A_[i*2*M+k] = sqrt(A_[i*2*M+k-1] * i * k);
        }
    }
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < M; j++) {
            B[i+1][j+1] = B[i][j] * A_[i*2*M+2*j  ];
        }
    }
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < M; j++) {
            C[i  ][j+1] = C[i][j] * A_[i*2*M+2*j+1];
        }
    }
    memcpy(A, A_+(N-1)*2*M, N*sizeof(float));

    printf("A:");
    for (int i = 0; i < N; i++) {
        printf(" %f", A[i]);
    }
    printf("\nB:");
    for (int i = 0; i < N+1; i++) {
        for (int j = 0; j < M+1; j++) {
            printf(" %f", B[i][j]);
        }
    }
    printf("\nC:");
    for (int i = 0; i < N+1; i++) {
        for (int j = 0; j < M+1; j++) {
            printf(" %f", C[i][j]);
        }
    }
    printf("\n");
}
