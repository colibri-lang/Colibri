import AssertThat
import XCTest

import AST
import Parser

class FuncDeclParserTests: XCTestCase, ParserTestCase {

  func testParse() {
    var stream = tokenize("func foo()")
    var diagnostics: [Diagnostic] = []

    let result = FuncDeclParser.get.parse(stream: &stream, diagnostics: &diagnostics)
    assertThat(diagnostics, .isEmpty)
    assertThat(result, .not(.isNil))

    if let decl = result {
      assertThat(decl.name, .equals("foo"))

      let signature = decl.signature
      assertThat(signature.parameters, .isEmpty)

      assertThat(decl.range?.description, .equals("1:1..<1:11"))
    }
  }

}
