**Intent classification: formal-methods onboarding / dependent type theory → practical Lean workflow.**

Given your recent focus on **Calculus of Constructions, System F, propositions-as-types, category theory, and formalization**, I would *not* learn Lean primarily as a bag of tactics. Learn it in this order:

$$
\text{Lean syntax}
\rightarrow
\text{dependent type theory}
\rightarrow
\text{proof terms}
\rightarrow
\text{inductive types}
\rightarrow
\text{tactics}
\rightarrow
\text{Mathlib}
$$

Lean 4 is based on a dependent type theory in the Calculus-of-Constructions family with inductive types, and its kernel checks elaborated proof terms. ([Lean Language][1])

## 1. Install Lean

The official recommendation is:

1. VS Code
2. official **Lean 4** VS Code extension
3. let the extension install/manage the Lean toolchain

The current official installation guide recommends exactly this workflow. ([Lean Language][2])

Then create:

```text
lean-playground/
└── Main.lean
```

Start with:

```lean
#eval 1 + 2

#check Nat
#check Nat.succ
#check 1
```

Then:

```lean
def double (n : Nat) : Nat :=
  n + n

#check double
#eval double 21
```

Your first mental model should be:

$$
\text{Lean program} = \text{term}
$$

and

$$
\text{Lean type} = \text{judgment about a term}.
$$

So:

```lean
#check double
```

is essentially asking Lean to establish

$$
\Gamma \vdash \operatorname{double} : \mathsf{Nat} \to \mathsf{Nat}.
$$

---

# 2. First understand Lean's core language

Don't immediately jump into `simp`, `linarith`, `aesop`, etc.

Learn these primitives:

| Concept            | Lean            | Type-theoretic meaning                   |
| ------------------ | --------------- | ---------------------------------------- |
| function           | `f : A → B`     | dependent function in non-dependent case |
| dependent function | `(x : A) → B x` | Π-type                                   |
| pair               | `A × B`         | product                                  |
| dependent pair     | `Σ x : A, B x`  | Σ-type                                   |
| proposition        | `P : Prop`      | type of proofs                           |
| proof              | `p : P`         | term inhabiting `P`                      |
| equality           | `a = b`         | identity/equality type                   |
| inductive type     | `inductive`     | freely generated type                    |
| universe           | `Type u`        | type hierarchy                           |

The critical Curry–Howard correspondence is:

$$
\boxed{
\text{proposition} \leftrightarrow \text{type}
}
$$

$$
\boxed{
\text{proof} \leftrightarrow \text{term}
}
$$

$$
\boxed{
\text{proving }P \leftrightarrow \text{constructing }p:P
}
$$

Lean's official theorem-proving book explicitly develops this starting with dependent type theory and then propositions-as-types. ([Lean Language][3])

---

# 3. Do propositions-as-types manually

Start here rather than tactics.

```lean
example (P Q : Prop) : P → Q → P := by
  intro hp
  intro hq
  exact hp
```

Then understand what the proof *really* is:

```lean
example (P Q : Prop) : P → Q → P :=
  fun hp =>
    fun hq =>
      hp
```

That is literally a function:

$$
P \to (Q \to P).
$$

The proof is a lambda term.

Then:

```lean
example (P Q : Prop) : P ∧ Q → Q ∧ P :=
  fun h =>
    And.intro h.right h.left
```

Categorically/type-theoretically, you're learning that:

$$
P \land Q
$$

behaves like a product:

$$
P \times Q.
$$

A proof of `P ∧ Q` contains both a proof of `P` and a proof of `Q`.

---

# 4. Learn the Π/Σ viewpoint

This is especially important given what you've been studying.

Non-dependent function:

```lean
A → B
```

is a special case of:

```lean
(x : A) → B x
```

which is a **Π-type**.

Likewise:

```lean
A × B
```

is the non-dependent analogue of:

```lean
(x : A) × B x
```

which is a **Σ-type**.

So your initial conceptual hierarchy should be:

$$
\begin{aligned}
A \to B &\quad\text{Π-type, non-dependent}\\
A \times B &\quad\text{Σ-type, non-dependent}\\
P : Prop &\quad\text{a type whose inhabitants are proofs}\\
p : P &\quad\text{a proof term}
\end{aligned}
$$

