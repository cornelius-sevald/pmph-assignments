#include<stdio.h>
#include<math.h>

#define N 10
#define M 20

int main() {
    float A[2*M]      = {0};
    float B[N+1][M+1] = {0};
    float C[N+1][M+1] = {0};

    for (int i = 0; i < N; i++) {
        A[0] = N;

        for (int k = 1; k < 2*M; k++) {
            A[k] = sqrt(A[k-1] * i * k);
        }

         for (int j = 0; j < M; j++) {
            B[i+1][j+1] = B[i][j] * A[2*j  ];
            C[i  ][j+1] = C[i][j] * A[2*j+1];
        }
    }

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
