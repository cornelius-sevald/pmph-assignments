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
