///|
/// Parser tests using inline WIT fixtures. Full rendered-AST string comparisons
/// make structure changes visible in the diff.

///|
let hello_world_wit : String =
  #|package docs:hello;
  #|
  #|interface greet {
  #|  greet: func(name: string) -> string
  #|}
  #|
  #|world hello-world {
  #|  import greet;
  #|  export run: interface {
  #|    run: func() -> string
  #|  }
  #|}

///|
let greeting_wit : String =
  #|package example:greeting@0.1.0;
  #|
  #|interface types {
  #|  record person {
  #|    name: string
  #|    age: u32
  #|    email: string
  #|  }
  #|  enum tone {
  #|    formal
  #|    casual
  #|  }
  #|  variant animal {
  #|    dog
  #|    bird(string)
  #|    fish
  #|  }
  #|  flags permissions {
  #|    read
  #|    write
  #|    execute
  #|  }
  #|  resource session;
  #|  type id = u64;
  #|  list-people: func(limit: u32) -> list<person>
  #|  make-greeting: func(name: string, t: tone) -> string
  #|  add-person: func(p: person) -> result<u64, string>
  #|  find: func(key: string) -> option<string>
  #|  mix: func(a: u8, b: s8) -> tuple<u32, bool>
  #|  talk: func(s: borrow<session>) -> string
  #|}
  #|
  #|world greeting-world {
  #|  use types.{person, tone};
  #|  import types;
  #|  export run: interface {
  #|    run: func() -> string
  #|  }
  #|}

///|
let calculator_wit : String =
  #|package example:calculator;
  #|world calculator {
  #|  import log: func(message: string);
  #|  export add: func(a: s32, b: s32) -> s32;
  #|  export batch-add: func(values: list<s32>) -> list<s32>;
  #|}

///|
let resource_wit : String =
  #|package example:resource;
  #|interface handles {
  #|  resource counter {
  #|    constructor(initial: u32);
  #|    static max: func() -> u32;
  #|    increment: func(amount: u32) -> u32;
  #|  }
  #|}

///|
let include_wit : String =
  #|package example:composition;
  #|world app {
  #|  include wasi:cli/run;
  #|  include local:shared/base;
  #|  include local:shared/legacy with { old-name as new-name, run as start };
  #|}

///|
let wasi_paths_wit : String =
  #|package example:wasi-paths;
  #|use wasi:io/streams@0.2.0.{input-stream as input, output-stream};
  #|world app {
  #|  import wasi:cli/environment@0.2.0;
  #|  export wasi:cli/run@0.2.0 as run;
  #|  include wasi:cli/command@0.2.0;
  #|}

///|
fn parse_or_fail(src : String) -> WitPackage {
  parse(src) catch {
    e => abort("parse failed: \{e.to_string()}")
  }
}

///|
test "parse hello-world package header" {
  let p = parse_or_fail(hello_world_wit)
  assert_eq(p.ns, "docs")
  assert_eq(p.name, "hello")
  assert_eq(p.version, None)
  assert_eq(p.items.length(), 2)
}

///|
test "parse hello-world interface" {
  let p = parse_or_fail(hello_world_wit)
  let items = p.items
  match items[0] {
    Interface(iface) => {
      assert_eq(iface.name, "greet")
      assert_eq(iface.items.length(), 1)
      match iface.items[0] {
        Func(f) => {
          assert_eq(f.name, "greet")
          assert_eq(f.params.length(), 1)
          assert_eq(f.params[0].name, "name")
          assert_eq(f.params[0].ty.to_string(), "string")
          assert_eq(f.results.length(), 1)
          assert_eq(f.results[0].to_string(), "string")
        }
        _ => abort("expected func")
      }
    }
    _ => abort("expected interface")
  }
}

///|
test "parse hello-world world" {
  let p = parse_or_fail(hello_world_wit)
  match p.items[1] {
    World(w) => {
      assert_eq(w.name, "hello-world")
      assert_eq(w.items.length(), 2)
      match w.items[0] {
        Import(imp) => {
          assert_eq(imp.name, "greet")
          assert_eq(imp.inline is None, true)
          assert_eq(imp.asName is None, true)
        }
        _ => abort("expected import")
      }
      match w.items[1] {
        Export(exp) => {
          assert_eq(exp.name, "run")
          match exp.inline {
            Some(iface) => {
              assert_eq(iface.items.length(), 1)
              match iface.items[0] {
                Func(f) => {
                  assert_eq(f.name, "run")
                  assert_eq(f.params.length(), 0)
                  assert_eq(f.results.length(), 1)
                }
                _ => abort("expected func")
              }
            }
            None => abort("expected inline interface")
          }
        }
        _ => abort("expected export")
      }
    }
    _ => abort("expected world")
  }
}

