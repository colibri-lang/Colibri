import AST

public struct PrimaryExprParser: Parser {

  public typealias Element = Expr

  public func parse(_ stream: TokenStream) -> ParseResult<Expr> {
    switch stream.first?.kind {
    case .identifier:
      let expr = UnresolvedDeclRefExpr(name: stream.first!.value!, range: stream.first!.range)
      return .success(expr, stream.dropFirst(), [])

    default:
      let diagnostics = [expectedError.instantiate(at: stream.first?.range, with: "expression")]
      return .failure(diagnostics)
    }
  }

  public static let get = PrimaryExprParser()

}
