// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Foundation

extension Lexer: IteratorProtocol, Sequence {
  /// Check if an operator at some index in the lexer's stream is left bound.
  ///
  /// - Parameter index: The index of the operator character.
  /// - Returns: A boolean value indicating whether the operator character at the input index is
  ///     left bound or not.
  private func isLeftBound(index: String.UnicodeScalarView.Index) -> Bool {
    if charIndex <= charStream.startIndex {
      return false
    }

    // Read the character at the preceding index in the lexer's stream.
    let previousChar = charStream[charStream.index(before: index)]

    // Whitespaces, statement or expression delimiters and opening delimiters indicate that the
    // operator is not left bound.
    if " \n\t([{,;:".unicodeScalars.contains(previousChar) {
      return false
    }

    // If the previous characters indicate the end of a multiline comment, the operator is not
    // left bound.
    if previousChar == "/" {
      if charStream[charStream.index(index, offsetBy: -2)] == "*" {
         return false
      }
    }

    return true
  }

  /// Check if an operator at some index in the lexer's stream is right bound.
  ///
  /// - Parameter index: The index of the operator character.
  /// - Returns: A boolean value indicating whether the operator character at the input index is
  ///     right bound or not.
  private func isRightBound(index: String.UnicodeScalarView.Index) -> Bool {
    if charIndex >= charStream.endIndex {
      return false
    }

    // Read the character at the next index in the lexer's stream.
    let nextChar = charStream[charStream.index(after: index)]

    // Whitespaces, statement or expression delimiters and opening delimiters indicate that the
    // operator is not right bound.
    if " \n\t)]},;:".unicodeScalars.contains(nextChar) {
      return false
    }

    // Prefer the '^' in "x^.y" to be a postfix op, not binary, but the '^' in
    // "^.y" to be a prefix op, not binary.
    if nextChar == "." {
      return !isLeftBound(index: charIndex)
    }

    if nextChar == "/" {
      let charAfter = charStream[charStream.index(index, offsetBy: 2)]
      if charAfter == "/" || charAfter == "*" {
        return false
      }
    }

    return true
  }

  /// Lex an operator identifier.
  private mutating func lexOperatorIdentifier() -> Token {
    let tokenStart = currentChar
    let tokenStartIndex = charIndex
    let startLocation = sourceLocation

    while let char = currentChar, isOperatorChar(char) {
      // '.' cannot appear in the middle of an operator unless the operator started with a '.'.
      if char == "." && tokenStart != "." {
        break
      }

      // If there is a "//" or "/*" in the middle of an identifier token, it starts a new comment.
      if char == "/" && peek() == "/" || peek() == "*" {
        break
      }

      skip()
    }

    // Decide between the infox, prefix or postfix cases.
    // It's infix if either both sides are bound or both sides are not.
    // Otherwise, it's postfix if left-bound and prefix if right-bound.
    let leftBound = isLeftBound(index: tokenStartIndex)
    let rightBound = isRightBound(index: charIndex)

    let operatorIdentifier = String(charStream[tokenStartIndex ... charIndex])

    // Match various reserved words.
    switch operatorIdentifier {

    case "=":
      if leftBound != rightBound {
        return Token(kind: .unaryEqual, range: range(from: startLocation))
      }
      return Token(kind: .equal, range: range(from: startLocation))

    case "&":
      if leftBound == rightBound || leftBound {
        break
      }
      return Token(kind: .ampersandPrefix, range: range(from: startLocation))

    case ".":
      if leftBound == rightBound {
        return Token(kind: .period, range: range(from: startLocation))
      }

      if rightBound {
        return Token(kind: .periodPrefix, range: range(from: startLocation))
      }

      return Token(kind: .unknown, range: range(from: startLocation))

    case "?":
      if leftBound {
        return Token(kind: .questionPostfix, range: range(from: startLocation))
      }
      return Token(kind: .questionInfix, range: range(from: startLocation))

    case "->":
      return Token(kind: .arrow, range: range(from: startLocation))

    case "*/":
      return Token(kind: .unexpectedCommentEnd, range: range(from: startLocation))

    default:
      if leftBound == rightBound {
        return Token(kind: .infixOperator, range: range(from: startLocation))
      }

      return leftBound
        ? Token(kind: .postfixOperator, range: range(from: startLocation))
        : Token(kind: .prefixOperator, range: range(from: startLocation))
    }
    return Token(kind: .unknown, range: range(from: startLocation))
  }

