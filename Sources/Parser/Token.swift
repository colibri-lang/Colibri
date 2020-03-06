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
    return try? range.translationUnit.source.read(
      count: range.upperBound.offset - range.lowerBound.offset,
      from: range.lowerBound.offset
    )
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
