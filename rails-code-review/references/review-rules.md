# Review Rules

## What NOT to Flag

- Comments that boil down to personal taste and don't improve readability, reliability, or maintainability.
- Over-engineered optimizations and performance nitpicks without evidence of a real problem.

## The 10 Review Rules

### 1. Prefer Explicit APIs and Simple Signatures

- For long-lived APIs (especially jobs and base classes), keyword args help with backward compatibility across versions.
- But don't mechanically convert internal methods with one obvious argument to keyword-only without reason.
- When passing kwargs, don't reassemble them through `merge` when you can pass explicitly: `foo: foo, **rest`.
- Don't extract a one-off expression into a separate method or local variable without a real readability gain.
- If a method accepts a set of options that are really data (not behavior switches), give them domain-specific names and prefer keyword arguments.
- Boolean arguments should almost always be keyword args.
- Don't create single-use temp variables if the inline call is short and clear.
- Avoid non-obvious tricks like `&.then` as a "fancy if" when they don't use the object inside the block and only confuse the reader.
- If important domain context lives only in the PR description or review thread, it needs to be in the code or a comment nearby.

### 2. Watch for Misleading Naming

- Names should describe the real meaning, not an approximate idea. Especially for actions, predicates, scopes, concerns, and hashes with domain state.
- If a name creates a false sense of DSL, predicate, collection semantics, three-state logic, or "just strings" — flag it.
- Don't name different endpoints/paths as if they're different things when they're actually the same flow with the same template and logic.
- Don't use escape hatches and "convenient" shortcuts like misleading helper names that hide the real API meaning.
- Don't try to "explain everything" with overly long variable names; a long name doesn't replace clear data structure and proper context.
- When code has a pair of "unit" and "quantity of units", name them so they can't be confused at first glance.

### 3. Simplify Code When Logic Outsmarts Its Task

- Watch for repeated `nil?`/fallback patterns, redundant conversions, and conditional branches that could be expressed more simply.
- If code looks like an overly general mechanism but actually serves a couple of specific cases, make it more straightforward.
- Trivial helper methods and concerns that only wrap an obvious `where`/`select`/option access usually don't improve design.
- If a base job/action API almost fits a new case, consider generalizing it rather than copying a similar `perform` alongside.
- Don't thread state down the stack through mutable instance variables; if a value matters lower down, pass it as an argument.
- If domain logic relies on multiple states, statuses, or time axes, lay it out explicitly rather than hiding it in chains of conditions.
- Early return with an explicit "empty" result is often better than branching through half a method for an edge case.
- If the whole point of a method is enumerating finite states, a flat condition tree or `case` is often more honest than "elegant" nested abstractions.
- Don't complicate state models and configuration without a clear benefit for reading or extensibility.
- Keep models lean: don't mix in job scheduling and orchestration when an action/job layer can do it more explicitly.

### 4. Tests Should Be Short, Regular, and Well-Named

- Repeated checks are better as `shared_examples` or another regular form, only if it doesn't hurt navigation and failure localization.
- Deeply nested contexts are just as suspicious as overly aggressive shared examples: sometimes a bit of duplication is more honest.
- Each individual expectation is better in its own `it`/`its` block if it simplifies failure localization.
- Names of `subject`, `context`, and examples should directly explain the scenario, not require deciphering.
- Use verifying doubles and standard RSpec doubles, not home-made hacks and `as_null_object`, unless there's a genuinely rare reason.
- Use project conventions like `with_user:` metadata and implicit-subject idioms where they genuinely improve readability.
- Don't optimize tests by line count at the expense of readability.
- For error paths, try to provide real bad data rather than stubbing internal utils just to "reach the branch".
- Tests should be self-describing not just by names but by placement: related specs are better stored nearby and in the expected folder.
- `let_it_be` is acceptable only for truly immutable records; don't sacrifice test isolation for convenience or dubious speed gains.

### 5. Flow Control and Errors Should Make the Main Path Visible

- In the main method, it should be easy to read the primary execution flow without jumping through small helper layers.
- If an abstraction hides real business-flow branches, rewrite it so the scenario reads top to bottom.
- Validations and correctness checks belong closer to the entry point, not on derived values deeper in the stack.
- Not every "didn't work" is an error; first separate the product case, the rare-but-expected case, and the real exception.
- Model validations should check consistency of a single record; business-level constraints and cross-entity rules belong in the action/service policy layer.
- If a contract is violated, make the error explicit rather than leaving a silent "maybe nil, maybe not".
- If a wrong method call means a bug, the method should yell, not quietly do nothing.
- Errors and exceptions should be formulated to guard against accidental misuse of the API.
- In rescue blocks, prefer plain `raise` for re-raising the current exception unless you're adding new meaning.
- If a test for an error only checks "no raise" but doesn't describe the return value, it's a weak test.

