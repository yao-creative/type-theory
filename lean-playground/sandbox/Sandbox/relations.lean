variable { A : Type }

def Reflexive (R : A -> A -> Prop) : Prop :=
∀ (a : A), R a a

def Symmetric (R : A → A → Prop) : Prop :=
∀ x y, R x y → R y x

def Transitive (R : A → A → Prop) : Prop :=
∀ x y z, R x y → R y z → R x z


def AntiSymmetric (R : A → A → Prop) : Prop :=
∀ x y, R x y → R y x → x = y


def Irreflexive (R : A → A → Prop) : Prop :=
∀ x, ¬ R x x

def Total (R : A → A → Prop) : Prop :=
∀ x y, R x y ∨ R y x



