-- Lean tries to avoid doing long kernel computation to stay interactive
set_option maxRecDepth 1000000000000
set_option maxHeartbeats 1000000000000

def Size : Base.Church.Nat := Base.Church.N1
def Main : Eq (Base.Church.force_tree (Base.Church.full_tree Size)) Base.Church.true := by rfl
