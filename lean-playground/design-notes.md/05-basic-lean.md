**Intent: Lean project structure + module system + syntax onboarding.**

If you've already done `lake new`, the key idea is:

$$
\boxed{\text{one `.lean` file} \leftrightarrow \text{one module}}
$$

and modules form a dependency DAG through `import`.

## 1. Typical Lake project

Suppose:

```text
myproject/
├── lakefile.toml
├── MyProject.lean
├── MyProject/
│   ├── Basic.lean
│   ├── Logic.lean
│   └── Nat.lean
└── Main.lean
```

You can think of the modules as:

$$
\mathsf{Main}
\rightarrow
\{\mathsf{MyProject.Basic},\mathsf{MyProject.Logic}\}
\rightarrow
\mathsf{Mathlib}
$$

The directory structure gives the module namespace.

---

# 2. Importing files

If:

```text
MyProject/Basic.lean
```

contains:

```lean
def double (n : Nat) : Nat :=
  n + n
```

then `Main.lean` can do:

```lean
import MyProject.Basic

#eval double 10
```

The import name is based on the **module name**, not the `.lean` filename path:

```lean
import MyProject.Basic
```

not:

```lean
import MyProject/Basic.lean
```

---

# 3. Multiple files should form a DAG

For your exercises, I'd structure things roughly like:

```text
MyProject/
├── Foundations/
│   ├── Terms.lean
│   ├── Logic.lean
│   └── Equality.lean
├── Induction/
│   ├── Nat.lean
│   └── Lists.lean
└── Main.lean
```

Then:

```lean
-- Foundations/Logic.lean
import MyProject.Foundations.Terms
```

and:

```lean
-- Induction/Nat.lean
import MyProject.Foundations.Logic
```

while:

```lean
-- Main.lean
import MyProject.Induction.Nat
```

The important architectural rule is:

$$
A\text{ imports }B
\implies
B\text{ cannot depend on }A.
$$

So your Lean modules form a directed acyclic dependency graph.

This is exactly analogous to a typed dependency graph:

$$
\mathsf{Module}
\quad
\xrightarrow{\text{imports}}
\quad
\mathsf{Module}.
$$

---

# 4. Namespaces

Suppose `Basic.lean` contains:

```lean
namespace MyProject.Basic

def double (n : Nat) : Nat :=
  n + n

def triple (n : Nat) : Nat :=
  n + n + n

end MyProject.Basic
```

Then elsewhere:

```lean
import MyProject.Basic

#check MyProject.Basic.double
```

You can open the namespace:

```lean
open MyProject.Basic

#check double
```

Or use:

```lean
namespace MyProject

def double (n : Nat) :=
  n + n

end MyProject
```

Namespaces are primarily **name organization**, not object-oriented classes.

---

# 5. Basic Lean syntax

## Definitions

```lean
def double (n : Nat) : Nat :=
  n + n
```

Mathematically:

$$
\operatorname{double}:\mathbb N\to\mathbb N.
$$

You can omit the return type when Lean can infer it:

```lean
def double (n : Nat) :=
  n + n
```

But while learning, I'd usually write it explicitly.

---

## Functions

```lean
def square (n : Nat) : Nat :=
  n * n
```

Anonymous functions:

```lean
fun n : Nat => n + 1
```

So:

```lean
#check fun n : Nat => n + 1
```

has type:

```text
Nat → Nat
```

and this:

```lean
def increment : Nat → Nat :=
  fun n => n + 1
```

is equivalent to:

```lean
def increment (n : Nat) : Nat :=
  n + 1
```

---

# 6. Function application

Lean uses whitespace:

```lean
f x
```

not:

```text
f(x)
```

For multiple arguments:

```lean
f x y
```

which means:

$$
(f\ x)\ y.
$$

This is curried application.

For example:

```lean
def add (a : Nat) (b : Nat) : Nat :=
  a + b
```

has type:

$$
\mathsf{Nat}\to\mathsf{Nat}\to\mathsf{Nat}.
$$

---

# 7. Variables

```lean
variable (n : Nat)

#check n
```

Within a namespace/file, you can establish reusable variables:

```lean
variable {α : Type}
variable (x : α)
```

The braces matter.

```lean
(x : α)
```

is an explicit argument.

```lean
{x : α}
```

is an **implicit argument**.

For example:

```lean
def identity {α : Type} (x : α) : α :=
  x
```

Then Lean can infer `α`:

```lean
#check identity 10
#check identity "hello"
```

Conceptually:

$$
\mathsf{id} :
\Pi\{\alpha:\mathsf{Type}\},\alpha\to\alpha.
$$

---

# 8. Structures

```lean
structure Point where
  x : Int
  y : Int
```

Construct:

```lean
def p : Point :=
  { x := 3
    y := 4 }
```

