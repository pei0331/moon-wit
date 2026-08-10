///|
/// moon-wit CLI: parse a WIT document and generate MoonBit bindings.
///
/// Subcommands:
///   parse <file.wit>          — parse and print the WIT AST (rendered as WIT)
///   gen <file.wit> [-o <dir>] — generate bindings to stdout, or write
///                               `bindings.mbt` + `moon.pkg` into <dir>
///   version                   — print the version
///   help                      — show usage
fn main {
  let args = @env.args()
  let cmd = if args.length() >= 2 { args[1] } else { "" }
  match cmd {
    "parse" => run_parse(args)
    "gen" => run_gen(args)
    "version" => println("moon-wit 0.1.0")
    "help" => print_help()
    _ => {
      if cmd != "" {
        println("error: unknown subcommand '\{cmd}'")
      }
      print_help()
      abort("usage error")
    }
  }
}

///|
fn usage() -> String {
  let mut s = "moon-wit — MoonBit WIT (WebAssembly Interface Types) binding generator\n"
  s = s + "\n"
  s = s + "Usage:\n"
  s = s +
    "  moon-wit parse <file.wit>              Parse and print the WIT AST\n"
  s = s +
    "  moon-wit gen <file.wit> [-o <dir>]     Generate MoonBit bindings (stdout, or write into <dir>)\n"
  s = s + "  moon-wit version                       Print the version\n"
  s = s + "  moon-wit help                          Show this help\n"
  s
}

///|
fn print_help() -> Unit {
  println(usage())
}

///|
/// Print an error then exit non-zero.
fn fail(message : String) -> Unit {
  println("error: \{message}")
  abort("moon-wit: \{message}")
}

///|
fn run_parse(args : Array[String]) -> Unit {
  if args.length() < 3 {
    fail("usage: moon-wit parse <file.wit>")
  }
  let path = args[2]
  let src = read_or_fail(path)
  let pkg = parse_or_fail(src)
  println(pkg.to_string())
}

///|
fn run_gen(args : Array[String]) -> Unit {
  if args.length() < 3 {
    fail("usage: moon-wit gen <file.wit> [-o <dir>]")
  }
  let path = args[2]
  let mut out_dir : String? = None
  let mut i = 3
  while i < args.length() {
    if args[i] == "-o" {
      if i + 1 >= args.length() {
        fail("missing directory after '-o'")
      }
      out_dir = Some(args[i + 1])
      i = i + 2
    } else {
      fail("unexpected argument '\{args[i]}'")
    }
  }
  let src = read_or_fail(path)
  let pkg = parse_or_fail(src)
  let bindings = @wit.generate(pkg)
  let moon_pkg = @wit.generate_moon_pkg(@wit.needs_list_import(pkg))
  match out_dir {
    Some(dir) => {
      if !write_file(dir + "/bindings.mbt", bindings) {
        fail("cannot write '\{dir}/bindings.mbt'")
      }
      if !write_file(dir + "/moon.pkg", moon_pkg) {
        fail("cannot write '\{dir}/moon.pkg'")
      }
      println("wrote \{dir}/bindings.mbt and \{dir}/moon.pkg")
    }
    None => println(bindings)
  }
}

///|
fn read_or_fail(path : String) -> String {
  match read_file(path) {
    Some(s) => s
    None => {
      // `abort` never returns, so this branch coerces to `String`.
      println("error: cannot read file '\{path}'")
      abort("moon-wit: cannot read file '\{path}'")
    }
  }
}

///|
fn parse_or_fail(src : String) -> @wit.WitPackage {
  @wit.parse(src) catch {
    e => {
      println("error: parse error: \{e.to_string()}")
      abort("moon-wit: parse error: \{e.to_string()}")
    }
  }
}
