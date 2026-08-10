# Contributing to moon-wit

Thanks for your interest! `moon-wit` is a small, dependency-free WIT parser
and binding generator for MoonBit. Before opening a PR, please keep the
following in mind.

## Scope

- **No new dependencies.** The library must build against `moonbitlang/core`
  alone. If you need a helper from core, use it directly; if core lacks it,
  implement it locally.
- **Spec conformance over features.** The WIT subset implemented must match
  the [WIT specification](https://github.com/WebAssembly/component-model/blob/main/design/mvp/WIT.md).
  A change that parses valid WIT differently is a bug; malformed input must be
  rejected with a precise `line:column` `WitError`.
- **Surgical changes.** Keep diffs focused. Match the existing `///|` block
  layout and follow `moon fmt`.

## Layout

| File | Purpose |
| --- | --- |
| `ast.mbt` | `WitPackage` AST + WIT renderer |
| `error.mbt` | `WitError` (a `suberror`) with positions |
| `lexer.mbt` | tokenizer with line/column tracking |
| `parser.mbt` | recursive-descent parser |
| `codegen.mbt` | WIT → MoonBit binding generation |
| `cmd/moon-wit/` | the `moon-wit` CLI (file I/O via FFI) |
| `tests/` | `.wit` fixtures |
| `examples/hello/` | CLI-generated bindings (checked in) |
| `*_test.mbt` | lexer / parser / codegen tests |

## Testing

```bash
moon test
```

- Lexer tests pin the token stream and positions.
- Parser tests compare full rendered-AST strings against fixtures and assert
  exact error positions.
- Codegen tests parse a fixture, generate, and assert the output contains the
  expected MoonBit declarations.
- Every grammar rule you touch should have at least one positive and one
  negative case.

## Pre-submit checklist

1. `moon fmt --check` — the repo is formatted.
2. `moon check` — no errors.
3. `moon test` — all tests pass.
4. `moon build` — the CLI and `examples/hello` compile.
5. `moon info` — regenerate the package interface; commit the `.mbti` diff.
6. If you changed the grammar or the type mapping, update `docs/GRAMMAR.md`
   and `README.md`.

## License

By contributing you agree that your changes are licensed under Apache-2.0.
