def Size : Base.Nat := Base.N1
def Main : Base.Equal (Base.force_tree (Base.full_tree Size)) Base.Bool.tt := Base.Equal.refl
