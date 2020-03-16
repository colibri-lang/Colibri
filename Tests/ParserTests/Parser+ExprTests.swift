import AssertThat
import XCTest

import AST
import Parser

class ExprParserTests: XCTestCase, ParserTestCase {

  func testAssignExpr() {
    var stream = tokenize("foo = bar")
    var diagnostics: [Diagnostic] = []

    let result = ExprParser.get.parse(stream: &stream, diagnostics: &diagnostics)
    assertThat(diagnostics, .isEmpty)
    assertThat(result, .not(.isNil))
    assertThat(result, .isInstance(of: AssignExpr.self))

    if let expr = result as? AssignExpr {
      assertThat(expr.target, .isInstance(of: UnresolvedDeclRefExpr.self))
      assertThat(expr.source, .isInstance(of: UnresolvedDeclRefExpr.self))
      assertThat(expr.range?.description, .equals("1:1..<1:10"))
    }

  }

  func testUnresolvedDeclRefExpr() {
    var stream = tokenize("foo")
    var diagnostics: [Diagnostic] = []

    let result = ExprParser.get.parse(stream: &stream, diagnostics: &diagnostics)
    assertThat(diagnostics, .isEmpty)
    assertThat(result, .not(.isNil))
    assertThat(result, .isInstance(of: UnresolvedDeclRefExpr.self))

    if let expr = result as? UnresolvedDeclRefExpr {
      assertThat(expr.name, .equals("foo"))
      assertThat(expr.range?.description, .equals("1:1..<1:4"))
    }
  }

}
