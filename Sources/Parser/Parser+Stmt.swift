import AST

public struct StmtParser: Parser {

  public typealias Element = Stmt

  public func parse(stream: inout TokenStream, diagnostics: inout [Diagnostic]) -> Stmt? {
    switch stream.peek().kind {
    case .return:
      return ReturnStmtParser.get.parse(stream: &stream, diagnostics: &diagnostics)

    default:
      diagnostics.append(expectedError.instantiate(
        at: stream.nextNonCommentToken?.range,
        with: ["statement"]))
      return nil
    }
  }

  public static let get = StmtParser()

}

public struct BraceStmtParser: Parser {

  public typealias Element = BraceStmt

  public func parse(stream: inout TokenStream, diagnostics: inout [Diagnostic]) -> BraceStmt? {
    // Parse a left brace.
    var leftBraceTok = stream.consume(.leftBrace)
    if leftBraceTok == nil {
      diagnostics.append(expectedError.instantiate(
        at: stream.nextNonCommentToken?.range,
        with: ["'{'"]))

      // Attempt to recover by looking for a left brace on the same line.
      stream.consume(ignoringSkippable: false, while: { tok in
        (tok.kind != .leftBrace) && (tok.kind != .newline)
      })
      leftBraceTok = stream.consume(.leftBrace)
      guard leftBraceTok != nil
        else { return nil }
    }
    assert(leftBraceTok != nil)

    var statements: [Node] = []
    while (stream.peek().kind != .rightBrace) && (stream.peek().kind != .eof) {
      // Ignore any number of leading semicolons.
      stream.consume(while: { tok in tok.kind == .semicolon })

      // Attempt to parse a statement.
      if stream.isAtStartOfStmt {
        if let stmt = StmtParser.get.parse(stream: &stream, diagnostics: &diagnostics) {
          statements.append(stmt)
        } else {
          // Recover at the next statement terminator.
          stream.consume(ignoringSkippable: false, while: { tok in !tok.isStmtTerminator })
        }
        continue
      }

      // Attempt to parse an expression.
      let backtrackingPoint = stream.backtrackingPoint()
      var diags: [Diagnostic] = []
      if let expr = ExprParser.get.parse(stream: &stream, diagnostics: &diags) {
        diagnostics.append(contentsOf: diags)
        statements.append(expr)
        continue
      } else {
        stream.rewind(to: backtrackingPoint)
        diagnostics.append(expectedError.instantiate(
          at: stream.nextNonCommentToken?.range,
          with: ["statement"]))

        // Recover at the next statement terminator.
        stream.consume(ignoringSkippable: false, while: { tok in !tok.isStmtTerminator })
        continue
      }
    }

    // Parse a right brace.
    let rightBraceTok = stream.consume(.rightBrace)
    if rightBraceTok == nil {
      diagnostics.append(expectedError.instantiate(
        at: stream.nextNonCommentToken?.range,
        with: ["'}'"]))
    }

    let range = SourceRange.union(
      of: [leftBraceTok?.range, rightBraceTok?.range].compactMap({ $0 }))
    return BraceStmt(statements: statements, range: range)
  }

  public static let get = BraceStmtParser()

}

public struct ReturnStmtParser: Parser {

  public typealias Element = ReturnStmt

  public func parse(stream: inout TokenStream, diagnostics: inout [Diagnostic]) -> ReturnStmt? {
    // Parse a 'return' keyword.
    guard let returnTok = stream.consume(.return) else {
      diagnostics.append(expectedError.instantiate(
        at: stream.nextNonCommentToken?.range,
        with: ["'return'"]))
      return nil
    }

    let backtrackingPoint = stream.backtrackingPoint()
    var diags: [Diagnostic] = []
    if let expr = ExprParser.get.parse(stream: &stream, diagnostics: &diags) {
      diagnostics.append(contentsOf: diags)
      return ReturnStmt(returnKeywordRange: returnTok.range, expr: expr)
    } else {
      stream.rewind(to: backtrackingPoint)
    }

    return ReturnStmt(returnKeywordRange: returnTok.range)
  }

  public static let get = ReturnStmtParser()

}
