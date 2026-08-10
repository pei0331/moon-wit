# moon-wit

A **Wasm Component Model interface binding generator** for
[MoonBit](https://www.moonbitlang.com). `moon-wit` reads a
[WIT 1.0](https://github.com/WebAssembly/component-model/blob/main/design/mvp/WIT.md)
document and generates type-safe MoonBit import/export bindings.

This is the interoperability layer for Wasm Components in MoonBit: feed it a
`.wit` file and it emits a MoonBit package that compiles with `moon build` out
of the box. Design inspired by `bytecodealliance/wit-bindgen`.

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
  abort("stub: greet")
}

// import greet
// export run
///|
pub fn run() -> String {
  abort("stub: run")
}
```

Function bodies are emitted as `abort("stub: <name>")` placeholders so the
generated package always compiles; they are filled in once the actual
component plumbing exists.

## CLI

| Subcommand | Description |
| --- | --- |
| `moon-wit parse <file.wit>` | Parse and print the WIT AST (rendered as WIT) |
| `moon-wit gen <file.wit> [-o <dir>]` | Generate bindings to stdout, or write `bindings.mbt` + `moon.pkg` into `<dir>` |
| `moon-wit version` | Print the version |
| `moon-wit help` | Show usage |

## How it maps WIT to MoonBit

`record` → `struct`, `variant` → payload `enum`, `enum` → unit `enum`,
`flags` → `Bool`-field `struct`, `resource` → `#external type`,
`type` alias → `typealias`, and every `func` → a typed `pub fn` stub.

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
moon test          # 26 tests (lexer / parser / codegen)
moon build         # build CLI and the generated examples/hello
```

See [CONTRIBUTING.md](CONTRIBUTING.md) and [docs/SUBMISSION.md](docs/SUBMISSION.md).

## License

Apache-2.0. See [LICENSE](LICENSE).
