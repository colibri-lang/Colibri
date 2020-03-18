public protocol Stmt: Node, SourceRepresentable {
}

public final class BraceStmt: Stmt {

  /// The statements contained in this scope.
  ///
  /// This array may contain any AST node. This is so that we can parse any kind of expression in a
  /// brace statement before the sema is able to determine which one shouldn't be allowed (e.g.
  /// because they resolve to an unused variable).
  public var statements: [Node]

  public let range: SourceRange?

  public init(
    statements: [Node] = [],
    range: SourceRange? = nil
  ) {
    self.statements = statements
    self.range = range
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

public final class ReturnStmt: Stmt {

  /// The source range of the `return` keyword.
  public let returnKeywordRange: SourceRange

  /// The returned expression, if present.
  public var expr: Expr?

  /// Whether or not this return statement is implicit.
  public let isImplicit: Bool

  public var range: SourceRange? {
    guard !isImplicit
      else { return nil }

    if let exprRange = expr?.range {
      return returnKeywordRange.lowerBound ..< exprRange.upperBound
    } else {
      return returnKeywordRange
    }
  }

  public init(
    returnKeywordRange: SourceRange,
    expr: Expr? = nil,
    isImplicit: Bool = false
  ) {
    self.returnKeywordRange = returnKeywordRange
    self.expr = expr
    self.isImplicit = isImplicit
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}