Access:

```lean
#eval p.x
```

This corresponds roughly to a record/product with named fields.

---

# 9. Inductive types

You'll use these constantly.

```lean
inductive MyBool where
  | false
  | true
```

Constructors:

```lean
MyBool.false
MyBool.true
```

Pattern matching:

```lean
def negate : MyBool → MyBool
  | MyBool.false => MyBool.true
  | MyBool.true  => MyBool.false
```

Another important example:

```lean
inductive Color where
  | red
  | green
  | blue
```

This creates a type with exactly those constructors.

---

# 10. Propositions

Lean's propositions are types:

```lean
#check True
#check False
#check And
#check Or
```

For example:

```lean
example (P Q : Prop) : P → Q → P := by
  intro hp
  intro hq
  exact hp
```

But remember the proof term underneath:

```lean
example (P Q : Prop) : P → Q → P :=
  fun hp => fun hq => hp
```

This is much more important for you than memorizing tactics.

---

# 11. The basic proof syntax

### `intro`

For:

```lean
P → Q
```

introduce the assumption:

```lean
example (P Q : Prop) : P → Q := by
  intro hp
```

Now the context contains:

```text
hp : P
⊢ Q
```

### `exact`

Give Lean a term of the goal:

```lean
example (P : Prop) : P → P := by
  intro hp
  exact hp
```

### `apply`

If you have:

```lean
h : P → Q
```

and goal:

```text
⊢ Q
```

then:

```lean
apply h
```

changes the goal to:

```text
⊢ P
```

### `constructor`

For conjunction:

```lean
example (P Q : Prop) : P → Q → P ∧ Q := by
  intro hp
  intro hq
  constructor
  · exact hp
  · exact hq
```

---

# 12. Equality

```lean
example (n : Nat) : n = n := by
  rfl
```

You can rewrite:

```lean
example (a b : Nat) (h : a = b) : a + 1 = b + 1 := by
  rw [h]
```

And chain equalities:

```lean
example (a b c : Nat)
    (h₁ : a = b)
    (h₂ : b = c) :
    a = c := by
  calc
    a = b := h₁
    _ = c := h₂
```

`calc` is worth learning early because it corresponds closely to ordinary mathematical reasoning.

---

# 13. Comments and commands

Comments:

```lean
-- single line

/-
multi-line
comment
-/
```

Useful commands:

```lean
#check Nat
#check Nat.add
#eval 2 + 3
#print double
```

`#check` asks for a type.

`#eval` evaluates executable expressions.

`#print` shows the declaration Lean has constructed.

---

# 14. Your first multi-file exercise project

I'd actually recommend you create this:

```text
lean-playground/
├── lakefile.toml
├── Main.lean
└── LeanPlayground/
    ├── Basics.lean
    ├── Logic.lean
    ├── Equality.lean
    └── Induction.lean
```

### `Basics.lean`

```lean
namespace LeanPlayground.Basics

def double (n : Nat) : Nat :=
  n + n

def square (n : Nat) : Nat :=
  n * n

end LeanPlayground.Basics
```

### `Logic.lean`

```lean
namespace LeanPlayground.Logic

example (P Q : Prop) : P → Q → P := by
  intro hp
  intro hq
  exact hp

end LeanPlayground.Logic
```

### `Main.lean`

```lean
import LeanPlayground.Basics
import LeanPlayground.Logic

open LeanPlayground.Basics

#check double
#check square

#eval double 21
#eval square 5
```

Then run from the project root:

```bash
lake env lean Main.lean
```

or, if your Lake project has the executable configured:

```bash
lake run
```

---

## The mental model I'd use

For now, keep these four layers separate:

$$
\boxed{
\text{Lake}
\rightarrow
\text{modules/imports}
\rightarrow
\text{declarations}
\rightarrow
\text{terms/types/proofs}
}
$$

Lake manages the **project/build graph**.

Lean's module system manages the **declaration/import graph**.

The type theory manages:

$$
\boxed{
\text{terms}
\quad
\text{types}
\quad
\text{contexts}
\quad
\text{judgments}
\quad
\text{proofs}
}
$$

And this gives you a very clean progression for your local exercises:

$$
\text{files/imports}
\rightarrow
\text{functions}
\rightarrow
\text{inductive types}
\rightarrow
\text{propositions}
\rightarrow
\text{equality}
\rightarrow
\text{induction}
\rightarrow
\text{dependent types}.
$$

For your particular background, I'd make `LeanPlayground/` a **formal type-theory laboratory** rather than immediately starting Mathlib: manually implement tiny versions of `And`, `Or`, existential types, equality, natural numbers, lists, and their eliminators, then inspect the generated declarations with `#print`. That will connect the set-theoretic judgment model you've just developed directly to actual Lean.
