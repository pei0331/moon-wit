# pei0331/moon-wit

A WIT core-subset parser and MoonBit API scaffold generator. It emits typed
declarations and compiling function stubs. Version 0.1.0 does not yet implement
the Component Model Canonical ABI, so the generated functions are not callable
Wasm import/export bindings. Design inspired by `bytecodealliance/wit-bindgen`.

## Usage

The library exposes the parse → generate pipeline used by the `moon-wit` CLI:

```moonbit nocheck
///|
let pkg = @moon_wit.parse(src) // WIT text → WitPackage (raises WitError)

///|
let bindings = @moon_wit.generate(pkg) // → bindings.mbt content

///|
let moon_pkg = @moon_wit.generate_moon_pkg(
  @moon_wit.needs_list_import(pkg), // → moon.pkg content
)
```

`examples/hello`, `examples/escaped` and `examples/calculator` are checked-in
CLI outputs compiled by CI. They cover inline interfaces, escaped identifiers
direct world-level function imports/exports and resource constructors, static
functions and methods.

## Public API

- `parse(String) -> WitPackage raise WitError` — lex + parse a WIT document.
- `generate(WitPackage) -> String` — render MoonBit bindings.
- `needs_list_import(WitPackage) -> Bool` — whether `list<T>` appears.
- `generate_moon_pkg(Bool) -> String` — contents of the generated `moon.pkg`.
- `type_str(WitType) -> String` — WIT type → MoonBit type.
- `type_name` / `case_name` / `field_name` — kebab-case → Pascal/snake_case.

Errors carry 1-based `line:column` positions. The implementation is pure logic
with no I/O, so the lexer/parser/codegen run unchanged on the Wasm targets;
file I/O lives only in the `moon-wit` CLI (`cmd/moon-wit`).
