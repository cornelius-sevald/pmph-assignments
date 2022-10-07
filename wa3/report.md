---
title-meta: PMPH Assignment 3
author-meta: Cornelius Sevald-Krause
date-meta: 2022-10-07
lang: en-GB
header-includes:
- \usepackage{placeins}
---

PMPH Assignment 3
=================

By: Cornelius Sevald-Krause `<lgx292>`  
Due: 2022-10-07

Task 1
------

For the outer loop there is a WAW dependency on line 4 as `A[0]` is written to
in every iteration.  
In the first inner loop, there is a true (RAW) dependency on line 7 as a read
from `A[k-1]` must necessarily have been produced in the previous iteration.  
Similarly, in the second inner loop there is also a true dependency in line 12
as a read from `C[i, j]` must have been produced by a write to `C[i, j+1]` in
the previous iteration, and as `C` is both indexed by `i` in the read and write
the outer loop does not have the possibility of carrying the dependency, as
opposed to line 11 where `B` is indexed by `i+1` in the write.  

To eliminate the WAW dependency on line 4, `A` can be privatized. The reason
that it is legal to privatize `A` can be found by looking at where `A` is
accessed. In the first iteration of the first inner loop (of index `k`) the read
from `A[0]` is covered by the write on line 4. All other reads of `A[k-1]` is
covered by a write to `A[k]` on the same line. `A` is also accessed on line 11
and 12, but all reads of `A` have already been covered in the same (outer)
iteration by writes in the loop on line 6--8.

Denote the statements on line 4, 7, 11 and 12 by $S_1$, $S_2$, $S_3$ and $S_4$
respectively. We will analyze the dependencies between these statements to
construct the dependency graph. The following dependencies exists:

 - $S_1 \rightarrow S_2$: In the first iteration of the first inner loop, $S2$
   reads `A[0]` which is written in the same outer iteration.
 - $S_2 \rightarrow S_2$: As we've already established there is a RAW dependency
   in the first inner loop where we read from `A[k-1]` and write to `A[k]`.
 - $S_2 \rightarrow S_3$: The reads of `A` from $S_3$ are produced by $S_2$.
 - $S_2 \rightarrow S_4$: Same reason as the $S_2 \rightarrow S_3$ dependence.
 - $S_4 \rightarrow S_4$: We've already established that there's a true
   dependency on line 12.
 - $S_3 \rightarrow S_3$: Same reason as the $S_4 \rightarrow S_4$ dependence.

Note that the previous WAW dependency on line 4 is gone as we privatized `A`.
Our dependency graph looks like:

\FloatBarrier

![Dependency graph](task1_depgraph.png)

\FloatBarrier

According to the graph, we distribute the outer loop across (in the following
order) $S_1$, $S_2$, $S_3$ and $S_4$. $S_3$ and $S_4$ are still together in the
inner loop. As `A` is overwritten in each iteration and used in several SCCs we
need to preform array expansion on `A` i.e. convert it to a $N \times (2 M)$
matrix which also has the effect of privatizing `A`.
The distributed loop is shown below:

```c
float A[2*M, N];

for (int i = 0; i < N; i++) {
    A[0, i] = N;                            // S1
}

for (int i = 0; i < N; i++) {
    for (int k = 1; k < 2*M; k++) {
        A[k, i] = sqrt(A[k-1, i] * i * k);  // S2
    }
}

for (int i = 0; i < N; i++) {
     for (int j = 0; j < M; j++) {
        B[i+1, j+1] = B[i, j] * A[2*j, i];  // S3
        C[i, j+1] = C[i, j] * A[2*j+1, i];  // S4
    }
}
```

The loop nest containing $S_1$ is trivially parallel as it only writes to $A$
and all of the writes are to different indices.  
For the loop containing $S_2$, consider an iteration $(i_1, k_1)$ that reads
from `A[i, k]` and an iteration $(i_2, k_2)$ that writes to `A[i, k]`. This
yields the following two equations: $i_1 = i_2$ and $k_1-1 = k_2$ which means
that $i_1 = i_2$ and $k_1 > k_2$. Assuming iteration $(i_1, k_1)$ is the sink
results in the direction vector `[ =, < ]`. As this is a valid direction vector,
our assumption was correct.  
For statement $S_3$, consider an iteration $(i_1, j_1)$ that reads from
`B[i, j]` and an iteration $(i_2, j_2)$ that writes to `B[i, j]`. This yields
the following two equations: $i_1 = i_2+1$ and $j_1 = j_2+1$ which means that
$i_1 > i_2$ and $j_1 > j_2$. Assuming iteration $(i_1, j_1)$ is the sink results
in the direction vector `[ <, < ]`. As this is a valid direction vector, our
assumption was correct. For statement $S_4$, the same reasoning used for
statement $S_2$ can be used, and therefore the direction vector is the same:
`[ =, < ]`

