import AST

public struct PatternParser: Parser {

  public typealias Element = Pattern

  public func parse(_ stream: TokenStream) -> ParseResult<Pattern> {
    switch stream.first?.kind {
    case .identifier:
      let pattern = NamedPattern(name: stream.first!.value!, range: stream.first!.range)
      return .success(pattern, stream.dropFirst(), [])

    case .underscore:
      let pattern = WildcardPattern(range: stream.first!.range)
      return .success(pattern, stream.dropFirst(), [])

    case .leftParenthesis:
      let (elts, rem, diags) = parseList(stream.dropFirst(), terminator: .rightParenthesis)

      let leftParenthesisToken = stream.first
      let rightParenthesisToken: Token?
      let remainder: TokenStream

      if rem.first?.kind == .rightParenthesis {
        rightParenthesisToken = rem.first!
        remainder = rem.dropFirst()
      } else {
        rightParenthesisToken = nil
        remainder = rem
      }

      let pattern = TuplePattern(
        elements: elts,
        leftParenthesisRange: leftParenthesisToken?.range,
        rightParenthesisRange: rightParenthesisToken?.range)
      return .success(pattern, remainder, diags)

    default:
      let diagnostics = [expectedError.instantiate(at: stream.first?.range, with: "pattern")]
      return .failure(diagnostics)
    }
  }

  public static let get = PatternParser()

}
