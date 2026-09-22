Yes — you're very close. There are **three distinctions** worth tightening.

### 1. Judgment ↔ membership in a relation

Your formulation is exactly the right set-theoretic encoding:

$$
\boxed{
\Gamma\vdash t:A
\quad\Longleftrightarrow\quad
(\Gamma,t,A)\in\mathsf{Typing}
}
$$

where

$$
\mathsf{Typing}\subseteq
\mathsf{Ctx}\times\mathsf{Term}\times\mathsf{Type}.
$$

The only caveat is that this is a **meta-level representation** of the judgment. We are modeling the judgment as membership in a set-theoretic relation.

---

### 2. `HasType` is usually a relation, not necessarily a function

You suggested:

> `HasType` is a function graph `(term, type)`?

Almost. I'd call it a **relation** first:

$$
\mathsf{HasType}\subseteq
\mathsf{Term}\times\mathsf{Type}.
$$

Then

$$
(t,A)\in\mathsf{HasType}
$$

means

$$
t:A.
$$

It *could* be the graph of a function if your type theory guarantees that every term has exactly one type:

$$
\mathsf{type}:\mathsf{Term}\rightharpoonup\mathsf{Type}.
$$

But dependent type theory is usually presented relationally because:

* typing is parameterized by $\Gamma$;
* not every syntactic term is well-typed;
* definitional equality means several type expressions can be interchangeable.

So I would keep:

$$
\boxed{\mathsf{Typing}\text{ = relation}}
$$

until you specifically want to exploit uniqueness-of-types.

---

### 3. Definitional equality is **not quite binding** `t` to `u`

This is the important correction.

If you have

$$
\Gamma\vdash t\equiv u:A,
$$

then you are saying:

> **Within context $\Gamma$, `t` and `u` are definitionally the same term of type `A`.**

Set-theoretically:

$$
\mathsf{DefEq}
\subseteq
\mathsf{Ctx}\times\mathsf{Term}\times\mathsf{Term}\times\mathsf{Type}.
$$

Thus:

$$
(\Gamma,t,u,A)\in\mathsf{DefEq}.
$$

It is better thought of as an **equivalence relation induced by computation/conversion**, rather than a binding.

For example, if

```lean
def double (n : Nat) := n + n
```

then Lean can computationally recognize something like

```lean
double 3
```

as definitionally equal to

```lean
3 + 3
```

without you having to prove a theorem.

So:

$$
t\equiv u
$$

is roughly:

$$
\boxed{\text{“these two syntactic terms compute/convert to the same thing.”}}
$$

whereas a theorem

$$
\Gamma\vdash t=u
$$

is a **proposition that requires a proof term**.

That distinction is extremely important:

$$
\underbrace{t\equiv u}_{\text{definitional equality}}
\qquad\neq\qquad
\underbrace{t=u}_{\text{propositional equality}}.
$$

---

# 4. Your intuition about $\Gamma$ is basically right, but with one correction

You said:

> left of judgment is like everything accepted to be true so far

This is **very close**, but $\Gamma$ isn't literally "everything true so far."

It is better to say:

$$
\boxed{
\Gamma=\text{the local typing assumptions currently in scope}
}
$$

For example:

$$
\Gamma =
(x:\mathsf{Nat},\quad
f:\mathsf{Nat}\to\mathsf{Nat},\quad
h:P(x)).
$$

Then:

$$
\Gamma\vdash f(x):\mathsf{Nat}
$$

means:

> Given these assumptions/declarations, `f(x)` has type `Nat`.

So $\Gamma$ is more like a **finite typed environment** than a set of all truths.

---

# 5. What about imported Coq/Lean lemmas?

This is where your intuition becomes interesting.

Suppose you have:

```lean
theorem add_zero (n : Nat) : n + 0 = n := ...
```

After the theorem has been defined, you have a constant:

$$
\mathsf{add\_zero}:
\Pi(n:\mathsf{Nat}),\;n+0=n.
$$

So the global environment contains something like:

$$
\mathcal E =
\{
\mathsf{Nat},
\mathsf{add},
\mathsf{add\_zero},
\ldots
\}.
$$

And the local context might be:

$$
\Gamma=(n:\mathsf{Nat}).
$$

Thus the overall situation is better represented as:

$$
\boxed{
\mathcal E;\Gamma\vdash t:A
}
$$

where:

* $\mathcal E$ = **global environment**: imported/defined constants, declarations, inductive types, theorems, etc.
* $\Gamma$ = **local context**: variables and hypotheses currently in scope.

This distinction is particularly useful for understanding Lean.

---

# 6. So there are actually two "sets of accepted things"

You can model it approximately as:

$$
\mathcal E
=
\{\text{globally declared constants/types/theorems}\}
$$

and

$$
\Gamma
=
\{\text{locally bound variables/assumptions}\}.
$$

For example:

$$
\mathcal E=
\{
\mathsf{Nat}:\mathsf{Type},
\mathsf{zero}:\mathsf{Nat},
\mathsf{succ}:\mathsf{Nat}\to\mathsf{Nat},
\mathsf{add}:\mathsf{Nat}\to\mathsf{Nat}\to\mathsf{Nat},
\mathsf{add\_zero}:\Pi n:\mathsf{Nat},n+0=n
\}
$$

while:

$$
\Gamma=
\{
n:\mathsf{Nat}
\}.
$$

Then:

$$
\mathcal E;\Gamma\vdash
\mathsf{add\_zero}(n):n+0=n.
$$

This is very close to how you should mentally model a Lean/Coq development.

---

## The clean hierarchy

I'd now use this mental model:

$$
\boxed{
\mathcal E;\Gamma\vdash t:A
}
$$

means

> Under global declarations $\mathcal E$ and local assumptions $\Gamma$, the term $t$ has type $A$.

Set-theoretically, you can model this as:

$$
(\mathcal E,\Gamma,t,A)\in\mathsf{Typing}.
$$

Then:

$$
(\mathcal E,\Gamma,t,u,A)\in\mathsf{DefEq}
$$

means $t$ and $u$ are definitionally equal at $A$.

And a theorem is itself just a term:

$$
p:P.
$$

So the really beautiful part of Curry–Howard is:

$$
\boxed{
\text{a theorem stored in the environment is literally a named term with a proposition as its type.}
}
$$

For example:

$$
\mathsf{add\_zero} :
\Pi n:\mathsf{Nat},\; n+0=n.
$$

It's simultaneously:

* a **constant** in the global environment,
* a **term**,
* whose **type is a proposition**,
* and therefore a **proof of that proposition**.

That's the bridge you're looking for between **sets/relations → judgments → contexts → Lean/Coq environments → Curry–Howard**.
