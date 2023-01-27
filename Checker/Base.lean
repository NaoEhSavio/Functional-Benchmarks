-- Types
-- =====

-- Equality
-- -------

inductive Base.Bool where
  | tt : Bool
  | ff : Bool

inductive Base.Nat where
  | zero             : Nat
  | succ (pred: Nat) : Nat

inductive Base.Tree where
  | leaf : Tree
  | node (l: Tree) (r: Tree) : Tree

inductive Base.Vector : Type u -> (len: Nat) -> Type u where
  | cons (head: t) (cons: Vector t len) : Vector t (Nat.succ len)
  | nil : Vector t Nat.zero

-- Church Boolean

def Base.Church.Bool  : Type (u + 1) := (p: Type u) -> (t: p) -> (f: p) -> p
def Base.Church.true  : Bool := fun _ => fun t => fun _ => t
def Base.Church.false : Bool := fun _ => fun _ => fun f => f

-- Church numeral

def Base.Church.Nat   : Type (u + 1) := (p: Type u) -> (t: p -> p) -> (f: p) -> p
def Base.Church.zero  : Nat        := fun _ => fun _ => fun z => z
def Base.Church.succ  : Nat -> Nat := fun n => fun p => fun f => fun z => f (n p f z)

-- Church tree

def Base.Church.Tree : Type (u + 1) := (p: Type u) -> (t: p -> p -> p) -> (f: p) -> p
def Base.Church.leaf : Tree                    := fun _ => fun _ => fun l => l
def Base.Church.node (a: Tree) (b: Tree): Tree := fun p => fun n => fun l => n (a p n l) (b p n l)

-- Church vector

def Base.Church.Vector (t: Type) (n: Nat): Type (u + 1) :=
  (p: Nat -> Type)
    -> (cons: (len: Nat) -> (head: t) -> (tail: p len) -> p (Base.Church.succ len))
    -> (nil: p Base.Church.zero)
    -> p n

def Base.Church.nil : Vector t Church.zero := fun _ => fun _ => fun nil => nil

def Base.Church.cons (head: t) (tail: Church.Vector t len) : Church.Vector t (Church.succ len) :=
  fun p => fun cons => fun nil => cons len head (tail p cons nil)

-- Functions

def Base.not : Base.Bool -> Base.Bool
  | Base.Bool.tt => Base.Bool.ff
  | Base.Bool.ff => Base.Bool.tt

def Base.and : Base.Bool -> Base.Bool -> Base.Bool
  | Base.Bool.ff, Base.Bool.ff => Base.Bool.ff
  | Base.Bool.ff, Base.Bool.tt => Base.Bool.ff
  | Base.Bool.tt, Base.Bool.ff => Base.Bool.ff
  | Base.Bool.tt, Base.Bool.tt => Base.Bool.tt

def Base.add : Base.Nat -> Base.Nat -> Base.Nat
  | x, Base.Nat.zero   => x
  | x, Base.Nat.succ y => Base.Nat.succ (add x y)

def Base.mul : Base.Nat -> Base.Nat -> Base.Nat
  | _, Base.Nat.zero   => Base.Nat.zero
  | x, Base.Nat.succ y => Base.add x (mul x y)

def Base.exp : Base.Nat -> Base.Nat -> Base.Nat
  | _, Base.Nat.zero   => Base.Nat.succ Base.Nat.zero
  | x, Base.Nat.succ y => Base.mul x (exp x y)

def Base.is_even : Base.Nat -> Base.Bool
  | Base.Nat.zero   => Base.Bool.tt
  | Base.Nat.succ a => Base.not (is_even a)

def Base.full_tree : Base.Nat -> Base.Tree
  | Base.Nat.zero   => Base.Tree.leaf
  | Base.Nat.succ n =>
    let branch := full_tree n
    Base.Tree.node branch branch

def Base.tree_fold : (a: Base.Tree) -> (p: Type u) -> (n: p -> p -> p) -> (l: p) -> p
  | Base.Tree.leaf,     _, _, l => l
  | Base.Tree.node a b, p, n, l => n (tree_fold a p n l) (tree_fold b p n l)

def Base.force_tree (t: Base.Tree) : Base.Bool :=
  Base.tree_fold t Base.Bool Base.and Base.Bool.tt

def Base.Church.not (b: Base.Church.Bool): Base.Church.Bool :=
  fun p => fun t => fun f => b p f t

def Base.Church.and (a: Base.Church.Bool) (b: Base.Church.Bool): Base.Church.Bool :=
  fun p => fun t => fun f => a p (b p t f) f

def Base.Church.add (a: Base.Church.Nat) (b: Base.Church.Nat): Base.Church.Nat :=
  fun p => fun s => fun z => a p s (b p s z)

def Base.Church.mul (a: Base.Church.Nat) (b: Base.Church.Nat): Base.Church.Nat :=
  fun p => fun s => a p (b p s)

def Base.Church.exp (a: Base.Church.Nat) (b: Base.Church.Nat): Base.Church.Nat :=
  fun p => b (p -> p) (a p)

def Base.Church.is_even (a: Base.Church.Nat): Base.Church.Bool :=
  a Base.Church.Bool Base.Church.not Base.Church.true

def Base.Church.full_tree (d: Base.Church.Nat): Base.Church.Tree := fun p n l => d p (fun t => n t t) l

def Base.Church.tree_fold (a: Base.Church.Tree) (p: Type (u+1)) (n: p -> p -> p) (l: p) : p := a p n l

def Base.Church.force_tree (t: Base.Church.Tree) : Base.Church.Bool :=
  Base.Church.tree_fold t Base.Church.Bool (fun a => fun b => Base.Church.and a b) (Base.Church.true)