  /// Lex an escaped identifier.
  private mutating func lexEscapedIdentifier() -> Token {
    let startLocation = sourceLocation

    // Skip the first '`' of the escaped identifier.
    skip()

    if let char = currentChar, !isAlphanumericOrUnderscore(char) {
      // The token is a backtick punctuation token.
      return Token(kind: .backtick, range: range(from: startLocation))
    }

    // Skip the first character of the escaped identifier.
    skip()
    skip(while: { isAlphanumericOrUnderscore($0) || isDigit($0) })

    if currentChar != "`" {
      return Token(kind: .unterminatedEscapedIdentifier, range: range(from: startLocation))
    }

    // Skip the closing '`' of the escaped identifier.
    skip()
    return Token(kind: .escapedIdentifier, range: range(from: startLocation))
  }

  /// Lex an identifier starting with a '$'.
  private mutating func lexDollarIdentifier() -> Token {
    let startLocation = sourceLocation

    // Consume the '$' at the start of the token.
    skip()

    var isAllDigits = true
    var identifier = ""
    while true {
      guard let char = currentChar else { break }

      if isAlphanumericOrUnderscore(char) {
        isAllDigits = false
      } else if !isDigit(char) {
        break
      }

      identifier += String(char)
    }

    // A '$' alone is not a valid token.
    if identifier.count == 0 {
      return Token(kind: .unknown, range: range(from: startLocation))
    }

    if !isAllDigits {
      return Token(kind: .identifier, range: range(from: startLocation))
    } else {
      return Token(kind: .dollarIdentifier, range: range(from: startLocation))
    }
  }

