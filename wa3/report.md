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

```
[<, <]
[=, <]
```

