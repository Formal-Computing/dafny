# Cache reuse: soundness obligations and experiment design

## Existing implementation

`Source/DafnyLanguageServer/Language/CachingResolver.cs` computes a SHA-256 digest over the hashes of graph successors, the builtins hash, and `ModuleDecl.CloneId`. The module cache stores a `ModuleResolutionResult`, which contains mutable AST declarations, dictionaries of signatures and class members, and an error reporter. The cache is owned by the language-server resolution pipeline, **not** the standalone CLI resolver.

## Targeted inefficiency hypothesis (not yet demonstrated)

When a parser assigns a new `CloneId` after an edit that does not change the semantic contents of a module, the key may change and the old result may be missed. It is **not sufficient** to show that text inside a module stayed unchanged: imports, visible names, options, builtins, generated declarations, and negative lookup dependencies may change its meaning.

## Experiment protocol

1. Run existing language-server caching integration tests unchanged.
2. Observe a warm language-server session with Alpha and Beta in separate files; edit Beta and collect per-module hit/miss logs.
3. Repeat with Alpha and Beta in the same file; edit Beta only. Compare actual parser clone identities and cache decisions rather than assuming a miss.
4. Change a declaration in Beta that Alpha imports; verify dependency invalidation.
5. Add a new declaration to a namespace previously searched unsuccessfully by Alpha; verify negative-lookup invalidation.
6. Repeat with `DAFNY_RESOLUTION_CACHE_BYPASS=1`, keeping the process alive across revisions.
7. Compare diagnostics, resolved bindings, and final verification outcomes between bypass and reuse modes.

## Reuse rule to establish before implementation

A candidate key must encode (or conservatively invalidate on) the semantic environment, including transitive dependency exports, builtins, compiler options, and namespace lookup context. Even with a matching key, reusing mutable `ModuleResolutionResult` instances across new ASTs needs an explicit reattachment or immutable-summary design. Until those obligations are proven, do not enable content-keyed reuse.

## Current evidence

- Release build of Dafny CLI succeeded; standalone `resolve` emitted per-module timings.
- Release build of Dafny language server succeeded.
- A newly drafted same-file integration test did not produce the assumed cache events in its temporary-project setup; it was removed rather than kept as a failing or misleading test.
- No validated semantic-equivalence or speedup result exists yet.
