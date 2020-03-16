import AssertThat
import XCTest

import AST
import Parser

class FuncDeclParserTests: XCTestCase, ParserTestCase {

  func testBasic() {
    var stream = tokenize("func foo()")
    var diagnostics: [Diagnostic] = []

    let result = FuncDeclParser.get.parse(stream: &stream, diagnostics: &diagnostics)
    assertThat(diagnostics, .isEmpty)
    assertThat(result, .not(.isNil))

    if let decl = result {
      assertThat(decl.name, .equals("foo"))
      assertThat(decl.signature.parameters, .isEmpty)
      assertThat(decl.range?.description, .equals("1:1..<1:11"))
    }
  }

  func testWithParams() {
    var stream = tokenize("func foo(x: Int, y: Int)")
    var diagnostics: [Diagnostic] = []

    let result = FuncDeclParser.get.parse(stream: &stream, diagnostics: &diagnostics)
    assertThat(diagnostics, .isEmpty)
    assertThat(result, .not(.isNil))

    if let decl = result {
      assertThat(decl.name, .equals("foo"))

      let params = decl.signature.parameters
      assertThat(params, .count(2))

      if params.count >= 2 {
        assertThat(params[0].externalName, .equals("x"))
        assertThat(params[1].externalName, .equals("y"))
      }

      assertThat(decl.range?.description, .equals("1:1..<1:25"))
    }
  }

}