In short, the loop containing $S_2$ has direction matrix `[ =, < ]` and the loop
containing $S_3$ and $S_4$ has direction matrix

```
[ <, < ]
[ =, < ]
```

From these we can annotate the loops:

```c
float A[2*M, N];

// parallel
for (int i = 0; i < N; i++) {
    A[0, i] = N;
}

// parallel
for (int i = 0; i < N; i++) {
    // sequential
    for (int k = 1; k < 2*M; k++) {
        A[k, i] = sqrt(A[k-1, i] * i * k);
    }
}

// sequential
for (int i = 0; i < N; i++) {
    // sequential
     for (int j = 0; j < M; j++) {
        B[i+1, j+1] = B[i, j] * A[2*j, i];
        C[i, j+1] = C[i, j] * A[2*j+1, i];
    }
}
```

Loop interchange can be applied to both the loop containing $S_2$ and the loop
containing $S_3$ and $S_4$. This is because none of the direction matrices
contain a `>` element so interchanging the columns can never result in a `>` as
the leftmost non-`=` element.  
Interchanging the first nested loop simply switches which of the inner and outer
loops are parallel and sequential and is therefore pointless.
Interchanging the second nested loop results in the following direction matrix:

```
[ <, < ]
[ <, = ]
```

The first column implies a sequential loop as it has `<` elements and is the
outermost loop i.e. there is no other outer loop to carry the dependencies.
The second column implies a parallel loop as the `<` element in the second
column is covered by the `<` in the first column on the same row. Loop
interchange is therefore beneficial. The code with the interchanged loops is
shown below:

```c
float A[2*M, N];

// parallel
for (int i = 0; i < N; i++) {
    A[0, i] = N;
}

// parallel
for (int i = 0; i < N; i++) {
    // sequential
    for (int k = 1; k < 2*M; k++) {
        A[k, i] = sqrt(A[k-1, i] * i * k);
    }
}

// sequential
for (int j = 0; j < M; j++) {
    // parallel
     for (int i = 0; i < N; i++) {
        B[i+1, j+1] = B[i, j] * A[2*j, i];
        C[i, j+1] = C[i, j] * A[2*j+1, i];
    }
}
```

Task 2
------

The write to `accum` on line 5 incurs a WAW dependency in the outer loop making
it not parallel. Additionally, the writes to `tmpA` in the inner loop on line 7
also incur a WAW dependency making.

To make the outer loop parallel, the WAW dependencies needs to be removed which
is done by privatizing `accum` and `tmpA`. It is safe to privatize `accum` as
any read from `accum` (on line 8 and 9) is covered by the write on line 5 in the
same iteration. It is also safe to privatize `tmpA` as the read on line 8 is
covered by the write on line 7.  
Assuming neither `accum` or `tmpA` is read after the outer loop, we can
privatize them by moving the declarations inside the loop as follows:

\newpage

```c
float A[N,64];
float B[N,64];
for (int i = 0; i < N; i++) {
    float accum, tmpA;
    accum = 0;
    for (int j = 0; j < 64; j++) {
        tmpA = A[i, j];
        accum = sqrt(accum) + tmpA*tmpA;
        B[i,j] = accum;
    }
}
```

The inner loop is not parallel as line 8 incurs a RAW (true) dependency as the
read of `accum` must have been produced by a write in the previous iteration.

We notice that the (re-written) line `accum = accum + tmpA*tmpA` looks like a
reduce pattern with associative operator `+`. It is not, however, as the next
line writes `accum` to an array violating the condition for a reduce pattern.
That instead implies that the loop can be expressed as a scan and the outer
parallel loop would then be a map. The futhark code is shown below:

```haskell
map (\A' -> let AtA = map2 (*) A' A' in scan (+) 0 AtA) A
```

Of course this version uses nested parallelism and should probably be flattened.

Task 3
------

The kernel `transfProg` is shown below:

```cpp
__global__ void 
transfProg(float* Atr, float* Btr, unsigned int N) {
    unsigned int gid = (blockIdx.x * blockDim.x + threadIdx.x);
    if(gid >= N) return;
    float accum = 0.0;

    for(int j=0; j<64; j++) {
        float tmpA  = Atr[j*N + gid];
        accum = sqrt(accum) + tmpA*tmpA;
        Btr[j*N + gid]  = accum;
    }
}
```

