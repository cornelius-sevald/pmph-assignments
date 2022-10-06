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
that it is legal to privatize `A` can be found when looking at where `A` is
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
loop parallel and sequential and is therefore pointless.
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
