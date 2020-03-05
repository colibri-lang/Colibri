// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

extension Lexer: IteratorProtocol, Sequence {

  /// Get the next token in the lexer's stream.
  public mutating func next() -> Token? {
    guard !depleted else { return nil }

    skip(while: isWhiteSpace)

    // End-of-file.
    guard let char = currentChar else {
      defer { depleted = true }
      return Token(kind: .eof, range: range(from: sourceLocation))
    }

    let startLocation = sourceLocation

    // Statement delimiters.
    if char == "\n" {
      skip()
      return Token(kind: .newline, range: range(from: startLocation))
    }
    if char == ";" {
      skip()
      return Token(kind: .semicolon, range: range(from: startLocation))
    }

    // Comments.
    if char == "/" {
      let nextChar = peek()

      // Line comment.
      if nextChar == "/" {
        skip(while: { $0 != "\n" })
        return Token(kind: .comment, range: range(from: startLocation))
      }

      // Multiline comment.
      if nextChar == "*" {
        skip(2)
        while currentChar != "*" || peek() != "/" {
          // Check if the end of the stream has been reached (the comment is unterminated).
          guard charIndex < charStream.endIndex else {
            skip(while: { _ in true })
            return Token(kind: .unterminatedComment, range: range(from: startLocation))
          }
          skip()
        }

        skip(2)
        return Token(kind: .multilineComment, range: range(from: startLocation))
      }
    }

    // Integer and floating point literals.
    if isDigit(char) {
      skip(while: isDigit)

      // Float literals.
      if currentChar == ".", let nextChar = peek(), isDigit(nextChar) {
        skip()
        skip(while: isDigit)
        return Token(kind: .floatLiteral, range: range(from: startLocation))
      }

      return Token(kind: .integerLiteral, range: range(from: startLocation))
    }

    // String literals.
    if char == "\"" {
      skip()

      while currentChar != "\"" {
        // Check if the end of the stream has been reached (the string is unterminated).
        guard charIndex < charStream.endIndex else {
          skip(while: { _ in true })
          return Token(kind: .unterminatedString, range: range(from: startLocation))
        }
        skip()
        // Skip escaped quotes.
        if currentChar == "\\" && peek() == "\"" {
          skip(2)
        }
      }

      skip()
      return Token(kind: .stringLiteral, range: range(from: startLocation))
    }

    // Identifiers and keywords.
    if isAlphanumericOrUScore(char) {
      let characters = String(consume(while: isAlphanumericOrUScore))
      let tokenKind: TokenKind

      switch characters {
      // Keywords.
      case "_": tokenKind = .underscore
      case "associatedtype": tokenKind = .associatedtype
      case "class": tokenKind = .class
      case "deinit": tokenKind = .`deinit`
      case "enum": tokenKind = .enum
      case "extension": tokenKind = .extension
      case "fileprivate": tokenKind = .fileprivate
      case "func": tokenKind = .func
      case "import": tokenKind = .import
      case "init": tokenKind = .`init`
      case "inout": tokenKind = .inout
      case "internal": tokenKind = .internal
      case "let": tokenKind = .let
      case "open": tokenKind = .open
      case "operator": tokenKind = .operator
      case "private": tokenKind = .private
      case "protocol": tokenKind = .protocol
      case "public": tokenKind = .public
      case "rethrows": tokenKind = .rethrows
      case "static": tokenKind = .static
      case "struct": tokenKind = .struct
      case "subscript": tokenKind = .subscript
      case "typealias": tokenKind = .typealias
      case "var": tokenKind = .var
      case "break": tokenKind = .break
      case "case": tokenKind = .case
      case "continue": tokenKind = .continue
      case "default": tokenKind = .default
      case "defer": tokenKind = .defer
      case "do": tokenKind = .do
      case "else": tokenKind = .else
      case "fallthrough": tokenKind = .fallthrough
      case "for": tokenKind = .for
      case "guard": tokenKind = .guard
      case "if": tokenKind = .if
      case "in": tokenKind = .in
      case "repeat": tokenKind = .repeat
      case "return": tokenKind = .return
      case "switch": tokenKind = .switch
      case "where": tokenKind = .where
      case "while": tokenKind = .while
      case "as": tokenKind = .as
      case "Any": tokenKind = .Any
      case "catch": tokenKind = .catch
      case "false": tokenKind = .false
      case "is": tokenKind = .is
      case "nil": tokenKind = .nil
      case "super": tokenKind = .super
      case "self": tokenKind = .`self`
      case "Self": tokenKind = .`Self`
      case "throw": tokenKind = .throw
      case "throws": tokenKind = .throws
      case "true": tokenKind = .true
      case "try": tokenKind = .try
      case "#available": tokenKind = ._available
      case "#colorLiteral": tokenKind = ._colorLiteral
      case "#column": tokenKind = ._column
      case "#else": tokenKind = ._else
      case "#elseif": tokenKind = ._elseif
      case "#endif": tokenKind = ._endif
      case "#error": tokenKind = ._error
      case "#file": tokenKind = ._file
      case "#fileLiteral": tokenKind = ._fileLiteral
      case "#function": tokenKind = ._function
      case "#if": tokenKind = ._if
      case "#imageLiteral": tokenKind = ._imageLiteral
      case "#line": tokenKind = ._line
      case "#selector": tokenKind = ._selector
      case "#sourceLocation": tokenKind = ._sourceLocation
      case "#warning": tokenKind = ._warning
      case "associativity": tokenKind = .associativity
      case "convenience": tokenKind = .convenience
      case "dynamic": tokenKind = .dynamic
      case "didSet": tokenKind = .didSet
      case "final": tokenKind = .final
      case "get": tokenKind = .get
      case "infix": tokenKind = .infix
      case "indirect": tokenKind = .indirect
      case "lazy": tokenKind = .lazy
      case "left": tokenKind = .left
      case "mutating": tokenKind = .mutating
      case "none": tokenKind = .none
      case "nonmutating": tokenKind = .nonmutating
      case "optional": tokenKind = .optional
      case "override": tokenKind = .override
      case "postfix": tokenKind = .postfix
      case "precedence": tokenKind = .precedence
      case "prefix": tokenKind = .prefix
      case "Protocol": tokenKind = .Protocol
      case "required": tokenKind = .required
      case "right": tokenKind = .right
      case "set": tokenKind = .set
      case "Type": tokenKind = .Type
      case "unowned": tokenKind = .unowned
      case "weak": tokenKind = .weak
      case "willset": tokenKind = .willset
      default: tokenKind = .identifier
      }

      return Token(kind: tokenKind, range: range(from: startLocation))
    }

    // Reserved punctuation.
    if isPunctuation(char) {
      // Handle the two-characters punctuation token '->'.
      if char == "-", let nextChar = peek(), nextChar == ">" {
        skip(2)
        return Token(kind: .arrow, range: range(from: startLocation))
      }

      // Handle the reserved punctuation token '='.
      if char == "=", let nextChar = peek(), !isOperatorChar(nextChar) {
        skip()
        return Token(kind: .assign, range: range(from: startLocation))
      }
    }

    // Operators.
    if isOperatorHead(char) {
      skip(while: isOperatorChar)
      return Token(kind: .op, range: range(from: startLocation))
    }
    // Operators can contain dots on the condition that they start with one and do not consist in
    // only a single dot.
    if char == ".", let nextChar = peek(), isOperatorChar(nextChar) || nextChar == "." {
      skip(while: { isOperatorChar($0) || $0 == "." } )
      return Token(kind: .op, range: range(from: startLocation))
    }

    // Punctuation.
    if isPunctuation(char) {
      let tokenKind: TokenKind

      switch char {
      case "(": tokenKind = .leftParenthesis
      case ")": tokenKind = .rightParenthesis
      case "{": tokenKind = .leftBrace
      case "}": tokenKind = .rightBrace
      case "[": tokenKind = .leftBracket
      case "]": tokenKind = .rightBracket
      case ".": tokenKind = .dot
      case ",": tokenKind = .comma
      case ":": tokenKind = .colon
      case "@": tokenKind = .at
      case "#": tokenKind = .pound
      case "`": tokenKind = .backtick
      default:  tokenKind = .unknown
      }

      skip()
      return Token(kind: tokenKind, range: range(from: startLocation))
    }

    skip()
    return Token(kind: .unknown, range: range(from: startLocation))
  }

}

