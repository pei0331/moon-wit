# Changelog

All notable changes to this project are documented in this file.

## [0.1.0] - 2026-08-12

Initial release. `moon-wit` — a WIT core-subset parser and MoonBit API
scaffold generator.

### Added

- WIT 1.0 core-subset lexer with 1-based line/column positions, comments and
  `@version` tokens, including `%escaped-identifier` support.
- WIT declaration attributes such as `@since(...)` are accepted as metadata.
- Recursive-descent parser: `package`, `interface`, `world`, `use`,
  `import`/`export` (named and inline-interface), `record`/`variant`/`enum`/
  `flags`/`resource`/`type` aliases, and `func` signatures including named and
  multiple results.
- Direct world-level function imports and exports, including code generation
  and list-dependency detection.
- Generated no-result functions use an explicit `Unit` return type, and WIT
  lists use the package-qualified `@list.List[T]` MoonBit type.
- Resource bodies now parse constructors, static functions and methods, and
  generate prefixed opaque-handle API stubs.
- World `include path;` declarations and `with { old as new }` renames are
  parsed, rendered and retained in generated output as composition comments.
- External interface paths preserve namespaces, hierarchy and versions across
  `use`, `import`, `export` and `include` declarations.
- Generated comments render `use` declarations without a duplicated keyword.
- `future<T>` and `stream<T>` map to generated opaque generic scaffold handles.
- WIT flags map to `UInt` bitmasks with prefixed named constants.
- Full AST (`ast.mbt`) with a WIT round-trip renderer.
- Code generator (`codegen.mbt`): `record`→`struct`, `variant`→payload `enum`,
  `enum`→unit `enum`, `flags`→`UInt` bitmask, `resource`→`#external
  type`, alias→`type`, `func`→typed `pub fn` stub; full WIT→MoonBit type
  mapping (see `docs/GRAMMAR.md`); automatic `moonbitlang/core/list` import
  detection.
- `moon-wit` CLI (`cmd/moon-wit`): `parse` / `gen` / `version` / `help`
  subcommands with native file I/O.
- Automated tests covering the lexer, parser (AST shape and exact error
  positions) and codegen (generated declarations, type mapping and list-import
  detection), including comma-separated WIT members, optional function
  semicolons and parse/render round trips.
- WIT fixtures and generated examples for hello-world, rich type mappings,
  escaped identifiers, direct world functions, resources, composition,
  versioned WASI paths, async handles and official-style attributes; every
  generated package is verified by CI via `moon build`.
- Docs: README, `docs/GRAMMAR.md`, `docs/SUBMISSION.md`.
- Architecture and scope-boundary documentation in `docs/DESIGN.md`.
- CI blackbox checks for CLI error handling and non-zero failure exits.
- Original official-style fixture covering syntax used by `wasi-io`, plus a
  third-party reference and license inventory.
