let f (A : [][64]f32) : [][64]f32 =
  map (\A' -> let AtA = map2 (*) A' A'
               in scan (+) 0 AtA
      ) A

let main (A : [][]f32) : [][]f32 = f A
