
partial def comp (p : UInt64) (f : UInt64 → UInt64) (n : UInt64) : UInt64 :=
  if p == 0 then
    f n
  else
    comp (p  - 1) (fun k => f (f k)) n

def main (xs : List String) : IO Unit := do
  let n := UInt64.ofNat $ String.toNat! xs.head!
  IO.print $ comp n (fun x => x) 0
