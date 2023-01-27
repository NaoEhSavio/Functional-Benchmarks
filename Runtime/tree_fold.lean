inductive Tree where
| node (l r : Tree) : Tree
| leaf (w : UInt32) : Tree
deriving Inhabited


namespace Tree

partial def gen (val : UInt32) : Tree :=
  if val == 0 then
    .leaf 1
  else
    .node (gen (val - 1)) (gen (val - 1))

def sum : Tree → UInt32
  | .leaf _ => 1
  | .node l r => sum l + sum r

end Tree

def main (xs : List String) : IO Unit := do
  let n := UInt32.ofNat $ String.toNat! xs.head!
  IO.print $ (Tree.gen n).sum
