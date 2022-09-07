def Size : Base.Church.Nat := Base.Church.N1
def Main : Base.Equal (Base.Church.is_even (Base.Church.exp Base.Church.N2 Size)) Base.Church.true := Base.Equal.refl
