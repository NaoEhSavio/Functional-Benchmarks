def Size : Base.Church.Nat := Base.Church.N1
def Main : Base.Equal (Base.Church.force_tree (Base.Church.full_tree Size)) Base.Church.true := Base.Equal.refl