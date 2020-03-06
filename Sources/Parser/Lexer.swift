import AST

public struct Lexer {
  
  /// The stream of characters the lexer must process.
  internal var charStream: String.UnicodeScalarView

  /// The position of the lexer in the character stream.
  internal var charIndex: String.UnicodeScalarView.Index

  /// A boolean value indicating whether all characters have been consumed from the stream.
  internal var depleted: Bool
  
  /// The current location pointed to by the lexer in the source.
  internal var sourceLocation: SourceLocation
  
  /// The character currently being pointed to by the lexer in the stream.
  internal var currentChar: UnicodeScalar? {
    return charIndex < charStream.endIndex
      ? charStream[charIndex]
      : nil
  }
  
  public init(translationUnit: TranslationUnit) throws {
    charStream = translationUnit.source.unicodeScalars
    charIndex = charStream.startIndex
    sourceLocation = SourceLocation(translationUnit: translationUnit)
    depleted = false
  }
  
  /// Skip 'count' characters in the lexer's stream.
  ///
  /// - Parameter count: The number of characters to skip.
  internal mutating func skip(_ count: Int = 1) {
    for _ in 0 ..< count {
      // Check that the end of the stream hasn't been reached yet.
      guard let char = currentChar else { return }
      
      if char == "\n" {
        sourceLocation.line += 1
        sourceLocation.column = 1
      } else {
        sourceLocation.column += 1
      }
      sourceLocation.offset += 1
      charIndex = charStream.index(after: charIndex)
    }
  }
  
  /// Skip characters in the lexer's stream while some predicate is true.
  ///
  /// - Parameter predicate: A function from unicode scalars to booleans representing a predicate
  ///     that must be verified.
  internal mutating func skip(while predicate: (UnicodeScalar) -> Bool) {
    while let char = currentChar, predicate(char) {
      skip()
    }
  }
  
  /// Consume characters from the lexer's stream while some predicate is true and return them.
  ///
  /// - Parameter predicate: A function from unicode scalars to booleans representing a predicate
  ///     that must be verified.
  /// - Returns: A string subsequence containing the characters consumed from the stream.
  internal mutating func consume(
    while predicate: (UnicodeScalar) -> Bool
  ) -> String.UnicodeScalarView.SubSequence {
    let startIndex = charIndex
    skip(while: predicate)
    return charStream[startIndex ..< charIndex]
  }
  
  /// Peek at the character that is 'offset' away from the one currently being pointed to by the
  /// lexer.
  ///
  /// - Parameter offset: The offset to peek at from the current index.
  /// - Returns: The character 'offset' away from the one at the lexer's current index.
  internal func peek(at offset: Int = 1) -> UnicodeScalar? {
    let peekIndex = charStream.index(charIndex, offsetBy: offset)
    return peekIndex < charStream.endIndex
      ? charStream[peekIndex]
      : nil
  }
  
  /// Create a range from some location to the one currently being pointed to by the lexer.
  ///
  /// - Parameter start: The SourceLocation to start the range from.
  /// - Returns: A SourceRange from 'start' to the current SourceLocation of the lexer.
  internal func range(from start: SourceLocation) -> SourceRange {
    return start ..< sourceLocation
  }
  
}