It is very similar to the `origProg` kernel, except that when indexing `Atr` and
`Btr`, `j` is multiplied by `N` and `gid` is simply added as-is instead of
multiplying `gid` by 64 and adding `j`. This has the effect of traversing `Atr`
and `Btr` column-wise instead of row-wise in the loop. This means that adjacent
threads will also access adjacent memory leading to coalesced memory access.

The CPU orchestration is shown below:

```cpp
transposeTiled<float, TILE>(d_A, d_Atr, HEIGHT_A, WIDTH_A);
transfProg<<< num_blocks, block >>>(d_Atr, d_Btr, num_thds);
transposeTiled<float, TILE>(d_Btr, d_B, WIDTH_A, HEIGHT_A);
```

It transposes `d_A` and stores it in `d_Atr`, runs the `transfProg` kernel with
`d_Atr` as input and `d_Btr` as output and finally re-transposes `d_Btr` and
stores it in `d_B` which is the final output. Notice also how the width and
height parameters are switched in the second transposition, even though it does
not matter in this case as they are equal.

Sadly, the program does not validate and I have no idea why. It reports:
"`Row 0 column: 1, seq: 0.400942, par: 0.011794`". Strangely, if you use the
`origProg` kernel instead of `transfProg` on line 192 (while keeping the
transpositions) you get the same error. You also get the same error if you use
the `transfProg` kernel but forgo the transpositions (and remember to pass `d_A`
and `d_B` directly). Anyway, I digress.

The benchmarks on the different GPUs are shown below in GB/s:

| GPU # | `memcpy` | Original | Coalesced |
|-------|---------:|---------:|----------:|
| `02`  |   259.36 |    11.63 | 71.70     |
| `03`  |   259.48 |    11.69 | 71.77     |
| `04`  |   540.66 |    16.06 | 140.00    |

As expected, both `GPU 02` and `GPU 03` have similar results with the coalesced
version having speedups of ~6.16 w.r.t. the original. `GPU 04` is faster and
results in an even greater speedup of ~8.72. Of course, the speedups are not to
be trusted as the coalesced version does not validate, so any performance gains
should be taken with a grain of salt until the program actually produces the
correct result.

Task 4
------

The `matMultRegTiledKer` kernel does validate. The benchmarks on the different
GPUs are shown below in GFlops/s:

| GPU # |   Naive | Block-Tiled | Block+Register Tiled |
|-------|--------:|------------:|---------------------:|
| `02`  |  152.73 |      431.14 |             12744.71 |
| `03`  |  152.86 |      431.39 |              9862.15 |
| `04`  | 1138.19 |     1493.12 |              1389.51 |

Both `GPU 02` and `GPU 03` have incredible results with the block+register tiles
version with `GPU 02` having speedups of ~29.56 and ~83.45 over the block-tiled
and naive versions respectively. `GPU 04` is much faster with the naive and
block-tiled kernels but is actually slower with the block+register tiled kernel
than `GPU 02` and `GPU 03` which is very surprising. It might in part be because
more people where using the device at the same time (I checked with the `who`
command) but that is probably only a small factor.

By preforming the extra levels of strip-mining on the loops we are able to
interchange them to our liking and unroll the hot loops that do all of the
reading and writing to memory which can lead to significant performance gain.

The kernel is shown below:

```cpp
template <class ElTp, int T> 
__global__ void matMultRegTiledKer(ElTp* A, ElTp* B, ElTp* C,
        int heightA, int widthB, int widthA) {
  __shared__ ElTp Ash[T][T];
  unsigned int tidy = threadIdx.y;          // thread id y
  unsigned int tidx = threadIdx.x;          // thread id x
  unsigned int ii = blockIdx.y * T;         // grid y
  unsigned int jjj = blockIdx.x * T * T;    // grid x
  unsigned int jj = jjj + tidy * T;         // block y
  unsigned int j = jj + tidx;               // block x
  ElTp accum[T] = {0};

  for(int kk = 0; kk < widthA; kk += T) {
      #pragma unroll
      for(int i = 0; i < T; i++) {
          Ash[tidy][tidx] = (((i+ii) < heightA) && (kk+tidx < widthA)) ?
              A[(i+ii)*widthA + (kk+tidx)] : 0.0;
      }
      __syncthreads();
      for(int k = 0; k < T; k++) {
          float b = B[k*widthB + j];
          #pragma unroll
          for(int i = 0; i < T; i++) {
              accum[i] += Ash[i+ii][k] * b;
          }
      }
      __syncthreads();
  }
  #pragma unroll
  for(int i = 0; i < T; i++) {
      C[(i+ii)*widthB + j] = accum[i];
  }
}
```