def Base.N0  : Base.Nat := Base.Nat.zero
def Base.N1  : Base.Nat := Base.Nat.succ Base.N0
def Base.N2  : Base.Nat := Base.Nat.succ Base.N1
def Base.N3  : Base.Nat := Base.Nat.succ Base.N2
def Base.N4  : Base.Nat := Base.Nat.succ Base.N3
def Base.N5  : Base.Nat := Base.Nat.succ Base.N4
def Base.N6  : Base.Nat := Base.Nat.succ Base.N5
def Base.N7  : Base.Nat := Base.Nat.succ Base.N6
def Base.N8  : Base.Nat := Base.Nat.succ Base.N7
def Base.N9  : Base.Nat := Base.Nat.succ Base.N8
def Base.N10 : Base.Nat := Base.Nat.succ Base.N9
def Base.N11 : Base.Nat := Base.Nat.succ Base.N10
def Base.N12 : Base.Nat := Base.Nat.succ Base.N11
def Base.N13 : Base.Nat := Base.Nat.succ Base.N12
def Base.N14 : Base.Nat := Base.Nat.succ Base.N13
def Base.N15 : Base.Nat := Base.Nat.succ Base.N13
def Base.N16 : Base.Nat := Base.Nat.succ Base.N15
def Base.N17 : Base.Nat := Base.Nat.succ Base.N16
def Base.N18 : Base.Nat := Base.Nat.succ Base.N17
def Base.N19 : Base.Nat := Base.Nat.succ Base.N18
def Base.N20 : Base.Nat := Base.Nat.succ Base.N19
def Base.N21 : Base.Nat := Base.Nat.succ Base.N20
def Base.N22 : Base.Nat := Base.Nat.succ Base.N21
def Base.N23 : Base.Nat := Base.Nat.succ Base.N22
def Base.N24 : Base.Nat := Base.Nat.succ Base.N23
def Base.N25 : Base.Nat := Base.Nat.succ Base.N24
def Base.N26 : Base.Nat := Base.Nat.succ Base.N25
def Base.N27 : Base.Nat := Base.Nat.succ Base.N26
def Base.N28 : Base.Nat := Base.Nat.succ Base.N27
def Base.N29 : Base.Nat := Base.Nat.succ Base.N28
def Base.N30 : Base.Nat := Base.Nat.succ Base.N29
def Base.N31 : Base.Nat := Base.Nat.succ Base.N30
def Base.N32 : Base.Nat := Base.Nat.succ Base.N31

def Base.Church.N0  : Base.Church.Nat := Base.Church.zero
def Base.Church.N1  : Base.Church.Nat := Base.Church.succ Base.Church.N0
def Base.Church.N2  : Base.Church.Nat := Base.Church.succ Base.Church.N1
def Base.Church.N3  : Base.Church.Nat := Base.Church.succ Base.Church.N2
def Base.Church.N4  : Base.Church.Nat := Base.Church.succ Base.Church.N3
def Base.Church.N5  : Base.Church.Nat := Base.Church.succ Base.Church.N4
def Base.Church.N6  : Base.Church.Nat := Base.Church.succ Base.Church.N5
def Base.Church.N7  : Base.Church.Nat := Base.Church.succ Base.Church.N6
def Base.Church.N8  : Base.Church.Nat := Base.Church.succ Base.Church.N7
def Base.Church.N9  : Base.Church.Nat := Base.Church.succ Base.Church.N8
def Base.Church.N10 : Base.Church.Nat := Base.Church.succ Base.Church.N9
def Base.Church.N11 : Base.Church.Nat := Base.Church.succ Base.Church.N10
def Base.Church.N12 : Base.Church.Nat := Base.Church.succ Base.Church.N11
def Base.Church.N13 : Base.Church.Nat := Base.Church.succ Base.Church.N12
def Base.Church.N14 : Base.Church.Nat := Base.Church.succ Base.Church.N13
def Base.Church.N15 : Base.Church.Nat := Base.Church.succ Base.Church.N13
def Base.Church.N16 : Base.Church.Nat := Base.Church.succ Base.Church.N15
def Base.Church.N17 : Base.Church.Nat := Base.Church.succ Base.Church.N16
def Base.Church.N18 : Base.Church.Nat := Base.Church.succ Base.Church.N17
def Base.Church.N19 : Base.Church.Nat := Base.Church.succ Base.Church.N18
def Base.Church.N20 : Base.Church.Nat := Base.Church.succ Base.Church.N19
def Base.Church.N21 : Base.Church.Nat := Base.Church.succ Base.Church.N20
def Base.Church.N22 : Base.Church.Nat := Base.Church.succ Base.Church.N21
def Base.Church.N23 : Base.Church.Nat := Base.Church.succ Base.Church.N22
def Base.Church.N24 : Base.Church.Nat := Base.Church.succ Base.Church.N23
def Base.Church.N25 : Base.Church.Nat := Base.Church.succ Base.Church.N24
def Base.Church.N26 : Base.Church.Nat := Base.Church.succ Base.Church.N25
def Base.Church.N27 : Base.Church.Nat := Base.Church.succ Base.Church.N26
def Base.Church.N28 : Base.Church.Nat := Base.Church.succ Base.Church.N27
def Base.Church.N29 : Base.Church.Nat := Base.Church.succ Base.Church.N28
def Base.Church.N30 : Base.Church.Nat := Base.Church.succ Base.Church.N29
def Base.Church.N31 : Base.Church.Nat := Base.Church.succ Base.Church.N30
def Base.Church.N32 : Base.Church.Nat := Base.Church.succ Base.Church.N31