This will make Lean feel much less like a mysterious proof scripting language.

---

# 5. Then inductive types

This is where Lean becomes particularly interesting.

Try:

```lean
inductive MyBool where
  | false
  | true
```

You have constructed a type

$$
\mathsf{MyBool}
$$

with two constructors:

$$
\mathsf{false} : \mathsf{MyBool}
$$

and

$$
\mathsf{true} : \mathsf{MyBool}.
$$

Then:

```lean
def negate : MyBool → MyBool
  | MyBool.false => MyBool.true
  | MyBool.true  => MyBool.false
```

The important conceptual point is:

> **Inductive definitions generate both data and their elimination principles.**

This becomes the foundation for understanding pattern matching, recursion, and induction. The official TPIL chapter emphasizes that constructors and recursors are fundamental to defining functions and proving properties of inductive types. ([Lean Language][4])

---

# 6. Then equality

Spend a surprising amount of time here.

```lean
example (n : Nat) : n = n := by
  rfl
```

Understand `rfl` as construction of reflexivity.

Then:

```lean
example (a b : Nat) (h : a = b) : b = a := by
  exact h.symm
```

And:

```lean
example (a b c : Nat) (hab : a = b) (hbc : b = c) : a = c := by
  exact hab.trans hbc
```

Your mental model should be:

$$
\operatorname{Eq}(a,b)
$$

is itself a type.

So equality proofs are objects inhabiting an equality type.

This is the gateway into dependent type theory rather than merely conventional first-order logic.

---

# 7. Only then learn tactics

Now learn:

```text
intro
exact
apply
constructor
rw
rfl
simp
cases
induction
have
show
calc
```

For example:

```lean
example (a b c : Nat)
    (h₁ : a = b)
    (h₂ : b = c) :
    a = c := by
  calc
    a = b := h₁
    _ = c := h₂
```

Notice that tactics are really **proof-term construction interfaces**.

Conceptually:

$$
\text{tactic script}
\longrightarrow
\text{elaborated proof term}
\longrightarrow
\text{kernel checking}.
$$

That's the architecture you should keep in your head.

---

# 8. Then learn programming + proving together

I'd next work through **Functional Programming in Lean**. The official book is explicitly aimed at programmers and covers Lean programming, type classes, monads, functors/applicatives, dependent types, and then programming/proving together. ([Lean Language][5])

This fits your Rust/OCaml background particularly well.

The progression I'd use:

$$
\begin{array}{c}
\text{functions}\\
\downarrow\\
\text{inductive data}\\
\downarrow\\
\text{pattern matching}\\
\downarrow\\
\text{recursion}\\
\downarrow\\
\text{dependent types}\\
\downarrow\\
\text{proofs}
\end{array}
$$

---

# 9. Then Theorem Proving in Lean 4

Use **Theorem Proving in Lean 4** as the main theory/proof text.

Its current structure is almost exactly the curriculum I'd recommend:

1. Introduction
2. Dependent Type Theory
3. Propositions and Proofs
4. Quantifiers and Equality
5. Tactics
6. Interacting with Lean
7. Inductive Types
8. Induction and Recursion
9. Structures and Records
10. Type Classes
11. Conversion Tactic Mode
12. Axioms and Computation ([Lean Language][3])