### 6. Comments Should Explain External Constraints and Odd Decisions

- If code looks strange because of an API provider, rate limits, callback constraints, or framework quirks, explain it briefly in a comment.
- If knowledge about a job's/process's behavior isn't obvious at first glance, a short comment is mandatory.
- Action docs are especially important: actions are the main "verbs" of the system, and people read domain behavior from them.
- Prefer a precise comment over rewriting code just to satisfy a linter.
- If a piece of code is non-obvious without context, leave an explanation nearby rather than relying on `git blame`.
- Don't add comments that merely duplicate the method name or vacuously describe the return value.
- If a comment has gone stale and become confusing, it's better to delete it than to "maintain the appearance of documentation".
- If a comment explains an exception to a general rule, it should contain the reason, not a description of the mechanics.
- If a comment no longer matches reality or "isn't needed anymore", that's a valid reason to remove it in the PR.

### 7. Query/SQL Code Should Be Readable and Regular

- Queries should read as a coherent operation, not as a collection of scattered SQL fragments and post-processing.
- Trivial "helpful" query helpers should be elevated to a genuinely reusable domain API, not proliferated locally in controllers.
- If a generic scope already exists (`with_feature`, `with_status`), it's usually better to use it than to load everything and filter in Ruby or create a one-off helper for a single status.
- If a query naturally expresses as a scope or named selection, that's often better than scattered logic in the calling code.
- If you can eliminate N+1 or row-by-row lookup, it often changes the shape of the entire algorithm; don't treat the symptom locally if the problem is structural.
- If a complex SQL pattern starts repeating across the project, unify or extract it before it spreads.
- Break long query methods into observable steps so the data pipeline is visible.
- Use forms that help tooling and the reader: for example, SQL heredoc with syntax highlighting where it improves reading.
- If a query form can be made more future-proof and regular, it's worth discussing.
- Query/domain API should not leak accidental implementation details into the public interface.

### 8. Presentation Layer Should Be Declarative with Clear Boundaries

- Serializers should describe data declaratively where possible, not become procedural glue.
- Decorators and serializers should not unexpectedly hit the database; they should work with already-prepared data.
- Decorator, serializer, and presenter should each have a clear role; don't mix their responsibilities without necessity.
- If logic looks like a presentation concern, don't hide it in model/query just because it's easier to reach from there.
- If correspondence logic can be expressed in one clear place, do so rather than spreading it across constants and branches.
- Helper and utility names shouldn't promise overly narrow behavior when the logic is actually general.
- In new code, prefer modern project abstractions; presenter/decorator is often more expressive than an ad-hoc hash.
- If a method is only used inside a decorator/serializer and assembles a structure specific to it, that's a strong signal the logic is in the wrong layer.

### 9. Discuss Performance Only with Data and at the Right Scale

- Moving to a heavier implementation for readability is acceptable, but for hot paths you need at least minimal performance proof.
- Don't suggest micro-optimizations without understanding the data volume, indexes, and real load.
- When mentioning performance, it's more useful to speak in terms of measurements, query plans, and large databases rather than abstract concerns.
- For genuinely hot paths, local optimizations are acceptable, but their intent should be easily visible.
- Trigger-heavy, serializer-heavy, and decorator-heavy spots require extra caution: an additional DB call there can impact the entire system.
- Prefer predictability: if you can't tell in advance from a serializer/decorator/trigger whether queries will fire, that's already a maintenance and performance risk.

### 10. Follow Ruby Conventions Where They Genuinely Help Readability

- Consistency of action-like interfaces (`#call`) matters more than the specific method name; if the project uses a pattern, follow it.
- If a project convention or Ruby idiom makes code clearer, rely on it rather than introducing a local exception without a strong reason.
- Distinguish `or` as control flow from `||` as logical operator; don't mix them mechanically.
- Don't introduce Java-style constants for symbols and internal names where Ruby already provides a simple, expressive way.

## Formulating Feedback

**Bad feedback:**
> Better to rename `data` to `payment_data`.

No explanation of why the current name creates a problem — looks like a taste preference.

**Good feedback:**
> `data` in this method's context could mean either request params or provider response — the reader can't tell without context what it contains. `provider_response` more precisely conveys that this is the result of an external call.

Specific risk (ambiguity) + suggestion + explanation of why it's better.
