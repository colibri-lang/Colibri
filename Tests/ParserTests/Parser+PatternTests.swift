import AssertThat
import XCTest

import AST
import Parser

class PatternParserTests: XCTestCase, ParserTestCase {

  func testParseNamedPattern() {
    var stream = tokenize("foo")
    var diagnostics: [Diagnostic] = []

    let result = PatternParser.get.parse(stream: &stream, diagnostics: &diagnostics)
    assertThat(diagnostics, .isEmpty)
    assertThat(result, .not(.isNil))
    assertThat(result, .isInstance(of: NamedPattern.self))

    if let pattern = result as? NamedPattern {
      assertThat(pattern.name, .equals("foo"))

      assertThat(pattern.range?.description, .equals("1:1..<1:4"))
    }
  }

  func testParseTuplePattern() {
    var stream = tokenize("(foo, (bar, baz))")
    var diagnostics: [Diagnostic] = []

    let result = PatternParser.get.parse(stream: &stream, diagnostics: &diagnostics)
    assertThat(diagnostics, .isEmpty)
    assertThat(result, .not(.isNil))
    assertThat(result, .isInstance(of: TuplePattern.self))

    if let pattern = result as? TuplePattern {
      assertThat(pattern.elements, .count(2))
      if pattern.elements.count >= 2 {
        assertThat(pattern.elements[0], .isInstance(of: NamedPattern.self))
        assertThat(pattern.elements[1], .isInstance(of: TuplePattern.self))
      }

      assertThat(pattern.range?.description, .equals("1:1..<1:18"))
    }
  }

  func testWildcardPattern() {
    var stream = tokenize("_")
    var diagnostics: [Diagnostic] = []

    let result = PatternParser.get.parse(stream: &stream, diagnostics: &diagnostics)
    assertThat(diagnostics, .isEmpty)
    assertThat(result, .not(.isNil))
    assertThat(result, .isInstance(of: WildcardPattern.self))

    if let pattern = result as? WildcardPattern {
      assertThat(pattern.range?.description, .equals("1:1..<1:2"))
    }
  }

}
