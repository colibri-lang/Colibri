import AST
import Utils

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

  /// Whether this token is a skippable token (e.g. a comment, whitespace, ...).
  public var isSkippable: Bool {
    return (kind == .newline)
        || (kind == .comment)
        || (kind == .multilineComment)
        || (kind == .unterminatedComment)
  }

  /// Whether this token is an explicit statement delimiter (i.e. `;` or `EOF`).
  public var isExplicitStatementDelimiter: Bool {
    (kind == .semicolon) || (kind == .eof)
  }

  /// Whether this token is either an explicit statement delimiter or a newline.
  public var isStatementDelimiter: Bool {
    (kind == .newline) || isExplicitStatementDelimiter
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
