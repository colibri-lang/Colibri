import AssertThat
import XCTest

import AST
import Parser

private let source =
"""
/* public */ struct Player {
  var name: String
}
"""

class TokenStreamTests: XCTestCase {

  var tokens: [Token] = []
  var stream: TokenStream!

  override func setUp() {
    let unit = TranslationUnit(name: "<test>", source: source)
    tokens = Array(try! Lexer(translationUnit: unit))
    stream = TokenStream(lexer: try! Lexer(translationUnit: unit))
  }

  func testFirst() {
    XCTAssertEqual(
      stream.first(where: { _ in true }),
      tokens[1])

    XCTAssertEqual(
      stream.first(ignoringSkippable: false, where: { _ in true }),
      tokens[0])

    XCTAssertEqual(
      stream.first(where: { tok in tok.kind == .identifier }),
      tokens.first(where: { tok in tok.kind == .identifier }))

    XCTAssertEqual(
      stream.first(where: { tok in tok.kind == .Self }),
      nil)

    XCTAssertEqual(
      stream.first(where: { tok in tok.kind == .var }),
      tokens.first(where: { tok in tok.kind == .var }))
  }

  func testPeek() {
    XCTAssertEqual(stream.peek(), tokens[1])

    // Consume two tokens from the stream, one being skippable.
    stream.consume()

    XCTAssertEqual(stream.peek(), tokens[2])

    // Consume two tokens from the stream.
    stream.consume()
    stream.consume()

    XCTAssertEqual(stream.peek(), tokens[5])

    XCTAssertEqual(stream.peek(ignoringSkippable: false), tokens[4])
  }

  func testConsume() {
    XCTAssertEqual(stream.consume(), tokens[1])
    XCTAssertEqual(stream.consume(), tokens[2])
    XCTAssertEqual(stream.consume(), tokens[3])

    XCTAssertEqual(stream.consume(ignoringSkippable: false), tokens[4])
  }

  func testConsumeKind() {
    XCTAssertEqual(stream.consume(.struct), tokens[1])
    XCTAssertEqual(stream.consume(.identifier), tokens[2])
    XCTAssertEqual(stream.consume(.leftBrace), tokens[3])

    XCTAssertNil(stream.consume(.newline))
    XCTAssertEqual(stream.consume(ignoringSkippable: false, .newline), tokens[4])
  }

  func testConsumeKinds() {
    XCTAssertEqual(stream.consume([.struct]), tokens[1])
    XCTAssertEqual(stream.consume([.identifier]), tokens[2])
    XCTAssertEqual(stream.consume([.leftBrace]), tokens[3])

    XCTAssertNil(stream.consume([.newline]))
    XCTAssertEqual(stream.consume(ignoringSkippable: false, [.newline]), tokens[4])
  }

  func testConsumePredicate() {
    XCTAssertEqual(stream.consume(if: { $0.kind == .struct }), tokens[1])
    XCTAssertEqual(stream.consume(if: { $0.kind == .identifier }), tokens[2])
    XCTAssertEqual(stream.consume(if: { $0.kind == .leftBrace }), tokens[3])

    XCTAssertNil(stream.consume(if: { $0.kind == .newline }))
    XCTAssertEqual(
      stream.consume(ignoringSkippable: false, if: { $0.kind == .newline }),
      tokens[4])
  }

  func testConsumeWhile() {
    XCTAssertEqual(
      Array(stream.consume(while: { $0.kind != .leftBrace })),
      Array(tokens[1 ..< 3]))

    XCTAssertEqual(
      Array(stream.consume(ignoringSkippable: false, while: { $0.kind != .colon })),
      Array(tokens[3 ..< 7]))
  }

}
