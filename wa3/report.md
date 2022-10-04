---
title-meta: PMPH Assignment 3
author-meta: Cornelius Sevald-Krause
date-meta: 2022-10-07
lang: en-GB
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
from `A[k-1]` must necessarily have been produced in the previous iteration. As
`A` is not indexed by `i` the outer loop does not have the possibility of
carrying the dependency.

For the second inner loop, in the statement on line 11, assume that iteration
$(i_1, j_1)$ reads from `B[i, j]` and iteration $(i_2, j_2)$ writes to `B[i,
j]`. This yields the following two equations: $i_1 = i_2+1$ and $j_1 = j_2+1$
which means that $i_1 > i_2$ and $j_1 > j_2$. Assuming iteration $(i_1, j_1)$ is
the sink results in the direction vector `[<, <]`. Doing the same for the
statement on line 12 yields the following two equations: $i_1 = i_2$ and $j_1 =
j_2+1$ which means that $i_1 = i_2$ and $j_1 > j_2$. Again assuming iteration
$(i_1, j_1)$ is the sink results in the direction vector `[=, <]`. As both of
these are valid direction vectors they are true (RAW) dependencies. Our
direction matrix is:

$$
    M =
    \left[ \begin{array}{cc}
        \texttt{<} & \texttt{<} \\
        \texttt{=} & \texttt{<} \\
    \end{array} \right]
$$

The inner loop is not parallel as $M[1,1] = \texttt{<}$ and the outer loop does
not carry the dependency.

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
 - $S_3 \rightarrow S_3$: We've already established that there's a true
   dependency on line 11.
 - $S_4 \rightarrow S_4$: Same reason as the $S_3 \rightarrow S_3$ dependence.

Note that the previous WAW dependency on line 4 is gone as we privatized `A`.
Our dependency graph looks like:

![Dependency graph](task1_depgraph.png)

According to the graph, we distribute the outer loop across (in the following
order) $S_1$, $S_2$, $S_3$ and $S_4$. The order of $S_3$ and $S_4$ doesn't
matter. As `A` is overwritten in each iteration and used in several SCCs we need
to preform array expansion on `A` i.e. convert it to a $N \times (2 M)$ matrix.
The distributed loop is shown below:

```c
float A[N][2*M];

for (int i = 0; i < N; i++) {
    A[i][0] = N;                            // S1
}

for (int i = 0; i < N; i++) {
    for (int k = 1; k < 2*M; k++) {
        A[i][k] = sqrt(A[i][k-1] * i * k);  // S2
    }
}

for (int i = 0; i < N; i++) {
     for (int j = 0; j < M; j++) {
        C[i, j+1] = C[i, j] * A[i][2*j+1];  // S3
    }
}

for (int i = 0; i < N; i++) {
     for (int j = 0; j < M; j++) {
        B[i+1, j+1] = B[i, j] * A[i][2*j];  // S4
    }
}
```

After the loops, the value that previously corresponded to `A` is now `A[N-1]`.
