import AssertThat
import XCTest

import AST
import Parser

class BraceStmtParserTests: XCTestCase, ParserTestCase {

  func testEmptyBrace() {
    var stream = tokenize("{ }")
    var diagnostics: [Diagnostic] = []

    let result = BraceStmtParser.get.parse(stream: &stream, diagnostics: &diagnostics)
    assertThat(diagnostics, .isEmpty)
    assertThat(result, .not(.isNil))

    if let stmt = result {
      assertThat(stmt.statements, .isEmpty)
      assertThat(stmt.range?.description, .equals("1:1..<1:4"))
    }
  }

  func testNonEmptyBrace() {
    var stream = tokenize("{ return 0 }")
    var diagnostics: [Diagnostic] = []

    let result = BraceStmtParser.get.parse(stream: &stream, diagnostics: &diagnostics)
    assertThat(diagnostics, .isEmpty)
    assertThat(result, .not(.isNil))

    if let stmt = result {
      assertThat(stmt.statements, .count(1))
      assertThat(stmt.range?.description, .equals("1:1..<1:13"))
    }
  }

}

class ReturnStmtParserTests: XCTestCase, ParserTestCase {

  func testReturnVoid() {
    var stream = tokenize("return")
    var diagnostics: [Diagnostic] = []

    let result = ReturnStmtParser.get.parse(stream: &stream, diagnostics: &diagnostics)
    assertThat(diagnostics, .isEmpty)
    assertThat(result, .not(.isNil))

    if let stmt = result {
      assertThat(stmt.expr, .isNil)
      assertThat(stmt.range?.description, .equals("1:1..<1:7"))
    }
  }

  func testReturnExpr() {
    var stream = tokenize("return foo")
    var diagnostics: [Diagnostic] = []

    let result = ReturnStmtParser.get.parse(stream: &stream, diagnostics: &diagnostics)
    assertThat(diagnostics, .isEmpty)
    assertThat(result, .not(.isNil))

    if let stmt = result {
      assertThat(stmt.expr, .isInstance(of: Expr.self))
      assertThat(stmt.range?.description, .equals("1:1..<1:11"))
    }
  }

}
