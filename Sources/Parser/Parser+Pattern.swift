import AST

public struct PatternParser: Parser {

  public typealias Element = Pattern

  public func parse(stream: inout TokenStream, diagnostics: inout [Diagnostic]) -> Pattern? {
    switch stream.peek().kind {
    case .identifier:
      let identTok = stream.consume()
      return NamedPattern(name: identTok.value!, range: identTok.range)


    case .underscore:
      let identTok = stream.consume()
      return WildcardPattern(range: identTok.range)

    case .leftParenthesis:
      let leftParenthesis = stream.consume()
      let elements = list(terminatedBy: .rightParenthesis)
        .parse(stream: &stream, diagnostics: &diagnostics)
      let rightParenthesis = stream.consume(.rightParenthesis)

      return TuplePattern(
        elements: elements ?? [],
        leftParenthesisRange: leftParenthesis.range,
        rightParenthesisRange: rightParenthesis?.range)

    default:
      diagnostics.append(expectedError.instantiate(
        at: stream.nextNonCommentToken?.range,
        with: "pattern"))
      return nil
    }
  }

  public static let get = PatternParser()

}
