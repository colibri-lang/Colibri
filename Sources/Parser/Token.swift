import AST

/// A lexical token in a Colibri source.
///
/// A lexical token represents a unit of text that has a meaning in the language's syntax.
public struct Token {
  
  /// The kind of the token.
  public let kind: TokenKind

  /// The range of characters covered by the token in the source.
  public let range: SourceRange
  
  /// The text the token corresponds to in the source.
  public var value: String? {
    return String(
      range.translationUnit.source
        .dropFirst(range.lowerBound.offset)
        .prefix(range.upperBound.offset - range.lowerBound.offset))
  }

  /// Whether this token is at the beginning of a line.
  public var isAtStartOfLine: Bool {
    let startOffset = range.lowerBound.offset
    guard startOffset > 0
      else { return true }

    let source = range.lowerBound.translationUnit.source
    let index = source.index(source.startIndex, offsetBy: startOffset - 1)
    return source[index].isNewline
  }

  /// Whether this token is an operator.
  public var isOperator: Bool {
    return (kind == .prefixOperator)
        || (kind == .postfixOperator)
        || (kind == .infixOperator)
  }

  /// Whether this token is a keyword.
  public var isKeyword: Bool {
    // TODO: Implement me with sourcery!
    return false
  }

  /// Whether this token is a comment.
  public var isComment: Bool {
    return (kind == .comment)
        || (kind == .multilineComment)
        || (kind == .unterminatedComment)
  }

  /// Whether this token is a skippable token (e.g. a comment, whitespace, ...).
  public var isSkippable: Bool {
    return (kind == .newline)
        || isComment
  }

  /// Whether this token is an explicit statement terminator (i.e. `;` or `EOF`).
  public var isExplicitStmtTerminator: Bool {
    return (kind == .semicolon)
        || (kind == .eof)
  }

  /// Whether this token is either an explicit statement terminator or a newline.
  public var isStmtTerminator: Bool {
    return (kind == .newline)
        || isExplicitStmtTerminator
  }
  
  public init(kind: TokenKind, range: SourceRange) {
    self.kind = kind
    self.range = range
  }
  
}

extension Token: Equatable {
  
  public static func == (lhs: Token, rhs: Token) -> Bool {
    return lhs.kind == rhs.kind && lhs.value == rhs.value && lhs.range == rhs.range
  }
  
}

extension Token: CustomStringConvertible {
  
  public var description: String {
    return kind.description
  }
  
}