  /// Lex an identifier or a keyword.
  private mutating func lexIdentifier() -> Token {
    let startLocation = sourceLocation

    let identifier = String(consume(while: { isAlphanumericOrUnderscore($0) || isDigit($0) }))
    let tokenKind: TokenKind

    switch identifier {
    case "associatedtype":
      tokenKind = .associatedtype
    case "class":
      tokenKind = .class
    case "deinit":
      tokenKind = .`deinit`
    case "enum":
      tokenKind = .enum
    case "extension":
      tokenKind = .extension
    case "fileprivate":
      tokenKind = .fileprivate
    case "func":
      tokenKind = .func
    case "import":
      tokenKind = .import
    case "init":
      tokenKind = .`init`
    case "inout":
      tokenKind = .inout
    case "internal":
      tokenKind = .internal
    case "let":
      tokenKind = .let
    case "open":
      tokenKind = .open
    case "operator":
      tokenKind = .operator
    case "private":
      tokenKind = .private
    case "protocol":
      tokenKind = .protocol
    case "public":
      tokenKind = .public
    case "rethrows":
      tokenKind = .rethrows
    case "static":
      tokenKind = .static
    case "struct":
      tokenKind = .struct
    case "subscript":
      tokenKind = .subscript
    case "typealias":
      tokenKind = .typealias
    case "var":
      tokenKind = .var
    case "break":
      tokenKind = .break
    case "case":
      tokenKind = .case
    case "continue":
      tokenKind = .continue
    case "default":
      tokenKind = .default
    case "defer":
      tokenKind = .defer
    case "do":
      tokenKind = .do
    case "else":
      tokenKind = .else
    case "fallthrough":
      tokenKind = .fallthrough
    case "for":
      tokenKind = .for
    case "guard":
      tokenKind = .guard
    case "if":
      tokenKind = .if
    case "in":
      tokenKind = .in
    case "repeat":
      tokenKind = .repeat
    case "return":
      tokenKind = .return
    case "switch":
      tokenKind = .switch
    case "where":
      tokenKind = .where
    case "while":
      tokenKind = .while
    case "as":
      tokenKind = .as
    case "Any":
      tokenKind = .Any
    case "catch":
      tokenKind = .catch
    case "false":
      tokenKind = .false
    case "is":
      tokenKind = .is
    case "nil":
      tokenKind = .nil
    case "super":
      tokenKind = .super
    case "self":
      tokenKind = .`self`
    case "Self":
      tokenKind = .`Self`
    case "throw":
      tokenKind = .throw
    case "throws":
      tokenKind = .throws
    case "true":
      tokenKind = .true
    case "try":
      tokenKind = .try
    case "#available":
      tokenKind = ._available
    case "#colorLiteral":
      tokenKind = ._colorLiteral
    case "#column":
      tokenKind = ._column
    case "#else":
      tokenKind = ._else
    case "#elseif":
      tokenKind = ._elseif
    case "#endif":
      tokenKind = ._endif
    case "#error":
      tokenKind = ._error
    case "#file":
      tokenKind = ._file
    case "#fileLiteral":
      tokenKind = ._fileLiteral
    case "#function":
      tokenKind = ._function
    case "#if":
      tokenKind = ._if
    case "#imageLiteral":
      tokenKind = ._imageLiteral
    case "#line":
      tokenKind = ._line
    case "#selector":
      tokenKind = ._selector
    case "#sourceLocation":
      tokenKind = ._sourceLocation
    case "#warning":
      tokenKind = ._warning
    case "associativity":
      tokenKind = .associativity
    case "convenience":
      tokenKind = .convenience
    case "dynamic":
      tokenKind = .dynamic
    case "didSet":
      tokenKind = .didSet
    case "final":
      tokenKind = .final
    case "get":
      tokenKind = .get
    case "infix":
      tokenKind = .infix
    case "indirect":
      tokenKind = .indirect
    case "lazy":
      tokenKind = .lazy
    case "left":
      tokenKind = .left
    case "mutating":
      tokenKind = .mutating
    case "none":
      tokenKind = .none
    case "nonmutating":
      tokenKind = .nonmutating
    case "optional":
      tokenKind = .optional
    case "override":
      tokenKind = .override
    case "postfix":
      tokenKind = .postfix
    case "precedence":
      tokenKind = .precedence
    case "prefix":
      tokenKind = .prefix
    case "Protocol":
      tokenKind = .Protocol
    case "required":
      tokenKind = .required
    case "right":
      tokenKind = .right
    case "set":
      tokenKind = .set
    case "Type":
      tokenKind = .Type
    case "unowned":
      tokenKind = .unowned
    case "weak":
      tokenKind = .weak
    case "willset":
      tokenKind = .willset
    case "owned":
      tokenKind = .owned
    case "shared":
      tokenKind = .shared
    default:
      tokenKind = .identifier
    }

    return Token(kind: tokenKind, range: range(from: startLocation))
  }