///|
test "rendered WIT parses again" {
  let rendered = parse_or_fail(hello_world_wit).to_string()
  let reparsed = parse_or_fail(rendered)
  assert_eq(reparsed.to_string(), rendered)
  assert_eq(contains_test_str(rendered, "import greet;"), true)
  assert_eq(contains_test_str(rendered, "\n    run: func()"), true)
}

///|
test "parse and render escaped identifiers" {
  let src =
    #|package test:escaped;
    #|interface %interface {
    #|  %type: func(%match: string) -> string;
    #|}
  let rendered = parse_or_fail(src).to_string()
  assert_eq(contains_test_str(rendered, "interface %interface"), true)
  assert_eq(contains_test_str(rendered, "%type: func(%match: string)"), true)
  assert_eq(parse_or_fail(rendered).to_string(), rendered)
}

///|
fn contains_test_str(haystack : String, needle : String) -> Bool {
  let needle_len = needle.length()
  if needle_len == 0 {
    return true
  }
  for i in 0..<(haystack.length() - needle_len + 1) {
    if haystack[i:i + needle_len].equal_to_string(needle) {
      return true
    }
  }
  false
}

///|
test "parse greeting package version" {
  let p = parse_or_fail(greeting_wit)
  assert_eq(p.ns, "example")
  assert_eq(p.name, "greeting")
  assert_eq(p.version, Some("0.1.0"))
}

///|
test "parse greeting typedefs" {
  let p = parse_or_fail(greeting_wit)
  match p.items[0] {
    Interface(iface) => {
      assert_eq(iface.items.length(), 12)
      assert_eq(
        iface.items[0].to_string(),
        "record person {\n  name: string\n  age: u32\n  email: string\n}",
      )
      assert_eq(
        iface.items[1].to_string(),
        "enum tone {\n  formal\n  casual\n}",
      )
      assert_eq(
        iface.items[2].to_string(),
        "variant animal {\n  dog\n  bird(string)\n  fish\n}",
      )
      assert_eq(
        iface.items[3].to_string(),
        "flags permissions {\n  read\n  write\n  execute\n}",
      )
      assert_eq(iface.items[4].to_string(), "resource session;")
      assert_eq(iface.items[5].to_string(), "type id = u64;")
    }
    _ => abort("expected interface")
  }
}

///|
test "parse comma-separated type members" {
  let src =
    #|package test:commas;
    #|interface types {
    #|  record point { x: f32, y: f32, }
    #|  variant value { none, text(string), }
    #|  enum color { red, green, blue, }
    #|  flags access { read, write, }
    #|}
  let p = parse_or_fail(src)
  match p.items[0] {
    Interface(iface) => {
      assert_eq(iface.items.length(), 4)
      assert_eq(
        iface.items[0].to_string(),
        "record point {\n  x: f32\n  y: f32\n}",
      )
      assert_eq(
        iface.items[1].to_string(),
        "variant value {\n  none\n  text(string)\n}",
      )
      assert_eq(
        iface.items[2].to_string(),
        "enum color {\n  red\n  green\n  blue\n}",
      )
      assert_eq(
        iface.items[3].to_string(),
        "flags access {\n  read\n  write\n}",
      )
    }
    _ => abort("expected interface")
  }
}

///|
test "parse functions with optional semicolons" {
  let src =
    #|package test:functions;
    #|interface api {
    #|  ping: func();
    #|  lookup: func(key: string) -> option<string>;
    #|  legacy: func()
    #|}
  let p = parse_or_fail(src)
  match p.items[0] {
    Interface(iface) => {
      assert_eq(iface.items.length(), 3)
      assert_eq(iface.items[0].to_string(), "ping: func()")
      assert_eq(
        iface.items[1].to_string(),
        "lookup: func(key: string) -> option<string>",
      )
      assert_eq(iface.items[2].to_string(), "legacy: func()")
    }
    _ => abort("expected interface")
  }
}

