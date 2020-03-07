import AssertThat
import XCTest

import AST
import Parser

class DeclParserTests: XCTestCase {

  func testParsePatter() {
    let buffer = "foo"
    let source = SourceReference(name: "<test>", source: buffer)
    let stream = Array(try! Lexer(sourceRef: source))

    switch PatternParser.get.parse(stream) {
    case .success(let pattern, let remainder, let diagnostics):
      assertThat(pattern, .isInstance(of: NamedPattern.self))
      if let namedPattern = pattern as? NamedPattern {
        assertThat(namedPattern.name, .equals("foo"))
      }

      assertThat(remainder.first, .equals(stream.last))
      assertThat(diagnostics, .isEmpty)

    case .failure(let diagnostics):
      XCTFail("parsing unexpectedly failed with \(diagnostics.count) dignostics")
    }

  }

}
