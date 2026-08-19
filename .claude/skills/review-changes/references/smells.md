# Code smells

A fixed set of code smells for the Standards axis. Source: Fowler, *Refactoring*, ch. 3.

This baseline applies even when the repo documents no standards of its own. Two rules bind it.

1. **The repo overrides.** A documented repo standard always wins. Where the repo endorses something
   this baseline would flag, suppress the smell.
2. **Every entry is a judgement call.** Label it as one. Write "possible Feature Envy", never
   "violates Feature Envy". A documented-standard breach can be a hard finding. A baseline smell
   cannot.

**Skip anything tooling already enforces.** A lint rule or a formatter makes the finding noise.

Each entry reads *what it is* then *how to fix it*. Match each against the diff.

- **Mysterious Name**. A function, variable, or type whose name hides what it does or holds.
  → Rename it. If no honest name comes, the design is murky.
- **Duplicated Code**. The same logic shape appears in more than one hunk or file in the change.
  → Extract the shared shape. Call it from both sites.
- **Feature Envy**. A method reaches into another object's data more than its own.
  → Move the method onto the data it envies.
- **Data Clumps**. The same few fields or parameters keep travelling together.
  → Bundle them into one type. Pass that type.
- **Primitive Obsession**. A primitive or string stands in for a domain concept.
  → Give the concept its own small type.
- **Repeated Switches**. The same switch or if-cascade on the same type recurs across the change.
  → Replace it with polymorphism, or with one map both sites share.
- **Shotgun Surgery**. One logical change forces scattered edits across many files in the diff.
  → Gather what changes together into one module.
- **Divergent Change**. One file or module gets edited for several unrelated reasons.
  → Split it so each module changes for one reason.
- **Speculative Generality**. Abstraction, parameters, or hooks serve needs the change does not have.
  → Delete them. Inline back until a real need shows. This entry also covers the over-engineering
  lens: an interface with one implementation, a factory for one product, config for a value that
  never changes, and a reinvented standard-library function.
- **Message Chains**. Long `a.b().c().d()` navigation the caller should not depend on.
  → Hide the walk behind one method on the first object.
- **Middle Man**. A class or function that mostly delegates onward.
  → Cut it. Call the real target directly. A thin wrapper that only saves typing is the same smell.
- **Refused Bequest**. A subclass or implementer ignores or overrides most of what it inherits.
  → Drop the inheritance. Use composition.
