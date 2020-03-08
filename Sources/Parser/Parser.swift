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
  func parse(_ stream: TokenStream) -> ParseResult<Element>

}

extension Parser {

  public func parse(_ stream: [Token]) -> ParseResult<Element> {
    parse(stream.suffix(from: 0))
  }

}

/// The result of a parser.
public enum ParseResult<Element> {

  /// A parse success.
  case success(Element, TokenStream, [Diagnostic])

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

/// A parser that attempts to apply a first sub-parser, or a second if the former didn't commit.
public struct EitherParser<First, Second>: Parser
  where First: Parser, Second: Parser, First.Element == Second.Element
{

  private let first: First
  private let second: Second

  /// Creates a new instance of an either parser from two sub-parsers.
  ///
  /// - Parameters:
  ///   - first: The first sub-parser to apply.
  ///   - second: The sub-parser to apply if the first failed without committing.
  public init(first: First, second: Second) {
    self.first = first
    self.second = second
  }

  public func parse(_ stream: TokenStream) -> ParseResult<First.Element> {
    let firstParseResult = first.parse(stream)
    switch firstParseResult {
    case .success:
      return firstParseResult
    case .failure:
      return second.parse(stream)
    }
  }

}

extension Parser {

  static func | <Other>(lhs: Self, rhs: Other) -> EitherParser<Self, Other>
    where Other: Parser, Other.Element == Self.Element
  {
    EitherParser(first: lhs, second: rhs)
  }

}

extension Parser {

  /// Attempts to parse a comma-separated list of elements from the given stream.
  ///
  /// This method applies `parse(:)` repeatedly to create a comma-separated list of elements. It
  /// stops when the next token to parse is `terminator` or the end of the stream, or if it fails
  /// completely, that is when `parse(:)` didn't commit and returned a failure.
  ///
  /// This method is intended to be used to parse everything enclosed within list delimiters (e.g.
  /// a comma-separated list of names enclosed in parentheses). Hence leading and trailing newlines
  /// are consumed. Note however that the terminator token is not be consumed and can therefore be
  /// expected to be the next consumable token.
  ///
  /// - Parameters:
  ///   - stream: The stream to parse
  ///   - terminator: The kind of token that designates the terminator of the list.
  func parseList(
    _ stream: TokenStream,
    terminator: TokenKind
  ) -> ([Element], TokenStream, [Diagnostic]) {
    var elements: [Element] = []
    var remainder = stream
    var diagnostics: [Diagnostic] = []

    while true {
      // Skip leading newlines.
      remainder = remainder.trimmed

      // Exit the loop if the next token is `terminator` or if the stream is depleted.
      guard let start = remainder.first, (start.kind != .eof) && (start.kind != terminator)
        else { return (elements, remainder, diagnostics) }

      // Handle leading separators as a particular error case.
      guard start.kind != .comma else {
        diagnostics.append(unexpectedError.instantiate(at: start.range, with: ["',' separator"]))
        remainder = remainder.dropFirst()
        continue
      }

      // Parse one list element from the stream.
      switch parse(remainder) {
      case .success(let element, let rem, let diags):
        elements.append(element)
        remainder = rem.trimmed
        diagnostics.append(contentsOf: diags)

      case .failure(let diags):
        diagnostics.append(contentsOf: diags)
        remainder = remainder.drop(while: { !$0.isStatementDelimiter })
      }

      // The next token should be a separator or a terminator. If it's the former, we shall simply
      // move on to the next element in the list. If it's the latter, the list has been completely
      // parsed and we should exit.
      // Error recovery depends on the token we find. Statement delimiters are used as terminators
      // and exit the loop, whereas any other token is diagnosed as a missing separator.
      switch remainder.first?.kind {
      case .comma:
        remainder = remainder.dropFirst()

      case nil, .eof, .semicolon, .newline, terminator:
        return (elements, remainder, diagnostics)

      default:
        diagnostics.append(
          expectedError.instantiate(at: remainder.first?.range, with: ["',' separator"]))
      }
    }
  }

}
