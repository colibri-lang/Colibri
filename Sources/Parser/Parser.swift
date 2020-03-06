import AST

/// A type that represents a parser.
public protocol Parser {

  associatedtype Element

  /// Attempts to parse the given stream to extract a valid output.
  ///
  /// - Parameter stream: The stream to parse
  /// - Returns:
  ///     Either pair containing the parsed element and the remainder of the stream, or a parse
  ///     error if the element could not be parsed.
  func parse(_ stream: ArraySlice<Token>) -> ParseResult<Element>

}

extension Parser {

  func parse(_ stream: [Token]) -> ParseResult<Element> {
    parse(stream.suffix(from: 0))
  }

}

/// The result of a parser.
public enum ParseResult<Element> {

  /// A parse success.
  case success(Element, ArraySlice<Token>)

  /// A parse failure.
  case failure(Diagnostic)

}
