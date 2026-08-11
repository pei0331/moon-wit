# Changelog

All notable changes to this project are documented in this file.

## [0.1.0] - 2026-08-11

Initial release. `moon-wit` — a WIT core-subset parser and MoonBit API
scaffold generator.

### Added

- WIT 1.0 core-subset lexer with 1-based line/column positions, comments and
  `@version` tokens.
- Recursive-descent parser: `package`, `interface`, `world`, `use`,
  `import`/`export` (named and inline-interface), `record`/`variant`/`enum`/
  `flags`/`resource`/`type` aliases, and `func` signatures including named and
  multiple results.
- Full AST (`ast.mbt`) with a WIT round-trip renderer.
- Code generator (`codegen.mbt`): `record`→`struct`, `variant`→payload `enum`,
  `enum`→unit `enum`, `flags`→`Bool`-field `struct`, `resource`→`#external
  type`, alias→`typealias`, `func`→typed `pub fn` stub; full WIT→MoonBit type
  mapping (see `docs/GRAMMAR.md`); automatic `moonbitlang/core/list` import
  detection.
- `moon-wit` CLI (`cmd/moon-wit`): `parse` / `gen` / `version` / `help`
  subcommands with native file I/O.
- Automated tests covering the lexer, parser (AST shape and exact error
  positions) and codegen (generated declarations, type mapping and list-import
  detection), including comma-separated WIT members, optional function
  semicolons and parse/render round trips.
- `tests/hello-world.wit` and `tests/greeting.wit` fixtures; checked-in
  `examples/hello` generated bindings verified by CI via `moon build`.
- Docs: README, `docs/GRAMMAR.md`, `docs/SUBMISSION.md`.
