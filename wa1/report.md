---
title-meta: PMPH Assignment 1
author-meta: Cornelius Sevald-Krause
date-meta: 2022-09-15
lang: en-GB
header-includes: |
  <style>
    table {border-collapse: collapse;}
    table, th, td {border: 1px solid black;}
    td {vertical-align: top;}
  </style>
---

\newcommand\catenate{\mathbin{\text{\ttfamily\upshape ++}}}
\newcommand\mappend{\mathbin{\text{\ttfamily\upshape o}}}

PMPH Assignment 1
===============

By: Cornelius Sevald-Krause `<lgx292>`  
Due: 2022-09-15

Task 1
------

### Part a)

Let $a, b, c \in Img(h)$ such that $h(x) = a$, $h(y) = b$ and $h(z) = c$
where $x, y, z \in \mathcal{A}$,
the domain of $h : \mathcal{A} \rightarrow \mathcal{B}$.

To prove that '$\mappend$' is associative we write the expression
$(a \mappend b) \mappend c$ as
$(h(x) \mappend h(y)) \mappend h(z)$.
Using the third definition of $h$ we re-write it
$h((x \catenate y)) \mappend h(z) =
 h((x \catenate y) \catenate z)$.
As list concatenation is associative, we can further re-write:
$h((x \catenate y) \catenate z)     =
 h(x \catenate (y \catenate z))     =
 h(x) \mappend h(y \catenate z)     =
 h(x) \mappend (h(y) \mappend h(z)) =
 a    \mappend (b    \mappend c)$.

To prove that $e$ is the neutral element we use the first and third definitions
of $h$ to write $b \mappend e$ as
$h(y) \mappend h([]) =
 h(y  \catenate [])  =
 h(y)                =
 b$.
It is also easy to see that
$b \mappend e      =
 h(y \catenate []) =
 h([] \catenate y) =
 e \mappend b$.