[Theorem Proving in Lean 4](https://lean-lang.org/theorem_proving_in_lean4/?utm_source=chatgpt.com)

I would **actually read chapters 2–4 carefully**, rather than skim them.

---

# 10. Your first serious exercise sequence

I would structure your first ~20 hours like this.

### Phase A — Terms

Write:

```lean
def identity ...
def compose ...
def const ...
def flip ...
```

and prove their types.

Think in:

$$
\lambda\text{-calculus} + \text{types}.
$$

### Phase B — Logic

Prove manually:

```text
P → P

P → Q → P

P ∧ Q → Q ∧ P

P ∧ (Q ∧ R) → (P ∧ Q) ∧ R

(P → Q) → (Q → R) → P → R
```

Initially avoid automation.

### Phase C — Quantifiers

Prove:

```text
∀ x, P x → P x

(∀ x, P x ∧ Q x) → (∀ x, P x) ∧ (∀ x, Q x)
```

Now you're explicitly manipulating Π-types.

### Phase D — Equality

Prove:

```text
a = a

a = b → b = a

a = b → b = c → a = c

a = b → f a = f b
```

The last one is particularly important:

$$
a=b
\implies
f(a)=f(b).
$$

### Phase E — Induction

Define your own recursive functions over `Nat` and prove properties about them.

For example:

```lean
def double : Nat → Nat
  | 0 => 0
  | n + 1 => double n + 2
```

Then prove something like:

```text
double n = n + n
```

using induction.

This is where you start understanding the correspondence:

$$
\text{recursive definition}
\leftrightarrow
\text{inductive structure}
\leftrightarrow
\text{inductive proof}.
$$

---

# 11. Then Mathlib

**Don't start with Mathlib.**

Once you understand core Lean, move into **Mathematics in Lean**.

The official Lean learning page currently recommends:

* **Functional Programming in Lean** → programming
* **Theorem Proving in Lean 4** → dependent type theory + proving
* **Mathematics in Lean** → mathematical formalization with Mathlib ([Lean Language][6])

That gives you three distinct layers:

$$
\boxed{\text{Lean core}}
\rightarrow
\boxed{\text{dependent type theory}}
\rightarrow
\boxed{\text{Mathlib}}
$$

Don't confuse them.

---

## The curriculum I'd give *you*

Given your existing background, I'd compress the beginner material substantially:

| Stage | Topic                           |    Depth |
| ----- | ------------------------------- | -------: |
| 1     | Lean syntax / VS Code           |    1–2 h |
| 2     | λ-calculus + Π-types            | **deep** |
| 3     | `Prop`, proofs, Curry–Howard    | **deep** |
| 4     | equality types                  | **deep** |
| 5     | inductive types                 | **deep** |
| 6     | recursion / induction           | **deep** |
| 7     | structures / type classes       |   medium |
| 8     | tactics                         |   medium |
| 9     | Mathlib                         | **deep** |
| 10    | category theory in Lean         |    later |
| 11    | formalized algebra              |    later |
| 12    | formal verification of programs |    later |

And I would explicitly **not** spend weeks learning ordinary functional programming syntax first. You already have enough programming background that the interesting bottleneck for you is the **type-theoretic boundary between terms, types, propositions, proofs, and dependent types**.

A particularly good 2–3 hour "just show me what Lean feels like" alternative is Patrick Massot's *A Glimpse of Lean*, which is specifically designed as an impatient introduction before committing to a longer course. ([Reservoir][7])

[A Glimpse of Lean](https://reservoir.lean-lang.org/%40PatrickMassot/GlimpseOfLean?utm_source=chatgpt.com)

### One principle to keep throughout

Don't think:

> "How do I make Lean accept this proof?"

Think:

$$
\boxed{
\text{What term inhabits this type?}
}
$$

Then tactics become an **interface for constructing that term**, rather than the thing you're fundamentally learning.

[1]: https://lean-lang.org/theorem_proving_in_lean4/Introduction/?utm_source=chatgpt.com "Introduction"
[2]: https://lean-lang.org/install/?utm_source=chatgpt.com "Install — Lean Lang"
[3]: https://lean-lang.org/theorem_proving_in_lean4/index.html?utm_source=chatgpt.com "Theorem Proving in Lean 4"
[4]: https://lean-lang.org/theorem_proving_in_lean4/Induction-and-Recursion/?utm_source=chatgpt.com "Induction and Recursion"
[5]: https://lean-lang.org/functional_programming_in_lean/?search=TPP2026+theorem+proving&utm_source=chatgpt.com "Functional Programming in Lean"
[6]: https://lean-lang.org/learn/?utm_source=chatgpt.com "Learn — Lean Lang"
[7]: https://reservoir.lean-lang.org/%40PatrickMassot/GlimpseOfLean?utm_source=chatgpt.com "glimpseOfLean | Reservoir"
