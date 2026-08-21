# Writing style

These rules are Simplified Technical English, the ASD-STE100 standard. The standard is named so they
stay checkable instead of becoming taste. Write every review artifact in them, and judge changed
prose and code comments against them. The two modes are defined at the end.

They set a baseline for written work. A project's own standards override them where the two
conflict. They never govern conversation with a user, because a user's own configuration decides
that.

## Lead with the verdict

The ask, the recommendation, or the bottom line goes in the first two sentences. Evidence and caveats
follow. If the reader stops after the opening, they already have the part they can act on.

**Why:** this is not an STE rule, because STE works at the sentence and says nothing about answer
order. It is still the largest readability win available. A comment that reasons its way toward a
recommendation makes the author guess what you want changed.

## Eight structural rules

1. One idea per sentence, and one instruction per sentence. A reason belongs to the claim it
   supports, so keep a because-clause attached rather than splitting it off to satisfy the count.
   Prose built entirely from split reasons reads as staccato.
2. ≤20 words for instructions, ≤25 for descriptions. The caps are soft, and a longer sentence needs
   a reason.
3. Active voice with a named actor. "The migration drops the column", not "the column is dropped".
4. No semicolons. Split the sentence. An em dash often marks the same unsplit seam.
5. ≤3 words stacked in a noun phrase. "task queue handler", not "agent task queue priority handler".
6. Simple tenses. "We received the report", not "we have received the report". The compound form
   earns its place only where it carries something the simple one cannot, such as current relevance
   or a hedge.
7. A numbered or bulleted list for 3+ steps or conditions. Never bury a sequence in one prose
   sentence.
8. Keep the subject, the verb, and the article. Never drop words to save space.

## Six habits to scan for

Each one is mechanical, so you can point at the word that breaks it.

1. **Synonym rotation.** One thing named three ways: "the handler", "this method", "the callback".
   Pick one name and reuse it every time.
2. **Hedge stacking.** "it is worth noting that this may potentially help to improve". State the
   claim or cut it.
3. **Nominalization.** "perform an analysis of" → "analyze".
4. **Marketing adjectives.** Seamless, robust, powerful, blazing-fast. Delete the word, or give the
   measurement that earns it.
5. **Run-ons.** Several ideas joined by semicolons or dashes.
6. **Soft phrasal verbs.** Spin up, reach out, dive into, kick off → start, contact, read, begin.

## Never compress a hedge into a fact

"This may leak under concurrent writes" never becomes "this leaks". Confidence is content, and a
length cap is what tempts you to cut it. The same holds for a scope qualifier, a condition, and a
number. Where the shorter sentence loses one, keep the longer sentence and say why.

**Why:** confident phrasing on a shaky finding costs the author a full context reload to disprove it.
That is the same re-review cost the verdict rule exists to minimize.

## Density is not word count

Splitting one long sentence into three short ones usually makes the text longer, and that is the right
direction. These rules cut ideas per sentence, not reasoning. They never override the reason a finding
exists, so drop the padding and keep the because.

## Keep the vocabulary

Skip the standard's ~900-word approved dictionary. A precise domain term earns its place, so keep
predicate, tautology, idempotent, and monomorphic, and define one once where it is not common English. The
standard allows a project glossary on top of its dictionary, so this is a provision of the standard
rather than a departure from it. Skip the aerospace register too. Contractions are fine, and so are
-ing forms.

## Two modes, and neither is off

**Strict.** Every rule above, including the caps and one term per concept. Use it where a wrong
reading has a cost.

**Flavored.** Structural rules in full. The word choice rules turn advisory, so contractions stay and
one concept can carry more than one name where the range earns it.

Flavored sheds the flat tone, never the sentence structure.
