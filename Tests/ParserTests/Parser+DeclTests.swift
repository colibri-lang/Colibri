import AssertThat
import XCTest

import AST
import Parser

class DeclParserTests: XCTestCase {

  func testParsePattern() {
    let stream = tokenize("foo")

    check(PatternParser.get.parse(stream)) { pattern in
      assertThat(pattern, .isInstance(of: NamedPattern.self))
      if let namedPattern = pattern as? NamedPattern {
        assertThat(namedPattern.name, .equals("foo"))
      }

      assertThat(pattern.range, .not(.isNil))
      assertThat(pattern.range, .equals(stream.first?.range))
    }
  }

  func testParseTuplePattern() {
    let stream = tokenize("(foo, (bar, baz))")

    check(PatternParser.get.parse(stream)) { pattern in
      assertThat(pattern, .isInstance(of: TuplePattern.self))
      if let tuplePattern = pattern as? TuplePattern {
        assertThat(tuplePattern.elements, .count(2))
        if tuplePattern.elements.count >= 2 {
          assertThat(tuplePattern.elements[0], .isInstance(of: NamedPattern.self))
          assertThat(tuplePattern.elements[1], .isInstance(of: TuplePattern.self))
        }
      }

      assertThat(pattern.range, .not(.isNil))
      assertThat(pattern.range?.lowerBound, .equals(stream.first?.range.lowerBound))
      assertThat(pattern.range?.upperBound, .equals(stream.dropLast().last?.range.upperBound))
    }
  }

  private func tokenize(_ buffer: String) -> [Token] {
    let source = SourceReference(name: "<test>", source: buffer)
    return Array(try! Lexer(sourceRef: source))
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
