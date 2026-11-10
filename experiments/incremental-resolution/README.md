# Incremental semantic resolution: upstream experiment

Status: experimental scaffold; no performance or soundness claims yet.

## Goal
Compare the unchanged Dafny resolver with a narrowly scoped incremental resolution implementation on the same source revisions. Record semantic diagnostics, resolution duration, and cache hit/miss/invalidation events. Never interpret a faster isolated cache lookup as an end-to-end Dafny speedup.

## Baseline first
1. Pin the upstream commit: `git rev-parse HEAD`.
2. Build using the SDK specified in `global.json` and Dafny's developer installation instructions.
3. Locate `Source/DafnyCore/Resolver/ModuleResolver.cs` and trace `ModuleResolutionResult` construction, consumers and mutable references.
4. Add opt-in timing instrumentation before implementing caching.
5. Capture a fresh-process baseline, warm-process baseline, and repeated runs.

## Differential experiment
- Revision A: two modules, Alpha and Beta, with an explicit dependency.
- Revision B: edit only Beta without changing Alpha's semantic environment.
- Revision C: add a declaration visible to Alpha that can change a previously failed lookup (negative dependency).
- Compare diagnostics and resolved symbol identities, not only exit codes.
- Record commit, command, environment, duration, hit/miss counts and results in machine-readable evidence.

## Safety constraints
Do not reuse a `ModuleResolutionResult` instance merely because source text matches. Establish a sufficient context-equivalence criterion, audit mutable references, and disable caching when uncertain. First experimental cache path must be opt-in and baseline-compatible.

## Discussion with collaborator
Which smallest class of modules has a demonstrably sound reusable summary? Which resolver phase can be instrumented without changing behavior? Which invalidation dependency is currently missing?
