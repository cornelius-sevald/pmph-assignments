---
title-meta: PMPH Assignment 4
author-meta: Cornelius Sevald-Krause
date-meta: 2022-10-14
lang: en-GB
include-header:
header-includes:
- \usepackage{siunitx}
- \sisetup{per-mode=symbol}
---


PMPH Assignment 4
=================

By: Cornelius Sevald-Krause `<lgx292>`  
Due: 2022-10-14

Task 1
------

### Part A

For MSI: `R1/X` is a read miss and moves `X` from $I$ to $S$ incurring a `BusRd`
penalty of 40 cycles. `W1/X` moves `X` from $S$ to $M$ and incurs a `BusUpgr`
penalty of 10 cycles, moving `X` from $S$ to $I$ for all other processors. The
second `W1/X` is a write hit and costs 1 cycle.  
For the second processor, we are in the same situation as before (`X` is in
$I$), so we get a read miss and move `X` from $I$ to $S$ triggering a `BusRd`
costing 40 cycles. This also moves `X` from $M$ to $S$ for processor 1. Now we
are in the excact same situation as we were after the initial `R1/X` so we can
reason that the next two operations will cost 10 and 1 cycles respectively.  For
processor 3 and 4 we can also reason that the results are the same i.e. the
three operations will cost 40+10+1 clock cycles for both processors. The final
cost is therefore $4 \cdot (40+10+1) = 204$ clock cycles.

For MESI: `R1/X` is a read miss and moves `X` from $I$ to $E$ incurring a
`BusRd` penalty of 40 cycles. `W1/X` moves `X` from $E$ to $M$ costing 1 cycle.
The second `W1/X` is a write hit and costs 1 cycle. Just as we did for MSI we
can reason that the operations of processor 2, 3 and 4 costs the same as the
ones for processor 1. The final cost is therefore $4 \cdot (40+1+1) = 164$.

### Part B

For MSI: We know from part A that we have one read miss and one `BusUpgr` for
each processor and therefore a total traffic of $4 \cdot (6+32+10) = 192$ bytes.

For MESI: We have one read miss and no other bus traffic for each processor
equaling a total of $4 \cdot (6+32) = 152$ bytes of traffic.

Task 2
------

### Part A

Let the block containing A, B, and C be called `X` and the block containing D be
called `Y`.

The first three reads are cold misses as `X` has not been accessed by that
processor yet. The write from P1 to A is a hit as `X` is in P1's cache. The
write invalidates the cache lines containing `X` in P2 and P3. The read of D
from P3 is a cold miss as `Y` has not been accessed yet. The read of B from P2
is a false sharing cache miss as `X` has been invalidated due to the previous
write to A. The write from P1 to B is also a hit as `X` is still in P1's cache.
The write again invalidates the cache line containing `X` in P2. The read of C
from P3 is a conflict miss as `Y` previously evicted `X` from the same cache
line. The read of B from P2 is a true sharing cache miss as `X` has been
invalidated by the previous write to the same variable B.

In summary, the cache misses are:

| Time | P1    | P2    | P3    | Miss type     |
|------|-------|-------|-------|---------------|
| 1    | $R_A$ |       |       | Cold miss     |
| 2    |       | $R_B$ |       | Cold miss     |
| 3    |       |       | $R_C$ | Cold miss     |
| 4    | $W_A$ |       |       |               |
| 5    |       |       | $R_D$ | Cold          |
| 6    |       | $R_B$ |       | False sharing |
| 7    | $W_B$ |       |       |               |
| 8    |       |       | $R_C$ | Replacement   |
| 9    |       | $R_B$ |       | True sharing  |

### Part B

The false sharing miss at $T=6$ could be ignored as the value of B is unchanged.

Task 3
------

For MSI:

 a. The local node does a directory lookup (50 cycles) and as the memory copy is
 clean no further action is taken.  
 Total of 50 cycles and no traffic.

 b. The local node does a directory lookup (50 cycles) and as the memory copy is
 dirty it does a remote read (20 cycles, 6 bytes). The remote node then does a
 directory lookup (50 cycles) and then flushes (100 cycles, 6+32 bytes) and
 finally the local node installs into the cache (50 cycles).  
 Total of 270 cycles and 44 bytes of traffic.

 c. The local nodes does a bus read request (20 cycles, 6 bytes) to the home
 node and then the home node does a directory lookup (50 cycles) and as the
 memory is clean flushes (100 cycles, 6+32 bytes) and the local node install the
 memory (50 cycles).  
 Total of 220 cycles and 44 bytes of traffic.

 d. The local node does a bus read request (20 cycles, 6 bytes) to the home node
 and then the home node does a directory lookup (50 cycles). As the home node is
 the dirty node it simply flushes (100 cycles, 6+32 bytes) and the local node
 installs the memory (50 cycles).  
 Total of 220 cycles and 44 bytes of traffic.

 e. The local node does a bus read request (20 cycles, 6 bytes) to the home node
 and then the home node does a directory lookup (50 cycles). The home node then
 does a remote read (20 cycles, 6 bytes) to the dirty node which then does a
 directory lookup (50 cycles) and then flushes (100 cycles, 6+32 bytes). The
 home node then installs into the cache (50 cycles) and flushes (100 cycles,
 6+32 bytes) and finally the local node installs into the cache (50 cycles).  
 Total of 440 cycles and 88 bytes of traffic.

For DASH: case a, b, c and d are the same as for MSI. For case e, we can preform
the two flushes and installs at the same time saving 150 cycles for a total of
290 cycles and 88 bytes of traffic.

Task 4
------

Let $N = n^2 = 16 \cdot 16$ be the number of nodes in the tori network.

 a. The network diameter is ${ n = 16 }$
 b. The bisection width is ${ 2n = 32 }$ and the bisection bandwidth is
    ${ 32 \cdot \qty{100}{\mega\bit\per\second} =
       \qty{3.2}{\giga\bit\per\second} }$
 c. The total number of links is ${ 2n^2 = 512 }$, the total bandwidth is
    ${ 512 \cdot \qty{100}{\mega\bit\per\second} =
       \qty{51.2}{\giga\bit\per\second}}$ and the total bandwidth per node is
    ${ \frac{\qty{51.2}{\giga\bit\per\second}}{n^2} =
       \frac{\qty{51.2}{\giga\bit\per\second}}{256} =
       \qty{200}{\mega\bit\per\second} }$

Task 5
------

a. The bisection width for a $n$-by-$n$ torus is $2n$ and for a $k$-dimensional
hypercube it is $2^{k-1}$ where $n^2 = 2^k = N$ is the number of nodes. To find
the $N$ for which the hypercube offers a higher bisection width we solve the
equation:
$$
\begin{array}{llr}
    2^{k-1}        &> 2n        &\Leftrightarrow \\
    2^{(\lg{N})-1} &> 2\sqrt{N} &\Leftrightarrow \\
    \frac{N}{2}    &> 2\sqrt{N} &\Leftrightarrow \\
\end{array}
$$
which holds for $N > 16$ i.e. at sizes greater than 16 nodes, the
$k$-dimensional a greater bisection width.
The closest number of nodes >16 is 64.

b. Both the switch degree and network diameter for a $k$-dimensional hypercube
is simply $k$. For a network with $N = 64$ nodes, $k = \lg{N} = 6$.

c. The latency (as measured by network diameter) and bandwidth (as measured by
bisection width) of a $k$-dimensional hypercube is favourable to that of an
$n$-by-$n$ torus for high $N$. The downside to the
$k$-dimensional hypercube is that its switch-degree (i.e. cost per node) grows
with $N$ and it is difficult to map to a 2D surface.
