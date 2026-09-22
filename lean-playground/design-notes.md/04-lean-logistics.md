**Intent: Lean engineering model — understand the repository, build system, package manager, editor, elaborator, and proof workflow as one system.**

If you're coming from Rust, the easiest mapping is:

$$
\boxed{
\text{Lean project}
\approx
\text{Cargo project}
}
$$

but Lean's build/package layer is **Lake**, rather than Cargo.

## 1. The basic repository

A typical Lean project looks roughly like:

```text
my-project/
├── lakefile.toml
├── lake-manifest.json
├── MyProject/
│   ├── Basic.lean
│   ├── Algebra.lean
│   └── ...
├── MyProject.lean
└── Main.lean
```

The important pieces are:

| File                 | Role                                    |
| -------------------- | --------------------------------------- |
| `lakefile.toml`      | project/build/package configuration     |
| `lake-manifest.json` | resolved dependency versions            |
| `.lean`              | Lean source modules                     |
| `Main.lean`          | often an executable/example entry point |
| `.lake/`             | generated build/dependency artifacts    |

The analogy is approximately:

$$
\begin{array}{ccc}
\text{Rust} & & \text{Lean}\\
\hline
Cargo.toml &\leftrightarrow& lakefile.toml\\
Cargo.lock &\leftrightarrow& lake-manifest.json\\
src/*.rs &\leftrightarrow& *.lean\\
cargo build &\leftrightarrow& lake build\\
cargo run &\leftrightarrow& lake env lean / lake exe\\
crates.io &\leftrightarrow& \text{Lake packages / Reservoir}
\end{array}
$$

---

# 2. Lake is the underlying project/build system

**Lake** is Lean's build system and package manager.

For example:

```bash
lake new my-project
cd my-project
lake build
```

A project can declare dependencies such as Mathlib.

Conceptually:

$$
\text{Project}
\rightarrow
\text{dependency graph}
\rightarrow
\text{modules}
\rightarrow
\text{compiled artifacts}.
$$

This should feel familiar from Cargo.

The difference is that Lean projects care enormously about the **Lean toolchain version**, because compiled `.olean` artifacts are tied to the Lean/compiler environment.

---

# 3. Lean itself is not just "the compiler"

There are several layers.

A useful conceptual decomposition is:

$$
\boxed{
\text{Editor}
\rightarrow
\text{Language Server}
\rightarrow
\text{Elaborator}
\rightarrow
\text{Kernel}
}
$$

with Lake sitting around the project/build side.

### Editor

Usually VS Code.

You type:

```lean
example (n : Nat) : n = n := by
  rfl
```

### Language server

The Lean VS Code extension communicates with Lean's language server.

This gives you:

* diagnostics
* goals
* type information
* autocomplete
* hover information
* error locations
* incremental checking

This is why Lean feels much more interactive than running a traditional compiler.

---

# 4. The elaborator is where a lot of the magic happens

You write something relatively high-level:

```lean
example (P Q : Prop) : P ∧ Q → Q ∧ P := by
  intro h
  exact ⟨h.2, h.1⟩
```

But Lean ultimately needs a much more explicit term.

The **elaborator** fills in things you omitted:

* implicit arguments
* universe parameters
* coercions
* overloaded notation
* typeclass arguments
* metavariables
* expected types
* tactic-generated proof terms

So conceptually:

$$
\text{surface Lean}
\xrightarrow{\text{elaboration}}
\text{explicit term}
\xrightarrow{\text{kernel}}
\text{checked}.
$$

This distinction will become extremely important once you start studying Lean seriously.

---

# 5. The kernel is the trust boundary

This is the deepest architectural point.

The kernel checks the final term against the rules of Lean's type theory.

So:

$$
\boxed{
\text{tactics don't establish truth}
}
$$

They construct terms.

And:

$$
\boxed{
\text{the kernel checks the resulting term}.
}
$$

For example:

```lean
by
  intro h
  exact h
```

is essentially a program that constructs a proof term.

The kernel then checks:

$$
p:P.
$$

This gives you the famous small trusted core idea:

$$
\text{large automation}
\rightarrow
\text{proof term}
\rightarrow
\boxed{\text{small kernel}}
$$

---

# 6. `.lean` → `.olean`

When Lean builds a module, it produces an `.olean` file.

Very roughly:

```text
Basic.lean
    ↓
Lean elaboration
    ↓
Basic.olean
```

The `.olean` contains compiled information needed by other modules.

So if:

```lean
import MyProject.Basic
```

Lean does not generally re-elaborate the entire source file from scratch every time.

Instead it can consume the compiled module.

This is one reason large Mathlib developments can work incrementally.

---

# 7. Imports form a module DAG

Suppose:

```text
Main.lean
   ↓
Algebra.lean
   ↓
Basic.lean
```

Then:

$$
\mathsf{Basic}
\rightarrow
\mathsf{Algebra}
\rightarrow
\mathsf{Main}
$$

is a dependency relation.

More formally, if modules form a set

$$
\mathsf{Module},
$$

then imports induce a directed relation

$$
\mathsf{Imports}
\subseteq
\mathsf{Module}\times\mathsf{Module}.
$$

You can think of a Lean project as producing a **DAG of modules**, just as Rust's module/crate graph ultimately becomes a dependency graph.

---

# 8. Mathlib is just an enormous Lean project

This is worth internalizing.

Mathlib isn't some magical second language.

It's essentially:

$$
\boxed{\text{a gigantic collection of Lean modules}}
$$

containing:

* definitions
* theorems
* proofs
* instances
* notation
* tactics
* mathematical structures.

So when you write:

```lean
import Mathlib
```

you're importing an enormous pre-built environment.

More disciplined projects often import specific modules instead:

```lean
import Mathlib.Data.Nat.Basic
```

rather than the whole library.

---

# 9. The workflow you should use

For your learning, I'd recommend this loop:

$$
\boxed{
\text{edit}
\rightarrow
\text{elaborate}
\rightarrow
\text{inspect goal}
\rightarrow
\text{construct term}
\rightarrow
\text{kernel check}
\rightarrow
\text{refactor}
}
$$

For example:

```lean
example (P Q : Prop) : P ∧ Q → Q ∧ P := by
  intro h
```

Lean now exposes a goal approximately like:

```text
P Q : Prop
h : P ∧ Q
⊢ Q ∧ P
```

Your job is to transform the goal.

```lean
exact ⟨h.2, h.1⟩
```

Now there are no goals.

That's the interactive proof-development loop.

---

# 10. Useful commands to learn immediately

Inside Lean:

```lean
#check Nat
#check Nat.add
#check @Nat.add
#print Nat
#print someTheorem
#eval 1 + 2
```

Particularly important:

```lean
#check
```

Ask:

> What is the type of this object?

and:

```lean
#print
```

Ask:

> What did Lean actually define?

The second one is extremely useful for your particular interests because you can investigate the relationship between **surface syntax and elaborated definitions**.

---

# 11. `lake` commands you'll actually use

Initially:

```bash
lake new my-project
cd my-project

lake build
```

Then, when using Mathlib or another dependency:

```bash
lake update
lake build
```

For directly checking a file:

```bash
lake env lean Main.lean
```

The important conceptual distinction is:

$$
\texttt{lean Main.lean}
$$

means roughly:

> Run Lean on this source file.

whereas:

$$
\texttt{lake build}
$$

means:

> Build the project according to its dependency/module configuration.

---

# 12. Toolchain management

This is another layer you should understand early.

Lean projects are associated with a particular Lean toolchain.

You may encounter files/configuration referring to something like:

```text
leanprover/lean4:v4.x.x
```

The exact version matters.

So:

$$
\boxed{
\text{Lean source}
+
\text{Lean version}
+
\text{dependencies}
}
$$

determine the reproducible build environment.

This is analogous to Rust:

$$
\texttt{rust-toolchain.toml}
+
\texttt{Cargo.toml}
+
\texttt{Cargo.lock}.
$$

---

# 13. Your mental model of the whole stack

I'd keep this model:

$$
\boxed{
\begin{array}{c}
\text{VS Code}\\
\downarrow\\
\text{Lean Language Server}\\
\downarrow\\
\text{Elaborator}\\
\downarrow\\
\text{Kernel}\\
\downarrow\\
\text{Trusted type theory}
\end{array}
}
$$

and separately:

$$
\boxed{
\begin{array}{c}
\text{lakefile.toml}\\
\downarrow\\
\text{Lake}\\
\downarrow\\
\text{module dependency DAG}\\
\downarrow\\
\text{.olean artifacts}
\end{array}
}
$$

Then Mathlib sits as a huge dependency graph consumed by this machinery.

---

## The Rust analogy I'd use

Since you know Rust, this is probably the most useful translation:

| Rust                    | Lean                       |
| ----------------------- | -------------------------- |
| Rust expression         | Lean term                  |
| Rust type               | Lean type                  |
| trait bound             | typeclass constraint       |
| `rustc`                 | Lean elaborator + compiler |
| borrow/type checking    | dependent type checking    |
| compiler error          | elaboration/type error     |
| Cargo                   | Lake                       |
| `Cargo.toml`            | `lakefile.toml`            |
| `Cargo.lock`            | `lake-manifest.json`       |
| crate                   | package/module structure   |
| compiled crate metadata | `.olean`                   |
| `cargo build`           | `lake build`               |
| rust-analyzer           | Lean language server       |
| compiler's type checker | **Lean kernel**            |
| unit/property test      | theorem/proof              |
| executable code         | computational terms        |
| specification           | types/propositions         |

The **one place not to overextend the analogy** is the kernel: Lean's kernel is not just "a compiler type checker." Its central job is to check that a purported proof term is valid according to the underlying dependent type theory.

Given your current questions, I'd next learn **one complete tiny Lean repository from empty directory → `lake build` → module import → theorem → `.olean` → `#check/#print` → kernel checking**. That will connect the abstract judgment model you've been building to the actual implementation.