  /// Lex an integer or floating point literal.
  private mutating func lexNumberLiteral() -> Token {
    let startLocation = sourceLocation

    let char = currentChar
    let nextChar = peek()

    // Lex a hexadecimal number.
    if char == "0", nextChar == "x" {
      skip(while: { isDigit($0) || "ABCDEF".unicodeScalars.contains($0) || $0 == "_" })
      return Token(kind: .integerLiteral, range: range(from: startLocation))
    }

    // Lex an octal number.
    if char == "0", nextChar == "o" {
      skip(while: { "01234567".unicodeScalars.contains($0) || $0 == "_" })
      return Token(kind: .integerLiteral, range: range(from: startLocation))
    }

    // Lex a binary number.
    if char == "0", nextChar == "b" {
      skip(while: { "01".unicodeScalars.contains($0) || $0 == "_" })
      return Token(kind: .integerLiteral, range: range(from: startLocation))
    }

    skip(while: { isDigit($0) || $0 == "_" })

    if currentChar == "." {
      // 'x.0.1' is sub-tuple access, not x.float_literal.
      if let nextChar = peek(), !isDigit(nextChar) || peek(at: 2) == "." {
        return Token(kind: .integerLiteral, range: range(from: startLocation))
      }

      // Lex any digits after the decimal point.
      skip(while: { isDigit($0) || $0 == "_" })

      // Lex exponent.
      if currentChar == "e" || currentChar == "E" {
        // Skip the 'e' or 'E'.
        skip()

        // Skip the sign.
        if currentChar == "+" || currentChar == "-" {
          skip()
        }

        // The exponent must start with a digit.
        if let char = currentChar, !isDigit(char) {
          return Token(kind: .invalidFloatLiteral, range: range(from: startLocation))
        }

        skip(while: { isDigit($0) || $0 == "_" })

        return Token(kind: .floatLiteral, range: range(from: startLocation))
      }
    } else {
      // Floating literals must have '.', 'e', or 'E' after digits. If it is
      // something else, then this is the end of the token.
      if currentChar != "e" || currentChar != "E" {
        return Token(kind: .integerLiteral, range: range(from: startLocation))
      }
    }

    return Token(kind: .unknown, range: range(from: startLocation))
  }

  /// Lex a string literal.
  private mutating func lexStringLiteral() -> Token {
    let startLocation = sourceLocation
    var isMultiline = false

    // Consume the first '"' or "'" of the string.
    let startingQuote = currentChar
    skip()

    // Consume the two other '"' or "'" if the string is multiline.
    if let nextChar = peek(), nextChar == startingQuote,
       let charAfter = peek(at: 2), charAfter == startingQuote {
      skip(2)
      isMultiline = true
    }

    var isInterpolated = false
    var interpolationStarted = false
    while true {
      // Check that the string is terminated.
      guard charIndex < charStream.endIndex else {
        return Token(kind: .unterminatedStringLiteral, range: range(from: startLocation))
      }

      // Check for the end of the string.
      if let char = currentChar, char == startingQuote {
        if isMultiline {
          if let nextChar = peek(), nextChar == startingQuote,
             let charAfter = peek(at: 2), charAfter == startingQuote {
            skip(3)
            break
          }
        } else {
          skip()
          break
        }
      }

      // Check for interpolated values in the string.
      if !interpolationStarted, currentChar == "\\", peek() == "(" {
        interpolationStarted = true
      }
      if interpolationStarted, currentChar == ")" {
        isInterpolated = true
      }

      skip()
    }

    if isMultiline {
      if isInterpolated {
        return Token(kind: .multilineInterpolatedStringLiteral, range: range(from: startLocation))
      }
      return Token(kind: .multilineStringLiteral, range: range(from: startLocation))
    } else {
      if isInterpolated {
        return Token(kind: .interpolatedStringLiteral, range: range(from: startLocation))
      }
      return Token(kind: .stringLiteral, range: range(from: startLocation))
    }
  }

