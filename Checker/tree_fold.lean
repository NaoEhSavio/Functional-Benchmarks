def Size : Base.Nat := Base.N1
def Main : Eq (Base.force_tree (Base.full_tree Size)) Base.Bool.tt := by rfl
