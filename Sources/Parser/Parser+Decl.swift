import AST

public struct PatternBindingDeclParser: Parser {

  public typealias Element = (decl: PatternBindingDecl, vars: [VarDecl])

  public func parse(_ stream: TokenStream) -> ParseResult<Element> {
    // Parses the `let` or `var` keyword that introduces the pattern.
    let startToken: Token
    switch stream.first?.kind {
    case .let, .var:
      startToken = stream.first!

    default:
      let diagnostics = [expectedError.instantiate(at: stream.first?.range, with: "let or var")]
      return .failure(diagnostics)
    }

    // Commit to parse a pattern binding declaration from this point.
    var remainder = stream.dropFirst()
    var diagnostics: [Diagnostic] = []

    // Parses a pattern.
    let pattern: Pattern
    switch PatternParser.get.parse(remainder.trimmed) {
    case .success(let pat, let rem, let diags):
      pattern = pat
      remainder = rem
      diagnostics.append(contentsOf: diags)

    case .failure(let diags):
      let range = remainder.first?.range
        ?? startToken.range.upperBound ..< startToken.range.upperBound
      pattern = InvalidPattern(range: range)
      diagnostics.append(contentsOf: diags)
    }

    // Create the declaration.
    let decl = PatternBindingDecl(letVarKeywordRange: startToken.range, pattern: pattern)
    return .success((decl: decl, vars: []), remainder, diagnostics)
  }

  public static let get = PatternBindingDeclParser()

}

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