///|
test "parse greeting funcs" {
  let p = parse_or_fail(greeting_wit)
  match p.items[0] {
    Interface(iface) => {
      assert_eq(
        iface.items[6].to_string(),
        "list-people: func(limit: u32) -> list<person>",
      )
      assert_eq(
        iface.items[7].to_string(),
        "make-greeting: func(name: string, t: tone) -> string",
      )
      assert_eq(
        iface.items[8].to_string(),
        "add-person: func(p: person) -> result<u64, string>",
      )
      assert_eq(
        iface.items[9].to_string(),
        "find: func(key: string) -> option<string>",
      )
      assert_eq(
        iface.items[10].to_string(),
        "mix: func(a: u8, b: s8) -> tuple<u32, bool>",
      )
    }
    _ => abort("expected interface")
  }
}

///|
test "parse greeting world with use" {
  let p = parse_or_fail(greeting_wit)
  match p.items[1] {
    World(w) => {
      assert_eq(w.name, "greeting-world")
      assert_eq(w.items.length(), 3)
      match w.items[0] {
        Use(u) => {
          assert_eq(u.path, "types")
          assert_eq(u.names.length(), 2)
          assert_eq(u.names[0].name, "person")
          assert_eq(u.names[1].name, "tone")
        }
        _ => abort("expected use")
      }
      match w.items[1] {
        Import(imp) => {
          assert_eq(imp.name, "types")
          assert_eq(imp.inline is None, true)
        }
        _ => abort("expected import")
      }
    }
    _ => abort("expected world")
  }
}

///|
test "parse direct world functions" {
  let p = parse_or_fail(calculator_wit)
  match p.items[0] {
    World(w) => {
      assert_eq(w.items.length(), 3)
      match w.items[0] {
        ImportFunc(f) => {
          assert_eq(f.name, "log")
          assert_eq(f.params[0].ty.to_string(), "string")
          assert_eq(f.results.length(), 0)
        }
        _ => abort("expected direct function import")
      }
      match w.items[1] {
        ExportFunc(f) => {
          assert_eq(f.name, "add")
          assert_eq(f.params.length(), 2)
          assert_eq(f.results[0].to_string(), "s32")
        }
        _ => abort("expected direct function export")
      }
      match w.items[2] {
        ExportFunc(f) => assert_eq(f.name, "batch-add")
        _ => abort("expected direct function export")
      }
    }
    _ => abort("expected world")
  }
}

///|
test "render direct world functions round trip" {
  let rendered = parse_or_fail(calculator_wit).to_string()
  assert_eq(
    contains_test_str(rendered, "export add: func(a: s32, b: s32) -> s32;"),
    true,
  )
  assert_eq(parse_or_fail(rendered).to_string(), rendered)
}

///|
test "parse resource functions" {
  let p = parse_or_fail(resource_wit)
  match p.items[0] {
    Interface(iface) =>
      match iface.items[0] {
        Type(def) =>
          match def.kind {
            Resource(funcs) => {
              assert_eq(funcs.length(), 3)
              assert_true(funcs[0].kind is Constructor)
              assert_true(funcs[1].kind is Static)
              assert_true(funcs[2].kind is Method)
              assert_eq(funcs[0].sig.results.length(), 0)
              assert_eq(funcs[2].sig.name, "increment")
            }
            _ => abort("expected resource")
          }
        _ => abort("expected type")
      }
    _ => abort("expected interface")
  }
  let rendered = parse_or_fail(resource_wit).to_string()
  assert_eq(parse_or_fail(rendered).to_string(), rendered)
}

///|
test "parse world includes" {
  let p = parse_or_fail(include_wit)
  match p.items[0] {
    World(w) => {
      assert_eq(w.items.length(), 3)
      match w.items[0] {
        Include(path, names) => {
          assert_eq(path, "wasi:cli/run")
          assert_eq(names.length(), 0)
        }
        _ => abort("expected include")
      }
      match w.items[1] {
        Include(path, names) => {
          assert_eq(path, "local:shared/base")
          assert_eq(names.length(), 0)
        }
        _ => abort("expected include")
      }
      match w.items[2] {
        Include(path, names) => {
          assert_eq(path, "local:shared/legacy")
          assert_eq(names[0].name, "old-name")
          assert_eq(names[0].asName, Some("new-name"))
          assert_eq(names[1].asName, Some("start"))
        }
        _ => abort("expected include with renames")
      }
    }
    _ => abort("expected world")
  }
  let rendered = p.to_string()
  assert_eq(parse_or_fail(rendered).to_string(), rendered)
}

