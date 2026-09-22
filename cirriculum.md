**Intent: implementation-backed foundations curriculum.** Yes. In fact, I’d recommend using **Lean locally as the laboratory**, while learning the calculi independently of Lean first. Lean is useful for checking that your derivations and encodings actually work, but you don't want Lean's elaborator to hide the underlying rules.

The first stage should be:

$$
\boxed{
\lambda\text{-calculus}
\rightarrow
\text{STLC}
\rightarrow
\text{System F}
\rightarrow
\text{dependent types}
}
$$

## Stage 0 — Untyped λ-calculus

**Goal:** understand terms and computation before types.

Learn:

$$
t ::= x\mid \lambda x.t\mid t\;t
$$

and:

* α-equivalence
* β-reduction
* substitution
* free/bound variables
* normal forms
* confluence
* Church numerals
* combinators

### Exercises

1. Compute:

$$
(\lambda x.x)\;y
$$

2. Reduce:

$$
(\lambda x.\lambda y.x)\;a\;b.
$$

3. Find the free variables of:

$$
\lambda x.(x\;y).
$$

4. α-convert:

$$
\lambda x.\lambda y.x
$$

without accidentally capturing a variable.

5. Define:

$$
\mathsf{true}=\lambda x.\lambda y.x
$$

$$
\mathsf{false}=\lambda x.\lambda y.y
$$

and construct `if`.

### Challenge

Prove for yourself:

> β-reduction changes computation but α-conversion does not change the meaning of a term.

---

# Stage 1 — Simply Typed λ-calculus

Now introduce:

$$
A ::= \alpha\mid A\to A\mid A\times A\mid\cdots
$$

and judgments:

$$
\Gamma\vdash t:A.
$$

Start with only:

$$
\frac{x:A\in\Gamma}{\Gamma\vdash x:A}
$$

$$
\frac{\Gamma,x:A\vdash t:B}
{\Gamma\vdash\lambda x.t:A\to B}
$$

$$
\frac{\Gamma\vdash f:A\to B\qquad\Gamma\vdash a:A}
{\Gamma\vdash f\,a:B}.
$$

### Exercises

Derive the typing judgment for:

$$
\lambda x.x.
$$

Then:

$$
\lambda f.\lambda x.f(x).
$$

Then:

$$
\lambda f.\lambda g.\lambda x.f(g(x)).
$$

---

### Important exercise: distinguish syntax from typing

Given:

$$
\lambda x.x
$$

ask:

1. Is it a term?
2. Is it a type?
3. Does it have a type?
4. Is its type unique?

You want to become extremely comfortable with:

$$
\text{term}
\neq
\text{type}
\neq
\text{typing judgment}.
$$

---

# Stage 2 — STLC metatheory

This is where I'd slow down.

Learn:

### Weakening

If

$$
\Gamma\vdash t:A
$$

then under suitable conditions:

$$
\Gamma,x:B\vdash t:A.
$$

### Substitution

If:

$$
\Gamma,x:A\vdash t:B
$$

and:

$$
\Gamma\vdash u:A
$$

then:

$$
\Gamma\vdash t[u/x]:B[u/x].
$$

This is one of the **central theorems of type theory**.

### Subject reduction

If:

$$
\Gamma\vdash t:A
$$

and

$$
t\to_\beta t',
$$

then:

$$
\Gamma\vdash t':A.
$$

### Progress

A closed well-typed term is either a value or can take a reduction step.

Together:

$$
\boxed{\text{preservation + progress}}
$$

give you the classic type-safety result.

---

# Stage 3 — STLC as mathematics

Now deliberately translate between representations.

Learn these correspondences:

$$
A\times B
$$

as products,

$$
A\to B
$$

as exponentials,

and:

$$
\lambda x.t
$$

as the categorical transpose/curry operation.

Your challenge is to understand:

$$
\operatorname{Hom}(A\times B,C)
\cong
\operatorname{Hom}(A,B\to C).
$$

At this point you'll see why:

$$
\text{STLC}\leftrightarrow\text{CCC}
$$

isn't just an analogy.

---

# Stage 4 — System F

Now add **type abstraction**.

Terms acquire:

$$
\Lambda A.t
$$

and type application:

$$
t[B].
$$

Types acquire:

$$
\forall A.B.
$$

The fundamental rules become approximately:

$$
\frac{\Gamma,A\;\text{type}\vdash t:B}
{\Gamma\vdash\Lambda A.t:\forall A.B}
$$

and

$$
\frac{\Gamma\vdash t:\forall A.B}
{\Gamma\vdash t[C]:B[C/A]}.
$$

---

## First System F exercise

Construct polymorphic identity:

$$
\mathsf{id}
=
\Lambda A.\lambda x:A.x.
$$

Derive:

$$
\vdash
\mathsf{id}
:
\forall A.A\to A.
$$

Then instantiate it:

$$
\mathsf{id}[\mathbb N]
$$

and determine its type.

---

# Stage 5 — The big conceptual challenge: term vs type abstraction

Compare:

$$
\lambda x:A.x
$$

with:

$$
\Lambda A.\lambda x:A.x.
$$

The first abstracts over:

$$
x:A.
$$

The second abstracts over:

$$
A:\mathcal U.
$$

So ask:

> What exactly changed in the syntax, context, reduction rules, and typing rules?

This is the conceptual bridge from STLC to System F.

---

# Stage 6 — System F parametricity

Now study:

$$
f:\forall A.A\to A.
$$

Challenge:

> What implementations are possible?

Then:

$$
f:\forall A.(A\to A)\to(A\to A).
$$

What can $f$ do?

Then:

$$
f:\forall A.\forall B.(A\to B)\to A\to B.
$$

What information does $f$ have available?

This should lead you toward **free theorems / parametricity**.

The key idea:

$$
\boxed{
\text{polymorphism restricts behavior}
}
$$

rather than merely increasing code reuse.

---

# Stage 7 — System F metatheory

Prove/work through:

1. weakening
2. substitution
3. type substitution
4. preservation
5. normalization
6. type erasure

Especially understand **type erasure**:

$$
\Lambda A.t
\longrightarrow
t
$$

at runtime, conceptually.

This gives you the separation:

$$
\text{compile-time type computation}
\neq
\text{runtime term computation}.
$$

---

# Stage 8 — Compare all three

You should eventually be able to explain this without notes:

$$
\begin{array}{c|c|c}
&\text{STLC}&\text{System F}\\
\hline
\text{term abstraction}&\lambda x.t&\lambda x.t\\
\text{type abstraction}&-&\Lambda A.t\\
\text{type application}&-&t[A]\\
\text{polymorphism}&-&\forall A.A\\
\text{dependent types}&-&-\\
\text{equality}&\text{β}&\text{β + type β}
\end{array}
$$

And then answer:

> **Why isn't System F already dependent type theory?**

That is a very good checkpoint before moving on.

---

# Yes: use local Lean

I would actually build **three tiny Lean exercises**, rather than immediately using Lean's full dependent type system.

You can make a project with:

```bash
lake new type-theory-lab
cd type-theory-lab
lake build
```

Then use Lean to represent progressively richer fragments.

However, there is one important caveat:

**Lean is not an implementation of STLC or System F.**

Lean is a much richer dependent type theory. So if you write:

```lean
#check fun x => x
```

Lean will happily infer polymorphism/dependent information that isn't part of your deliberately restricted STLC calculus.

Therefore I'd use Lean as a **checker/laboratory**, not as the definition of the theory.

---

# Exercise lab 1: encode STLC yourself

Start by defining your own syntax:

```lean
inductive Ty where
  | base : String → Ty
  | arr  : Ty → Ty → Ty
```

and terms:

```lean
inductive Tm where
  | var : Nat → Tm
  | app : Tm → Tm → Tm
  | lam : Ty → Tm → Tm
```

Now you have your own object language:

$$
\boxed{
\text{Lean is the metalanguage}
}
$$

and your inductive definitions represent:

$$
\boxed{
\text{STLC is the object language}.
}
$$

This distinction is **extremely valuable**.

---

## Exercise 1

Define contexts:

```lean
abbrev Ctx := List Ty
```

Then define:

```lean
HasType : Ctx → Tm → Ty → Prop
```

and implement the three rules:

$$
\frac{x:A\in\Gamma}
{\Gamma\vdash x:A}
$$

$$
\frac{\Gamma,A\vdash t:B}
{\Gamma\vdash\lambda x:A.t:A\to B}
$$

$$
\frac{\Gamma\vdash f:A\to B\qquad\Gamma\vdash x:A}
{\Gamma\vdash f\,x:B}.
$$

Don't use Lean's own function types for the object language.

---

# Exercise lab 2: prove STLC metatheory

Once `HasType` works, try proving:

$$
\boxed{\text{weakening}}
$$

then:

$$
\boxed{\text{substitution}}
$$

then:

$$
\boxed{\text{preservation}}.
$$

This is where the exercise becomes genuinely valuable.

You'll discover that **variable representation is not an incidental implementation detail**.

You'll have to confront:

* de Bruijn indices
* shifting
* substitution
* contexts
* weakening
* dependent substitutions later.

That is exactly the kind of difficulty you want to encounter before dependent type theory.

---

# Exercise lab 3: extend the syntax to System F

Add:

```lean
| tyVar : Nat → Ty
| all   : Ty → Ty
```

and:

```lean
| tyLam : Tm → Tm
| tyApp : Tm → Ty → Tm
```

Then define:

$$
\mathsf{id}
=
\Lambda A.\lambda x:A.x.
$$

and prove your own object-language judgment:

$$
\vdash \mathsf{id}:\forall A.A\to A.
$$

Again:

**don't use Lean's `∀` or polymorphic functions to represent the object language.**

You're implementing System F *inside* Lean.

---

# The progression I'd use

Your actual curriculum becomes:

$$
\boxed{
\begin{array}{c}
\text{Untyped λ-calculus}\\
\downarrow\\
\text{STLC syntax}\\
\downarrow\\
\text{STLC typing}\\
\downarrow\\
\text{STLC reduction}\\
\downarrow\\
\text{Weakening}\\
\downarrow\\
\text{Substitution}\\
\downarrow\\
\text{Preservation + Progress}\\
\downarrow\\
\text{Cartesian closed semantics}\\
\downarrow\\
\text{System F syntax}\\
\downarrow\\
\text{System F typing}\\
\downarrow\\
\text{Type substitution}\\
\downarrow\\
\text{Parametricity}\\
\downarrow\\
\text{Normalization}\\
\downarrow\\
\text{Dependent TT}
\end{array}
}
$$

And I would **not move to dependent types until you can implement and prove the basic metatheory of STLC and at least type-check a small System F interpreter in Lean**.

That will make the eventual transition to

$$
\Pi,\quad\Sigma,\quad\mathsf{Id},\quad\mathcal U
$$

much more meaningful, because you'll know exactly which new dependency each construction introduces.
