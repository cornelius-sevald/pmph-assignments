#include<stdio.h>
#include<assert.h>

#define N 4

float A[N][64];
float B[N][64];

void f() {
    for (int i = 0; i < N; i++) {
        float accum, tmpA;
        accum = 0;
        for (int j = 0; j < 64; j++) {
            tmpA = A[i][j];
            accum = accum + tmpA*tmpA;
            B[i][j] = accum;
        }
    }
}

void read_vals() {
    scanf("[");
    for (int i = 0; i < N-1; i++) {
        scanf("[");
        for (int j = 0; j < 64-1; j++) {
            scanf("%ff32, ", &A[i][j]);
        }
        scanf("%ff32], ", &A[i][64-1]);
    }
    scanf("[");
    for (int j = 0; j < 64-1; j++) {
        scanf("%ff32, ", &A[N-1][j]);
    }
    scanf("%ff32]\n", &A[N-1][64-1]);
}

void write_vals() {
    printf("[");
    for (int i = 0; i < N-1; i++) {
        printf("[");
        for (int j = 0; j < 64-1; j++) {
            printf("%ff32, ", B[i][j]);
        }
        printf("%ff32], ", B[i][64-1]);
    }
    printf("[");
    for (int j = 0; j < 64-1; j++) {
        printf("%ff32, ", B[N-1][j]);
    }
    printf("%ff32]]\n", B[N-1][64-1]);
}

int main() {
    read_vals();
    f();
    write_vals();
}
