import AST

public typealias ExprParser = PrimaryExprParser

public struct PrimaryExprParser: Parser {

  public typealias Element = Expr

  public func parse(stream: inout TokenStream, diagnostics: inout [Diagnostic]) -> Expr? {
    switch stream.peek().kind {
    case .identifier, .self, .op:
      let identTok = stream.consume()
      return UnresolvedDeclRefExpr(name: identTok.value!, range: identTok.range)

    case .nil:
      let litTok = stream.consume()
      return NilLiteralExpr(range: litTok.range)

    case .true, .false:
      let litTok = stream.consume()
      let litVal = litTok.kind == .true
      return BooleanLiteralExpr(value: litVal, range: litTok.range)

    case .integerLiteral:
      let litTok = stream.consume()
      let litVal = litTok.value.flatMap(Int.init)!
      return IntegerLiteralExpr(value: litVal, range: litTok.range)

    case .floatLiteral:
      let litTok = stream.consume()
      let litVal = litTok.value.flatMap(Double.init)!
      return FloatLiteralExpr(value: litVal, range: litTok.range)

    case .stringLiteral:
      let litTok = stream.consume()
      let litVal = litTok.value!
      return StringLiteralExpr(value: litVal, range: litTok.range)

    case ._file, ._line, ._column, ._function:
      let litTok = stream.consume()
      return MagicIdentifierLiteralExpr(range: litTok.range)

    default:
      diagnostics.append(expectedError.instantiate(
        at: stream.nextNonCommentToken?.range,
        with: "expression"))
      return nil
    }
  }

  public static let get = PrimaryExprParser()

}