///|
test "parse error: include requires a path" {
  let msg = try {
    ignore(parse("package x:y; world w { include ; }"))
    ""
  } catch {
    e => e.to_string()
  }
  assert_eq(msg, "1:32: expected a world path after 'include'")
}

///|
test "parse versioned external WIT paths" {
  let p = parse_or_fail(wasi_paths_wit)
  match p.items[0] {
    Use(u) => {
      assert_eq(u.path, "wasi:io/streams@0.2.0")
      assert_eq(u.names[0].name, "input-stream")
      assert_eq(u.names[0].asName, Some("input"))
    }
    _ => abort("expected top-level use")
  }
  match p.items[1] {
    World(w) => {
      match w.items[0] {
        Import(imp) => assert_eq(imp.name, "wasi:cli/environment@0.2.0")
        _ => abort("expected versioned import")
      }
      match w.items[1] {
        Export(exp) => {
          assert_eq(exp.name, "wasi:cli/run@0.2.0")
          assert_eq(exp.asName, Some("run"))
        }
        _ => abort("expected versioned export")
      }
      match w.items[2] {
        Include(path, _) => assert_eq(path, "wasi:cli/command@0.2.0")
        _ => abort("expected versioned include")
      }
    }
    _ => abort("expected world")
  }
  let rendered = p.to_string()
  assert_eq(parse_or_fail(rendered).to_string(), rendered)
}

///|
test "parse borrow type" {
  let p = parse_or_fail(greeting_wit)
  match p.items[0] {
    Interface(iface) =>
      match iface.items[11] {
        Func(f) => assert_eq(f.params[0].ty.to_string(), "borrow<session>")
        _ => abort("expected func")
      }
    _ => abort("expected interface")
  }
}

///|
test "parse future and stream types" {
  let src =
    #|package test:async;
    #|interface tasks {
    #|  wait: func() -> future<list<u8>>;
    #|  empty: func() -> future<_>;
    #|  events: func() -> stream<string>;
    #|}
  let rendered = parse_or_fail(src).to_string()
  assert_eq(contains_test_str(rendered, "future<list<u8>>"), true)
  assert_eq(contains_test_str(rendered, "future<_>"), true)
  assert_eq(contains_test_str(rendered, "stream<string>"), true)
  assert_eq(parse_or_fail(rendered).to_string(), rendered)
}

///|
test "render package version, wildcard uses and named results" {
  let src =
    #|package test:coverage@1.2.3;
    #|interface api {
    #|  use local:types/all.*;
    #|  status: func() -> (code: u16)
    #|}
    #|world app {
    #|  use local:types/all.*;
    #|}
  let rendered = parse_or_fail(src).to_string()
  assert_eq(contains_test_str(rendered, "package test:coverage@1.2.3;"), true)
  assert_eq(contains_test_str(rendered, "use local:types/all.*;"), true)
  assert_eq(contains_test_str(rendered, "status: func() -> (code: u16)"), true)
  assert_eq(parse_or_fail(rendered).to_string(), rendered)
}

///|
test "parse error: unexpected character" {
  let msg = try {
    ignore(parse("package docs:hello; !"))
    ""
  } catch {
    e => e.to_string()
  }
  assert_eq(msg, "1:21: unexpected character '!'")
}

///|
test "parse error: unterminated block comment" {
  let msg = try {
    ignore(parse("/* never closed"))
    ""
  } catch {
    e => e.to_string()
  }
  assert_eq(msg, "1:16: unterminated block comment")
}

///|
test "parse error: missing identifier with position" {
  let msg = try {
    ignore(parse("package docs:hello;\ninterface {"))
    ""
  } catch {
    e => e.to_string()
  }
  assert_eq(msg, "2:11: expected identifier, found {")
}

///|
test "parse error: missing semicolon" {
  let msg = try {
    ignore(parse("package docs:hello\nworld hi {}"))
    ""
  } catch {
    e => e.to_string()
  }
  assert_eq(msg, "2:1: expected ';', found ident(world)")
}
