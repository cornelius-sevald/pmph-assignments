-- Parallel Longest Satisfying Segment
--
-- ==
-- compiled input {
--    [1i32, -2, -2, 0, 0, 0, 0, 0, 3, 4, -6, 1]
-- }
-- output { 
--    9
-- }
-- compiled input {
--    [0i32, 1, 2, 3, 4, 5, 6, 7, 8, 9]
-- }
-- output { 
--    10
-- }
-- compiled input {
--    [9i32, 8, 7, 6, 5, 4, 3, 2, 1, 0]
-- }
-- output { 
--    1
-- }

import "lssp"
import "lssp-seq"

type int = i32

let main (xs: []int) : int =
  let pred1 _   = true
  let pred2 x y = (x <= y)
--  in  lssp_seq pred1 pred2 xs
  in  lssp pred1 pred2 xs
