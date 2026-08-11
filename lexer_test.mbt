///|
/// Direct lexer tests: token kinds, positions and trivia skipping.
/// The parser tests exercise the lexer end-to-end; these pin the token stream
/// itself.

///|
test "lex package header tokens" {
  let toks = tokenize("package docs:hello;")
  assert_eq(toks[0].to_string(), "ident(package)")
  assert_eq(toks[1].to_string(), "ident(docs)")
  assert_eq(toks[2].to_string(), ":")
  assert_eq(toks[3].to_string(), "ident(hello)")
  assert_eq(toks[4].to_string(), ";")
  assert_eq(toks[5].to_string(), "eof")
}

///|
test "lex version token after @" {
  let toks = tokenize("hello@0.1.0 ->")
  assert_eq(toks[0].to_string(), "ident(hello)")
  assert_eq(toks[1].to_string(), "@")
  assert_eq(toks[2].to_string(), "version(0.1.0)")
  assert_eq(toks[3].to_string(), "->")
}

///|
test "lex line and column tracking" {
  let toks = tokenize("a\n  b")
  assert_eq(toks[0].line, 1)
  assert_eq(toks[0].col, 1)
  assert_eq(toks[1].line, 2)
  assert_eq(toks[1].col, 3)
}

///|
test "lex comments are skipped" {
  let toks = tokenize("// hi\n/* block */ a")
  assert_eq(toks[0].to_string(), "ident(a)")
  assert_eq(toks[0].line, 2)
}

///|
test "lex kebab identifier stops at arrow" {
  let toks = tokenize("hello-world -> x")
  assert_eq(toks[0].to_string(), "ident(hello-world)")
  assert_eq(toks[1].to_string(), "->")
  assert_eq(toks[2].to_string(), "ident(x)")
}

///|
test "lex punctuation set" {
  let toks = tokenize("(){}<>:=.,/")
  let kinds : Array[String] = toks.map(fn(t) { t.to_string() })
  let mut joined = ""
  for i in 0..<kinds.length() {
    if i != 0 {
      joined = joined + " "
    }
    joined = joined + kinds[i]
  }
  assert_eq(joined, "( ) { } < > : = . , / eof")
}

///|
test "lex escaped identifiers" {
  let toks = tokenize("%type %hello-world")
  assert_eq(toks[0].to_string(), "ident(%type)")
  assert_eq(toks[1].to_string(), "ident(%hello-world)")
  assert_eq(toks[0].line, 1)
  assert_eq(toks[0].col, 1)
}

///|
test "lex error: percent must escape an identifier" {
  let msg = try {
    ignore(tokenize("%"))
    ""
  } catch {
    e => e.to_string()
  }
  assert_eq(msg, "1:1: expected identifier after '%'")
}
