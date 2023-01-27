namespace Example

inductive List (α : Type u) where
| nil : List α
| cons (head : α) (tail : List α) : List α
deriving Inhabited

inductive Tree (α : Type u) where
| concat (l r : Tree α) : Tree α
| single (d : α) : Tree α
| empty : Tree α
deriving Inhabited

namespace Tree

def sum : Tree UInt32 → UInt32
  | empty => 0
  | single a => a
  | concat a b => sum a + sum b

end Tree


namespace List

partial def randoms (seed : UInt32) (size : UInt32) : List UInt32 :=
  if size == 0 then
    nil
  else
    cons seed (randoms (seed * 1664525 + 1013904223) (size - 1))


mutual

  partial def qsort (p s : UInt32) (xs : List UInt32) : Tree UInt32:=
    match xs with
    | nil => .empty
    | .cons x nil => .single x
    | .cons x xs =>
      split p s (cons x xs) nil nil

  partial def split (p s : UInt32) (xs min max : List UInt32) : Tree UInt32 :=
    match xs with
    | nil =>
      let s' := s >>> 1
      let min' := qsort (p - s') s' min
      let max' := qsort (p + s') s' max
      .concat min' max'
    | cons x xs =>
      place p s (p < x) x xs min max

  partial def place (p s : UInt32) (b : Bool) (x : UInt32) (xs min max : List UInt32) : Tree UInt32 :=
    match b with
    | false => split p s xs (cons x min) max
    | true => split p s xs min (cons x max)

end 

end List

end Example

def pivot : UInt32 := 2147483648

def main (xs : List String) : IO Unit := do
  let n := UInt32.ofNat $ String.toNat! xs.head!
  let list := Example.List.randoms 1 (100000 * n)
  IO.print $ (list.qsort pivot pivot).sum
