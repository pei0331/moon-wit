# WIT grammar and type mapping

`moon-wit` parses a **core subset of the WIT 1.0 grammar** and generates
MoonBit bindings from it. This page documents exactly what is supported and
how each construct maps to MoonBit.

## Supported grammar

The parser accepts the following subset of the
[WIT specification](https://github.com/WebAssembly/component-model/blob/main/design/mvp/WIT.md).

```
document   ::= 'package' ns ':' name ['@' version] ';' top-level*
top-level  ::= interface | world | use

interface  ::= 'interface' name '{' interface-item* '}'
             | 'interface' name ';'
interface-item ::= use | type-def | func

world      ::= 'world' name '{' world-item* '}'
             | 'world' name ';'
world-item ::= 'include' world-path ['with' '{' rename (',' rename)* '}'] ';'
             | 'import' (impexp | func)
             | 'export' (impexp | func)
             | use
world-path ::= ident (':' ident)? ('/' ident)*
rename     ::= ident 'as' ident
impexp     ::= name ['as' name] [':' 'interface' '{' interface-item* '}']

use        ::= 'use' path '.' '{' name ['as' name] (',' name ['as' name])* '}' ';'
             | 'use' path '.' '*' ';'
path       ::= ident (':' ident)? ('/' ident)*      -- e.g. `wasi:io/streams`

type-def   ::= record | variant | enum | flags | resource | type-alias
record     ::= 'record' name '{' (field [','])+ '}'
field      ::= ident ':' type
variant    ::= 'variant' name '{' (case [','])+ '}'
case       ::= ident ['(' type ')']
enum       ::= 'enum' name '{' (ident [','])+ '}'
flags      ::= 'flags' name '{' (ident [','])+ '}'
resource   ::= 'resource' name ';'
             | 'resource' name '{' resource-item* '}'
resource-item ::= 'constructor' '(' [param (',' param)*] ')' ';'
                | 'static' func ';'
                | func ';'
type-alias ::= 'type' name '=' type ';'

func       ::= ident ':' 'func' '(' [param (',' param)*] ')' ['->' results] [';']
param      ::= ident ':' type
results    ::= type
             | '(' [result (',' result)*] ')'
result     ::= type | ident ':' type

type       ::= primitive
             | name                    -- reference to a defined type
             | 'list'    '<' type '>'
             | 'option'  '<' type '>'
             | 'result'  '<' ['_'|type] [',' ['_'|type]] '>'
             | 'tuple'   '<' type (',' type)* '>'
             | 'own'     '<' name '>'
             | 'borrow'  '<' name '>'
primitive  ::= 'u8' | 'u16' | 'u32' | 'u64'
             | 's8' | 's16' | 's32' | 's64'
             | 'f32' | 'f64' | 'char' | 'string' | 'bool'
```

Comments (`//`, `/* */`, `///`) and whitespace are skipped anywhere. Errors
carry precise 1-based `line:column` positions. WIT escaped identifiers retain
their leading `%` in the AST and rendered WIT.

## WIT → MoonBit type mapping

| WIT | MoonBit | Notes |
| --- | --- | --- |
| `u8` | `Byte` | |
| `u16` | `UInt16` | |
| `u32` | `UInt` | |
| `u64` | `UInt64` | |
| `s8` | `Int` | widened — no `Int8` in core |
| `s16` | `Int16` | |
| `s32` | `Int` | |
| `s64` | `Int64` | |
| `f32` | `Float` | |
| `f64` | `Double` | |
| `char` | `Char` | |
| `string` | `String` | |
| `bool` | `Bool` | |
| `list<T>` | `@list.List[T]` | requires `moonbitlang/core/list` |
| `option<T>` | `Option[T]` | |
| `result<T, E>` | `Result[T, E]` | missing slot → `Unit` |
| `tuple<A, B, …>` | `(A, B, …)` | |
| `own<R>` / `borrow<R>` | `R` | the resource type name |
| `name` | `Name` | PascalCase |

## WIT → MoonBit definition mapping

| WIT | MoonBit |
| --- | --- |
| `record person { … }` | `pub struct Person { … }` |
| `variant animal { dog, bird(string) }` | `pub enum Animal { Dog, Bird(String) }` |
| `enum tone { formal, casual }` | `pub enum Tone { Formal, Casual }` |
| `flags permissions { read, … }` | `pub struct Permissions { read : Bool, … }` (P0 placeholder) |
| `resource session;` | `#external type Session` (opaque) |
| `resource counter { ... }` | opaque type plus `counter_new`, `counter_max` and `counter_increment` stubs |
| `type id = u64;` | `pub type Id = UInt64` |
| `greet: func(name: string) -> string` | `pub fn greet(name : String) -> String { abort("stub: greet") }` |

Function bodies consume their parameters and call `abort("stub: <name>")` so
generated packages compile without unused-parameter warnings. Canonical ABI
import/export plumbing is not implemented in version 0.1.0.

Results map as follows:

- no results → `Unit` (no `->`)
- one unnamed result → the mapped type directly
- multiple / named results → a MoonBit tuple `(T1, T2)`

## Naming

WIT identifiers are kebab-case by convention. `moon-wit` converts them for
MoonBit:

| Context | Rule | Example |
| --- | --- | --- |
| type names, enum cases | kebab-case → PascalCase | `hello-world` → `HelloWorld` |
| fields, functions, params | kebab-case → snake_case | `first-name` → `first_name` |

The `%` prefix is removed only during MoonBit code generation. If the result is
a MoonBit keyword, an underscore is appended: `%type` → `type_` and `%match` →
`match_`.

## P0 scope

Currently unsupported (documented limitations):

- `with` clauses and `use ... with { ... }` semantics
- `future` / `stream` handle types
- multi-file package imports
- named-result structs (multiple named results flatten to a tuple)
- bit-packed `flags` (generated as `Bool` fields)
- Component Model Canonical ABI lowering/lifting and callable bindings

These are targeted for later phases.