/// Check whether a character is a white space.
private func isWhiteSpace(_ char: UnicodeScalar) -> Bool {
  return char == " " || char == "\t"
}

/// Check whether a character is a number.
private func isDigit(_ char: UnicodeScalar) -> Bool {
  return CharacterSet.decimalDigits.contains(char)
}

/// Check whether a character is alphanumeric or an underscore.
private func isAlphanumericOrUScore(_ char: UnicodeScalar) -> Bool {
  return CharacterSet.alphanumerics.contains(char)
}

/// Check whether a character is an operator head.
private func isOperatorHead(_ char: UnicodeScalar) -> Bool {
  let ranges = [
    0x00a1 ... 0x00a7,
    0x00a9 ... 0x00ab,
    0x00ac ... 0x00ae,
    0x00b0 ... 0x00b1,
    0x2016 ... 0x2017,
    0x2020 ... 0x2027,
    0x2030 ... 0x203e,
    0x2041 ... 0x2053,
    0x2055 ... 0x205e,
    0x2190 ... 0x23ff,
    0x2500 ... 0x2775,
    0x2794 ... 0x2bff,
    0x2e00 ... 0x2e7f,
    0x3001 ... 0x3003,
    0x3008 ... 0x3020
  ]
  let scalars = ranges.reduce(
    into: Set<UnicodeScalar>(),
    {set, range in set.formUnion(range.compactMap(UnicodeScalar.init))}
  )
    .union([0x00b6, 0x00bb, 0x00bf, 0x00d7, 0x00f7, 0x3030].compactMap( UnicodeScalar.init ))
    .union(Set<UnicodeScalar>("/=-+!*%<>&|^~?".unicodeScalars))
  return scalars.contains(char)
}

/// Check whether a character is an operator character.
private func isOperatorChar(_ char: UnicodeScalar) -> Bool {
  let ranges = [
    0x0300 ... 0x036f,
    0x1dc0 ... 0x1dff,
    0x20d0 ... 0x20ff,
    0xfe00 ... 0xfe0f,
    0xfe20 ... 0xfe2f,
    0xe0100 ... 0xe01ef
  ]
  let scalars = ranges.reduce(
    into: Set<UnicodeScalar>(),
    {set, range in set.formUnion(range.compactMap(UnicodeScalar.init))}
  )
  return scalars.contains(char) || isOperatorHead(char)
}

/// Check whether a character is punctuation.
private func isPunctuation(_ char: UnicodeScalar) -> Bool {
  Set<UnicodeScalar>("(){}[].,:@#->=`".unicodeScalars).contains(char)
}
