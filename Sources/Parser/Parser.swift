import AST

/// A type that represents a parser.
public protocol Parser {

  associatedtype Element

  /// Attempts to parse the given stream to extract a valid output.
  ///
  /// - Parameters:
  ///   - stream: The stream to parse.
  ///   - diagnostics: An array in which append the diagnostics for all issues encounted.
  ///
  /// - Returns: Either a the parsed element or a `nil` if the parser got stuck on a hard failure.
  func parse(stream: inout TokenStream, diagnostics: inout [Diagnostic]) -> Element?

}

extension Parser {

  public func list(terminatedBy terminatorKind: TokenKind) -> ListParser<Self> {
    ListParser(subparser: self, terminatorKind: terminatorKind)
  }

}

public struct ListParser<Subparser>: Parser where Subparser: Parser {

  public typealias Element = [Subparser.Element]

  private let subparser: Subparser

  private let terminatorKind: TokenKind

  public init(subparser: Subparser, terminatorKind: TokenKind) {
    self.subparser = subparser
    self.terminatorKind = terminatorKind
  }

  public func parse(
    stream: inout TokenStream,
    diagnostics: inout [Diagnostic]
  ) -> [Subparser.Element]? {
    var elements: Element = []

    while true {
      // Handle leading terminators and separators.
      switch stream.peek().kind {
      case terminatorKind, .semicolon, .eof:
        // Exit the loop if the next token is the list terminator or if the stream is depleted.
        return elements

      case .comma:
        // Handle leading separators as a particular error case.
        diagnostics.append(unexpectedError.instantiate(
          at: stream.peek(ignoringSkippable: false).range,
          with: ["',' separator"]))
        stream.consume()
        continue

      default:
        break
      }

      // Parse one list element from the stream.
      if let element = subparser.parse(stream: &stream, diagnostics: &diagnostics) {
        elements.append(element)
      } else {
        // Try to recover at the next statement delimiter.
        stream.consume(ignoringSkippable: false, while: { token in !token.isStatementDelimiter })
      }

      // The next token should be a separator or the list terminator. If it's the former, we shall
      // simply move on to the next element in the list. If it's the latter, the list has been
      // completely parsed and we should exit.
      // Error recovery depends on the token we find. Statement delimiters are used as terminators
      // and exit the loop, whereas any other token is diagnosed as a missing separator.

      switch stream.peek().kind {
      case .comma:
        stream.consume()

      case terminatorKind, .semicolon, .eof:
        return elements

      default:
        diagnostics.append(expectedError.instantiate(
          at: stream.peek(ignoringSkippable: false).range,
          with: ["',' separator"]))
      }
    }
  }

}

///// A parser that attempts to apply a first sub-parser, or a second if the former didn't commit.
//public struct EitherParser<First, Second>: Parser
//  where First: Parser, Second: Parser, First.Element == Second.Element
//{
//
//  private let first: First
//  private let second: Second
//
//  /// Creates a new instance of an either parser from two sub-parsers.
//  ///
//  /// - Parameters:
//  ///   - first: The first sub-parser to apply.
//  ///   - second: The sub-parser to apply if the first failed without committing.
//  public init(first: First, second: Second) {
//    self.first = first
//    self.second = second
//  }
//
//  public func parse(_ stream: TokenStream) -> ParseResult<First.Element> {
//    let firstParseResult = first.parse(stream)
//    switch firstParseResult {
//    case .success:
//      return firstParseResult
//    case .failure:
//      return second.parse(stream)
//    }
//  }
//
//}
//
//extension Parser {
//
//  static func | <Other>(lhs: Self, rhs: Other) -> EitherParser<Self, Other>
//    where Other: Parser, Other.Element == Self.Element
//  {
//    EitherParser(first: lhs, second: rhs)
//  }
//
//}
