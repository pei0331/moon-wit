# moon-wit

A **WIT core-subset parser and MoonBit API scaffold generator** for
[MoonBit](https://www.moonbitlang.com). `moon-wit` reads a
[WIT 1.0](https://github.com/WebAssembly/component-model/blob/main/design/mvp/WIT.md)
document and generates typed MoonBit declarations and function stubs.

The generated package compiles with `moon build` out of the box, making it
useful for validating WIT files and starting a MoonBit-facing API. Version
0.1.0 does **not** implement the Component Model Canonical ABI, so generated
functions are compile-time scaffolds rather than callable Wasm bindings.
Design inspired by `bytecodealliance/wit-bindgen`.

## Quick start

```bash
moon run cmd/moon-wit -- parse tests/hello-world.wit
# package docs:hello;
# interface greet {
#   greet: func(name: string) -> string
# }
# world hello-world { ... }
```

```bash
moon run cmd/moon-wit -- gen tests/hello-world.wit -o examples/hello
# wrote examples/hello/bindings.mbt and examples/hello/moon.pkg
```

Generated `bindings.mbt` for `tests/hello-world.wit`:

```moonbit
///|
pub fn greet(name : String) -> String {
  ignore(name)
  abort("stub: greet")
}

// import greet
// export run
///|
pub fn run() -> String {
  abort("stub: run")
}
```

Function bodies consume their parameters and then call `abort("stub: <name>")`
so the generated package compiles without unused-parameter warnings. Canonical
ABI import/export plumbing is tracked as future work.

## CLI

| Subcommand | Description |
| --- | --- |
| `moon-wit parse <file.wit>` | Parse and print the WIT AST (rendered as WIT) |
| `moon-wit gen <file.wit> [-o <dir>]` | Generate bindings to stdout, or write `bindings.mbt` + `moon.pkg` into `<dir>` |
| `moon-wit version` | Print the version |
| `moon-wit help` | Show usage |

Direct functions in a WIT world are supported:

```wit
world calculator {
  import log: func(message: string);
  export add: func(a: s32, b: s32) -> s32;
}
```

See `examples/calculator` for the generated package. CI regenerates and builds
all checked-in examples.

World composition paths are also parsed and preserved:

```wit
world app {
  include wasi:cli/run;
  include local:shared/base with { old-name as new-name };
}
```

External package paths retain namespaces, hierarchy and versions, including
forms such as `wasi:io/streams@0.2.0`.

Resource declarations with constructors, static functions and methods are
also scaffolded. See `examples/resource` for the generated opaque handle API.

## How it maps WIT to MoonBit

`record` → `struct`, `variant` → payload `enum`, `enum` → unit `enum`,
`flags` → `Bool`-field `struct`, `resource` → `#external type`,
`type` alias → MoonBit `type`, and every `func` → a typed `pub fn` stub.
WIT escaped identifiers such as `%type` are converted to legal MoonBit names
such as `type_` when they conflict with MoonBit keywords.

```wit
record person { name: string, age: u32 }
variant animal { dog, bird(string) }
greet: func(name: string) -> string
```

generates

```moonbit
pub struct Person {
  name : String
  age : UInt
}

pub enum Animal {
  Dog
  Bird(String)
}

pub fn greet(name : String) -> String {
  abort("stub: greet")
}
```

The full grammar and type-mapping tables are in
[docs/GRAMMAR.md](docs/GRAMMAR.md).

## Development

```bash
moon fmt --check   # formatting
moon check         # type-check
moon test          # lexer / parser / codegen tests
moon build         # build CLI and the generated examples/hello
```

CI also regenerates the checked-in example and package interfaces, then fails
if either differs from the committed files.

## Release

Inspect the mooncakes.io package contents before publishing:

```bash
moon package --list
moon login
moon publish
```

`moon publish` requires the package owner's mooncakes.io credentials and is
therefore a manual release step. Create or move a version tag only after the
published package has been verified.

See [CONTRIBUTING.md](CONTRIBUTING.md) and [docs/SUBMISSION.md](docs/SUBMISSION.md).

## License

Apache-2.0. See [LICENSE](LICENSE).
