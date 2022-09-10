PMPH Assignment 1
===============

By: Cornelius Sevald-Krause `<lgx292>`  
Due: 2022-09-15

Task 1
------

### Part a)

Let `a, b, c` be elements of `Img(h)` such that `h x = a`, `h y = b` and
`h z = c` where `x, y, z` are elements of the domain of `h`.

To prove that '`o`' is associative we write the expression `(a o b) o c` as
`(h x o h y) o h z`. Using the third definition of `h` we re-write it
`h (x ++ y) o h z = h (x ++ y) ++ z`.
As list concatenation is associative, we can further re-write:
```
h (x ++ y) ++ z   =
h x ++ (y ++ z)   =
h x o h y ++ z    =
h x o (h y o h z) =
a o (b o c)
```

To prove that `e` is the neutral element we use the first and third definitions
of `h` to write `b o e` as `h y o h [] = h y ++ [] = h y = b`.
It is also easy to see that `b o e = h y ++ [] = h [] ++ y = e o b`.
