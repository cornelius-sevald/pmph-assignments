---
title-meta: PMPH Assignment 4
author-meta: Cornelius Sevald-Krause
date-meta: 2022-10-14
lang: en-GB
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
penalty of 10 cycles, moving `X` from $S$ to $I$ for all other processors.
The second `W1/X` is a write hit and costs 1 cycle.  For the second processor, we
are in the same situation as before (`X` is in $I$), so we get a read miss and
move `X` from $I$ to $S$ triggering a `BusRd` costing 40 cycles. This also moves
`X` out of $M$ to $S$ for processor 1. Now we are in the excact same situation
as we were after the initial `R1/X` so we can reason that the next two
operations will cost 10 and 1 cycles respectively.  For processor 3 and 4 we can
also reason that the results are the same i.e. a the three operations will cost
40+10+1 clock cycles each. The final cost is therefore $4 \cdot (40+10+1) = 204$
clock cycles.

For MESI: `R1/X` is a read miss and moves `X` from $I$ to $E$ incurring a
`BusRd` penalty of 40 cycles. `W1/X` moves `X` from $E$ to $M$ costing 1 cycle.
The second `W1/X` is a write hit and costs 1 cycle. Just as we did for MSI we
can reason that the operations of processor 2, 3 and 4 costs the same as the
ones for processor 1. The final cost is therefore $4 \cdot (40+1+1) = 164$.

Task 2
------

 1. cold
 2. cold
 3. cold
 4. hit
 5. cold
 6. false sharing
 7. hit
 8. replacement miss
 9. true sharing

Task 3
------

For MSI:

 a. `dir lookup`:
     50 cycles no traffic
 b. `dir lookup -> RemRd -> dir lookup -> flush -> install`:
     50          + 20     + 50          + 100    + 50 cycles,
                   6                    + (6+32)      bytes
 c. `BusRd -> dir lookup -> flush -> install`:
     20     + 50          + 100    + 50 cycles,
     6                    + (6+32)      bytes
 d. `BusRd -> dir lookup -> flush -> install`:
     20     + 50          + 100    + 50 cycles,
     6                    + (6+32)      bytes
 e. `BusRd -> dir lookup -> RemRd -> dir lookup -> flush -> install -> flush -> install`:
    20     + 50          + 20     + 50          + 100    + 50       + 100    + 50 cycles,
    6                    + 6                    + (6+32)            + (6+32)      bytes

For DASH: a, b, c, d -> Same as MSI.  

 e. `BusRd -> dir lookup -> RemRd -> dir lookup -> 2x flush -> 2x install`:
     20     + 50          + 20     + 50          + 100         50 cycles,
     6                    + 6                    + 2*(6+32)       bytes

Task 4
------

 a. network diameter: $n = 16$
 b. bisection width: $2n = 32$, bisection bandwidth: $32 \cdot 100 Mbits/s$
 c. total number of links: $2n^2 = 512$,
    total bandwidth: $512 \cdot 100 Mbits/s = 51.2 Gbits/s$,
    total bandwidth: $51.2 Gbits/s / n^2 = 200 Mbits/s$