  /// Get the next token in the lexer's stream.
  public mutating func next() -> Token? {
    guard !depleted else { return nil }

    skip(while: isWhiteSpace)

    // Read the current character in the stream.
    guard let char = currentChar else {
      // Handle the end-of-file.
      defer { depleted = true }
      return Token(kind: .eof, range: range(from: sourceLocation))
    }

    // Record the index of the character being observed by the lexer.
    let currentIndex = charIndex

    // Remember the start location of the token to form its range.
    let startLocation = sourceLocation
    switch char {
    // MARK: Statement delimiters.
    case "\n":
      skip()
      return Token(kind: .newline, range: range(from: startLocation))

    case ";":
      skip()
      return Token(kind: .semicolon, range: range(from: startLocation))
    // MARK: Punctuation.
    case "@":
      skip()
      return Token(kind: .at, range: range(from: startLocation))

    case "{":
      skip()
      return Token(kind: .leftBrace, range: range(from: startLocation))

    case "[":
      skip()
      return Token(kind: .leftBracket, range: range(from: startLocation))

    case "(":
      skip()
      return Token(kind: .leftParenthesis, range: range(from: startLocation))

    case "}":
      skip()
      return Token(kind: .rightBrace, range: range(from: startLocation))

    case "]":
      skip()
      return Token(kind: .rightBracket, range: range(from: startLocation))

    case ")":
      skip()
      return Token(kind: .rightParenthesis, range: range(from: startLocation))

    case ",":
      skip()
      return Token(kind: .comma, range: range(from: startLocation))

    case ":":
      skip()
      return Token(kind: .colon, range: range(from: startLocation))

    case "\\":
      skip()
      return Token(kind: .backslash, range: range(from: startLocation))
    // MARK: Comments.
    case "/":
      let nextChar = peek()

      if nextChar == "/" {
        skip(while: { $0 != "\n" })
        return Token(kind: .comment, range: range(from: startLocation))
      }

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

      // If the '/' char is not the start of a comment, lex an operator and return it.
      return lexOperatorIdentifier()

    // MARK: Special operator characters.
    case "!":
      if isLeftBound(index: currentIndex) {
        skip()
        return Token(kind: .exclamationPostfix, range: range(from: startLocation))
      }
      return lexOperatorIdentifier()

    case "?":
      if isLeftBound(index: currentIndex) {
        skip()
        return Token(kind: .questionPostfix, range: range(from: startLocation))
      }
      return lexOperatorIdentifier()

    case "$":
      return lexDollarIdentifier()

    case "`":
      return lexEscapedIdentifier()

    default:
      // MARK: Identifiers and keywords.
      if isAlphanumericOrUnderscore(char) {
        return lexIdentifier()
      }

      // MARK: String literals.
      if char == "'" || char == "\"" {
        return lexStringLiteral()
      }

      // MARK: Integer and float literals.
      if isDigit(char) {
        return lexNumberLiteral()
      }

      // MARK: Operator identifiers.
      if isOperatorHead(char) {
        return lexOperatorIdentifier()
      }

    }

    skip()
    return Token(kind: .unknown, range: range(from: startLocation))
  }

}


// MARK: Helper functions.

/// Check whether a character is a white space.
private func isWhiteSpace(_ char: UnicodeScalar) -> Bool {
  return char == " " || char == "\t"
}

/// Check whether a character is a number.
private func isDigit(_ char: UnicodeScalar) -> Bool {
  return CharacterSet.decimalDigits.contains(char)
}

/// Check whether a character is alphanumeric or an underscore.
private func isAlphanumericOrUnderscore(_ char: UnicodeScalar) -> Bool {
  return char == "_" || CharacterSet.alphanumerics.contains(char)
}

private let operatorHeadRanges = [
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

private let operatorHeadScalars = operatorHeadRanges.reduce(
  into: Set<UnicodeScalar>(),
  {set, range in set.formUnion(range.compactMap(UnicodeScalar.init))}
)
  .union([0x00b6, 0x00bb, 0x00bf, 0x00d7, 0x00f7, 0x3030]
  .compactMap( UnicodeScalar.init ))
  .union(Set<UnicodeScalar>("/=-+!*%<>&|^~?".unicodeScalars))

/// Check whether a character is an operator head.
private func isOperatorHead(_ char: UnicodeScalar) -> Bool {
  return operatorHeadScalars.contains(char)
}

private let operatorRanges = [
  0x0300 ... 0x036f,
  0x1dc0 ... 0x1dff,
  0x20d0 ... 0x20ff,
  0xfe00 ... 0xfe0f,
  0xfe20 ... 0xfe2f,
  0xe0100 ... 0xe01ef
]

private let operatorScalars = operatorRanges.reduce(
  into: Set<UnicodeScalar>(),
  {set, range in set.formUnion(range.compactMap(UnicodeScalar.init))}
)

/// Check whether a character is a valid operator char.
private func isOperatorChar(_ char: UnicodeScalar) -> Bool {
  return operatorScalars.contains(char) || isOperatorHead(char)
}
