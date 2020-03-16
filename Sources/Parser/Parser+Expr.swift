import AST

/// Parses for expressions.
///
/// Because this parser is implemented as a recursive descent parser, a particular attention must
/// be made as to how expressions can be parsed witout triggering infinite recursions, due to the
/// left-recursion of the related production rules.
public struct ExprParser: Parser {

  public typealias Element = Expr

  public func parse(stream: inout TokenStream, diagnostics: inout [Diagnostic]) -> Expr? {
    // Parse a prefix expression.
    guard var leftExpr = PrimaryExprParser.get.parse(stream: &stream, diagnostics: &diagnostics)
      else { return nil }

    // As long as we can parse an infix operator after a prefix expression, we must consume it as
    // part of a binary expression. We also deal with precedence and associativity here, so that
    // expressions are parsed into the proper AST.
    while true {
      switch stream.peek().kind {
      case .assign:
        // Parse the source expression after the assignment operator.
        let assignTok = stream.consume()
        guard let rightExpr = parse(stream: &stream, diagnostics: &diagnostics)
          else { return leftExpr }

        // Assignment expressions are always left-associative.
        leftExpr = AssignExpr(
          assignOperatorRange: assignTok.range,
          target: leftExpr,
          source: rightExpr)

      default:
        // We couldn't parse a binary expression. Simply return the prefix expression we parsed
        // from the beginning.
        return leftExpr
      }
    }
  }

  public static let get = ExprParser()

}

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
