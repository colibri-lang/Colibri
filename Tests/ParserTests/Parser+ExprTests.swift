import AssertThat
import XCTest

import AST
import Parser

class ExprParserTests: XCTestCase {

  func testParseUnresolvedDeclRefExpr() {
    let stream = tokenize("foo")

    check(PrimaryExprParser.get.parse(stream)) { expr in
      assertThat(expr, .isInstance(of: UnresolvedDeclRefExpr.self))
      if let unresolvedDeclRefExpr = expr as? UnresolvedDeclRefExpr {
        assertThat(unresolvedDeclRefExpr.name, .equals("foo"))
      }

      assertThat(expr.range, .not(.isNil))
      assertThat(expr.range, .equals(stream.first?.range))
    }
  }

  private func tokenize(_ buffer: String) -> [Token] {
    let source = TranslationUnit(name: "<test>", source: buffer)
    return Array(try! Lexer(translationUnit: source))
  }

  private func check<Element>(_ parseResult: ParseResult<Element>, assertions: (Element) -> Void) {
    switch parseResult {
    case .success(let element, let remainder, let diagnostics):
      // check the given assertions.
      assertions(element)

      // The parser should have consumed all tokens from the stream but `EOF` and shouldn't have
      // diagnosed any issue.
      assertThat(remainder.first?.kind, .equals(.eof))
      assertThat(diagnostics, .isEmpty)

    case .failure(let diagnostics):
      XCTFail("parsing unexpectedly failed with \(diagnostics.count) dignostics")
    }
  }

}
