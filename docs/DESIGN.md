# Design

`moon-wit` is split into a pure library pipeline and a native CLI shell:

```text
.wit source
    |
    v
lexer.mbt  -> positioned tokens
    |
    v
parser.mbt -> ast.mbt values
    |             |
    |             +-> WIT round-trip renderer
    v
codegen.mbt -> bindings.mbt + moon.pkg
    |
    v
moon check / moon build
```

## Lexer and errors

The lexer emits tokens with 1-based line and column positions. Keywords stay
as identifier tokens and are interpreted by the recursive-descent parser.
`WitError` reports the token position at which parsing can no longer continue.

Escaped identifiers retain `%` in the AST. Versioned external paths retain
their namespace, hierarchy and `@version` text for round-trip output.

## AST and parser

The AST models packages, interfaces, worlds, type definitions, functions,
resources and world composition. Parsed documents can be rendered back to WIT
and parsed again; tests use this property to catch structural data loss.

Resource constructors, static functions and methods have explicit AST kinds.
World imports/exports distinguish interface references from direct functions.
This avoids overloading optional fields with unrelated meanings.

## Code generation

The generator maps WIT declarations to typed MoonBit declarations. Generated
functions consume their parameters and abort as explicit stubs, so packages
type-check and build without pretending that an ABI implementation exists.

The generator also emits required package imports. For example, `list<T>` uses
`@list.List[T]` and adds `moonbitlang/core/list` to `moon.pkg`.

`future<T>` and `stream<T>` use generated opaque generic handles because the
current MoonBit core has no matching Component Model runtime abstraction.
Flags use `UInt` masks and prefixed constants; no runtime ABI is implied.

Checked-in examples are generated artifacts. CI regenerates them and rejects
drift before building every example.

## Scope boundary

Version 0.1.0 does not implement Component Model Canonical ABI lowering and
lifting. In particular, generated functions are not callable component
imports or exports. The current deliverable is a WIT parser, round-trip model
and compiling MoonBit API scaffold generator.

Multi-file package resolution is also outside the current release. External
paths are preserved but are not loaded from disk or a registry.

Compatibility fixtures are written specifically for this project. Official
WASI repositories may be inspected during development, but their WIT files are
not vendored into the release package.

## Verification

The release checks are:

```bash
moon info
moon fmt --check
moon check
moon test
moon build
moon package --list
```

CI additionally regenerates all examples and fails if committed outputs or
public `.mbti` interfaces are stale. CLI smoke tests also require malformed
input, missing files and unknown subcommands to exit non-zero.
