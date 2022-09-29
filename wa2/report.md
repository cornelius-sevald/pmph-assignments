PMPH Assignment 2
=================

By: Cornelius Sevald-Krause `<lgx292>`  
Due: 2022-09-29

**Note:**

1. All benchmarks were done on gpu02.
2. To enable the optimizations in task 1 and 2, either export the environment
   variables `TASK1` and `TASK2` e.g. `TASK1=on make` or pass the options to the
   make command e.g. `make TASK2=on`. The actual values of `TASK1` and `TASK2`
   don't matter.
   I know the names are confusing (`TASK1` for task 2 and `TASK2` for task 3),
   it was to stay consistent with the comments in the source files that call
   them task 1 and task 2.

Task 1
------

The code that replaced the dummy code on line 66 is shown below:

```futhark
  let flags = mkFlagArray mult_lens 0 sq_primes :> [flat_size]i64
  let iots_v = map (\f -> if f != 0 then 2 else 1) flags
  let iotsp2 = sgmSumI64 flags iots_v
  let pss    = sgmSumI64 flags flags

  let not_primes = map2 (*) pss iotsp2
```

Line 1 uses the `mkFlagArray` function taken from the lecture notes and computes
the `flags` array using `mult_lens` as the shape. The values are taken from
`sq_primes` as they will be used later. Line 2 creates `iots_v` according to the
rule for flattening `iota` inside a `map`, except the first branch of the `if`
statement is `2` instead of `0`. This has the effect of `map`ping `(+2)` over
`iota`. Line 3 creates the segmented `iota` with all elements plus 2. Line 4
does a segmented sum using `flags` both as the flag array and operand. This
is equivalent to each `sq_primes` being replicated `mult_lens` times i.e.
`map2 replicate mult_lens sq_primes`. The result is stored in `pss` which is
then pairwise multiplied with `iotsp2` as the result on line 6.

The benchmarks were done with the command
`echo "10000000" | ./$prog -t /dev/stderr -r 10 > /dev/null` where `$prog` is
one of `primes-flat`, `primes-naive` and `primes-seq`.
The averages of the results are shown below.

| Prog.          | C Backend | OpenCL Backend |
|:---------------|----------:|---------------:|
| `primes-flat`  |    303001 |          28755 |
| `primes-naive` |    202289 |          41340 |
| `primes-seq`   |    327206 |              - |

The speedup between the sequential version with the C backend and the
flat-parallel version with the OpenCL backend is ~11.38.
The flat-parallel version is much slower (~3.3x) than the naive version with the
C backend, but has speedup of about ~1.44 with the OpenCL backend.
This is due to the superior depth of the flat-parallel version, now that the
parallel hardware has substantially reduced the impact of the work cost.

Task 2
------

The line `uint32_t loc_ind = threadIdx.x * CHUNK + i;` was instead changed to
`uint32_t loc_ind = threadIdx.x + i*blockDim.x;` in both `copyFromGlb2ShrMem`
and `copyFromShr2GlbMem`.

Before, in each thread, `loc_ind` would increase with a stride of 1 meaning that
adjacent threads in the same warp would, in lockstep, access memory `CHUNK`
bytes apart in each step.
Now, as `loc_ind` increases with a stride of `blockDim.x` i.e. the block size,
each adjacent thread accesses adjacent memory.

The benchmarks are discussed in the next section.

Task 3
------

The code for the inclusive warp-level scan is shown below:

```cpp
sgmScanIncWarp(volatile typename OP::RedElTp* ptr, volatile F* flg, const unsigned int idx) {
    typedef ValFlg<typename OP::RedElTp> FVTup;
    const unsigned int lane = idx & (WARP-1);

    // no synchronization needed inside a WARP, i.e., SIMD execution
    #pragma unroll
    for(uint32_t i=0; i<lgWARP; i++) {
        const uint32_t p = (1<<i);
        if( lane >= p ) {
            if(flg[idx] == 0) { ptr[idx] = OP::apply(ptr[idx-p], ptr[idx]); }
            flg[idx] = flg[idx-p] | flg[idx];
        } // __syncwarp();
    }

    F f = flg[idx];
    typename OP::RedElTp v = OP::remVolatile(ptr[idx]);
    return FVTup( f, v );
}
```

The tests that were meaningfully affected were "Optimized Reduce",
"Scan Inclusive AddI32" and "SgmScan Inclusive AddI32".

The time in microseconds with the different optimizations are shown below.
An array size of 50003565 was used and with block size 128.

| Optimizations       | Optimized Reduce | Scan Inclusive | SgmScan Inclusive |
|:--------------------|-----------------:|---------------:|------------------:|
| none                |            11251 |          13399 |             12528 |
| `TASK1`             |             8432 |           6441 |              6209 |
| `TASK2`             |             7186 |          11088 |             12510 |
| `TASK1` and `TASK2` |             4422 |           3924 |              6207 |

Below are the speedups relative to "none":

| Optimizations       | Optimized Reduce | Scan Inclusive | SgmScan Inclusive |
|:--------------------|-----------------:|---------------:|------------------:|
| none                |             1.00 |           1.00 |              1.00 |
| `TASK1`             |             1.33 |           2.08 |              2.02 |
| `TASK2`             |             1.57 |           1.21 |              1.00 |
| `TASK1` and `TASK2` |             2.54 |           3.41 |              2.02 |

As can be seen from the table, the optimizations in task 1 modestly improves the
runtime of Optimized Reduce and greatly improves both scans. The optimizations
in task 2 modestly improve Inclusive Scan and to a greater extent Optimized
Reduce. Together the two optimizations provide even greater speedups.

Below are the same measurements but with half of the elements (i.e. 25001782)
and same block size of 128.

| Optimizatrions      | Optimized Reduce | Scan Inclusive | SgmScan Inclusive |
|:--------------------|-----------------:|---------------:|------------------:|
| none                |             5676 |           6774 |              6261 |
| `TASK1`             |             4212 |           3192 |              3113 |
| `TASK2`             |             3627 |           5645 |              6263 |
| `TASK1` and `TASK2` |             2208 |           1959 |              3111 |

| Optimizatrions      | Optimized Reduce | Scan Inclusive | SgmScan Inclusive |
|:--------------------|-----------------:|---------------:|------------------:|
| none                |             1.00 |           1.00 |              1.00 |
| `TASK1`             |             1.35 |           2.12 |              2.01 |
| `TASK2`             |             1.56 |           1.20 |              1.00 |
| `TASK1` and `TASK2` |             2.57 |           3.46 |              2.01 |

The relative speedups are effectively the same which would suggest that the size
of the array does not impact the speedup of the optimizations.
