import AST

/// A type that represents a parser.
public protocol Parser {

  associatedtype Element

  /// Attempts to parse the given stream to extract a valid output.
  ///
  /// - Parameter stream: The stream to parse
  /// - Returns:
  ///     Either a pair containing the parsed element and the remainder of the stream, or a parse
  ///     error if the element could not be parsed.
  func parse(_ stream: ArraySlice<Token>) -> ParseResult<Element>

}

extension Parser {

  public func parse(_ stream: [Token]) -> ParseResult<Element> {
    parse(stream.suffix(from: 0))
  }

}

/// The result of a parser.
public enum ParseResult<Element> {

  /// A parse success.
  case success(Element, ArraySlice<Token>, [Diagnostic])

  /// A parse failure.
  case failure([Diagnostic])

  /// The diagnostics for the issues that occured while parsing (or failing to parse) the element.
  public var diagnostics: [Diagnostic] {
    switch self {
    case .success(_, _, let diags):
      return diags
    case .failure(let diags):
      return diags
    }
  }

}

extension ArraySlice where Element == Token {

  /// Returns this token stream without its leading newlines.
  var trimmed: ArraySlice {
    drop(while: { $0.kind == .newline })
  }

}
