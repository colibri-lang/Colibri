import AssertThat
import XCTest

import AST
import Parser

class ExprParserTests: XCTestCase, ParserTestCase {

  func testParseUnresolvedDeclRefExpr() {
    var stream = tokenize("foo")
    var diagnostics: [Diagnostic] = []

    let result = PrimaryExprParser.get.parse(stream: &stream, diagnostics: &diagnostics)
    assertThat(diagnostics, .isEmpty)

    assertThat(result, .not(.isNil))
    assertThat(result, .isInstance(of: UnresolvedDeclRefExpr.self))
    if let expr = result as? UnresolvedDeclRefExpr {
      assertThat(expr.name, .equals("foo"))

      assertThat(expr.range?.lowerBound.description, .equals("1:1"))
      assertThat(expr.range?.upperBound.description, .equals("1:4"))
    }
  }

}
