import AST

public struct PrimaryExprParser: Parser {

  public typealias Element = Expr

  public func parse(_ stream: TokenStream) -> ParseResult<Expr> {
    switch stream.first?.kind {
    case .identifier, .self, .op:
      let expr = UnresolvedDeclRefExpr(name: stream.first!.value!, range: stream.first!.range)
      return .success(expr, stream.dropFirst(), [])

    case .nil:
      let expr = NilLiteralExpr(range: stream.first!.range)
      return .success(expr, stream.dropFirst(), [])

    case .true, .false:
      let value = stream.first!.kind == .true
      let expr = BooleanLiteralExpr(value: value, range: stream.first!.range)
      return .success(expr, stream.dropFirst(), [])

    case .integerLiteral:
      let value = Int(stream.first!.value!)!
      let expr = IntegerLiteralExpr(value: value, range: stream.first!.range)
      return .success(expr, stream.dropFirst(), [])

    case .floatLiteral:
      let value = Double(stream.first!.value!)!
      let expr = FloatLiteralExpr(value: value, range: stream.first!.range)
      return .success(expr, stream.dropFirst(), [])

    case .stringLiteral:
      let value = stream.first!.value!
      let expr = StringLiteralExpr(value: value, range: stream.first!.range)
      return .success(expr, stream.dropFirst(), [])

    case ._file, ._line, ._column, ._function:
      let expr = MagicIdentifierLiteralExpr(range: stream.first!.range)
      return .success(expr, stream.dropFirst(), [])

    default:
      let diagnostics = [expectedError.instantiate(at: stream.first?.range, with: "expression")]
      return .failure(diagnostics)
    }
  }

  public static let get = PrimaryExprParser()

}
