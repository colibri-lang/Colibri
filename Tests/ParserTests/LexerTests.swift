import XCTest

import AST

@testable import Parser

class LexerTests: XCTestCase {
  
  /// Tokenize a String.
  private func tokenize(_ source: String) -> [Token] {
    let translationUnit = TranslationUnit(name: "test", source: source)
    let lexer = Lexer(translationUnit: translationUnit)
    return Array(lexer)
  }
  
  /// Compare the result of the lexer on a String with expected tokens.
  private func checkLex(
    _ source: String,
    _ expectedTokenKinds: [TokenKind],
    _ expectedTokenLengths: [Int]
  ) {
    let tokens = tokenize(source)
    XCTAssertEqual(tokens.map({ $0.kind }), expectedTokenKinds)
    let tokenLengths = tokens.map({ $0.range.upperBound.offset - $0.range.lowerBound.offset })
    XCTAssertEqual(tokenLengths, expectedTokenLengths)
  }
  
  func testLexComments() {
    let source = "//Blah\n(/*yo*/)"
    let expectedTokenKinds: [TokenKind] = [
      .comment, .newline, .leftParenthesis, .multilineComment, .rightParenthesis, .eof
    ]
    let expectedTokenLengths = [6, 1, 1, 6, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }
  
  func testUnterminatedComment() {
    let source = "/* Blah"
    let expectedTokenKinds: [TokenKind] = [.unterminatedComment, .eof]
    let expectedTokenLengths = [7, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }
  
//  func testLexLeftOperator() {
//    let source = "+a"
//    let expectedTokenKinds: [TokenKind] = [.op, .identifier, .eof]
//    let expectedTokenLengths = [1, 1, 0]
//    checkLex(source, expectedTokenKinds, expectedTokenLengths)
//  }
  
  func testTokenIsStartOfLine() {
    let source = "aaa"
    let tokens = Array(Lexer(translationUnit: TranslationUnit(name: "test", source: source)))
    XCTAssertEqual(tokens[0].range.lowerBound.column, 1)
  }
  
  func testLexTrailingComments() {
    let source = "//  comment\naaa //xx \n/* x */"
    let expectedTokenKinds: [TokenKind] = [
      .comment, .newline, .identifier, .comment, .newline, .multilineComment, .eof
    ]
    let expectedTokenLengths = [11, 1, 3, 5, 1, 7, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }
  
  func testLexUnderscore() {
    let source = "_"
    let expectedTokenKinds: [TokenKind] = [.underscore, .eof]
    let expectedTokenLengths = [1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }
  
//  func testLexParentheses() {
//    let source = "(a + b)"
//    let expectedTokenKinds: [TokenKind] = [
//      .leftParenthesis, .identifier, .op, .identifier, .rightParenthesis, .eof
//    ]
//    let expectedTokenLengths = [1, 1, 1, 1, 1, 0]
//    checkLex(source, expectedTokenKinds, expectedTokenLengths)
//  }
  
  func testLexBraces() {
    let source = "{\na\n}"
    let expectedTokenKinds: [TokenKind] = [
      .leftBrace, .newline, .identifier, .newline, .rightBrace, .eof
    ]
    let expectedTokenLengths = [1, 1, 1, 1, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexBrackets() {
    let source = "[1, 2, 3]"
    let expectedTokenKinds: [TokenKind] = [
      .leftBracket, .integerLiteral, .comma, .integerLiteral, .comma, .integerLiteral,
      .rightBracket, .eof
    ]
    let expectedTokenLengths = [1, 1, 1, 1, 1, 1, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }
  
//  func testLexDot() {
//    let source = ".someEnumCase"
//    let expectedTokenKinds: [TokenKind] = [.dot, .identifier, .eof]
//    let expectedTokenLengths = [1, 12, 0]
//    checkLex(source, expectedTokenKinds, expectedTokenLengths)
//  }
  
//  func testLexDotOperator() {
//    let source = ".<."
//    let expectedTokenKinds: [TokenKind] = [.op, .eof]
//    let exptectedTokenLengths = [3, 0]
//    checkLex(source, expectedTokenKinds, exptectedTokenLengths)
//  }
  
  func testLexComma() {
    let source = "(a, b)"
    let expectedTokenKinds: [TokenKind] = [
      .leftParenthesis, .identifier, .comma, .identifier, .rightParenthesis, .eof
    ]
    let expectedTokenLengths = [1, 1, 1, 1, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }
  
  func testLexColon() {
    let source = "let a: Int"
    let expectedTokenKinds: [TokenKind] = [
      .let, .identifier, .colon, .identifier, .eof
    ]
    let expectedTokenLengths = [3, 1, 1, 3, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }
  
//  func testLexAssign() {
//    let source = "a = 0"
//    let expectedTokenKinds: [TokenKind] = [.identifier, .assign, .integerLiteral, .eof]
//    let expectedTokenLengths = [1, 1, 1, 0]
//    checkLex(source, expectedTokenKinds, expectedTokenLengths)
//  }
  
  func testLexArrow() {
    let source = "(Int, Int) -> Bool"
    let expectedTokenKinds: [TokenKind] = [
      .leftParenthesis, .identifier, .comma, .identifier, .rightParenthesis, .arrow, .identifier,
      .eof
    ]
    let expectedTokenLengths = [1, 3, 1, 3, 1, 2, 4, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }
  
  func testLexBacktick() {
    let source = "`class`"
    let expectedTokenKinds: [TokenKind] = [.backtick, .`class`, .backtick, .eof]
    let expectedTokenLengths = [1, 5, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }
  
  func testLexIntegerLiteral() {
    let source = "42"
    let expectedTokenKinds: [TokenKind] = [.integerLiteral, .eof]
    let expectedTokenLengths = [2, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }
  
  func testLexFloatLiteral() {
    let source = "1.2"
    let expectedTokenKinds: [TokenKind] = [.floatLiteral, .eof]
    let expectedTokenLengths = [3, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }
  
  func testStringLiteral() {
    let source = "\"meow\""
    let expectedTokenKinds: [TokenKind] = [.stringLiteral, .eof]
    let expectedTokenLengths = [6, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }
  
//  func testLexBrokenStringLiteral1() {
//    let source = "\"meow\0"
//    let expectedTokenKinds: [TokenKind] = [.unterminatedString, .eof]
//    let expectedTokenLengths = [6, 0]
//    checkLex(source, expectedTokenKinds, expectedTokenLengths)
//  }
  
//  func testLexBrokenStringLiteral2() {
//    let source = "\"\\meow\0"
//    let expectedTokenKinds: [TokenKind] = [.unterminatedString, .eof]
//    let expectedTokenLengths = [7, 0]
//    checkLex(source, expectedTokenKinds, expectedTokenLengths)
//  }
  
  func testLexStringLiteralWithNull() {
    let source = "\"\0\""
    let expectedTokenKinds: [TokenKind] = [.stringLiteral, .eof]
    let expectedTokenLengths = [3, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }
  
//  func testLexOperator() {
//    let source = "%&<%"
//    let expectedTokenKinds: [TokenKind] = [.op, .eof]
//    let expectedTokenLengths = [4, 0]
//    checkLex(source, expectedTokenKinds, expectedTokenLengths)
//  }
  
//  func testDotOperatorMustStartWithDot() {
//    let source = "%>."
//    let expectedTokenKinds: [TokenKind] = [.op, .dot, .eof]
//    let expectedTokenLengths = [2, 1, 0]
//    checkLex(source, expectedTokenKinds, expectedTokenLengths)
//  }

}
