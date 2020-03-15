import AST

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

    // TODO: Parse statements.

    // Parse a right brace.
    let rightBraceTok = stream.consume(.rightBrace)
    if rightBraceTok == nil {
      diagnostics.append(expectedError.instantiate(
        at: stream.nextNonCommentToken?.range,
        with: ["'}'"]))
    }

    let range = SourceRange.union(
      of: [leftBraceTok?.range, rightBraceTok?.range].compactMap({ $0 }))
    return BraceStmt(range: range)
  }

  public static let get = BraceStmtParser()

}
