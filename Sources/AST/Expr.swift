public protocol Expr: Node, SourceRepresentable {
  
}

/// A value assignment, like `x = y`.
public final class AssignExpr: Expr {

  /// The source range of the `=` operator.
  public let assignOperatorRange: SourceRange

  /// The left part of the assignment (i.e. the expression to which the value is assigned).
  public var target: Expr

  /// The right part of the assignment (i.e. the value being assigned).
  public var source: Expr

  public var range: SourceRange? {
    return SourceRange.union(of: [
      target.range,
      assignOperatorRange,
      source.range,
    ].compactMap({ $0 }))
  }

  public init(
    assignOperatorRange: SourceRange,
    target: Expr,
    source: Expr
  ) {
    self.assignOperatorRange = assignOperatorRange
    self.target = target
    self.source = source
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// A reference to a value whose declaration has yet to be resolved.
///
/// This reoresents an unresolved identifier which may refer to a declaration that will be resolved
/// during sema, or simply an unknown identifier.
public final class UnresolvedDeclRefExpr: Expr {

  /// The name of the identifier.
  public let name: String

  public let range: SourceRange?

  public init(name: String, range: SourceRange?) {
    self.name = name
    self.range = range
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// A `nil` literal.
public final class NilLiteralExpr: Expr {

  public let range: SourceRange?

  public init(range: SourceRange?) {
    self.range = range
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// A boolean literal.
public final class BooleanLiteralExpr: Expr {

  /// The literal's value.
  public let value: Bool

  public let range: SourceRange?

  public init(value: Bool, range: SourceRange?) {
    self.value = value
    self.range = range
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// An integer literal.
public final class IntegerLiteralExpr: Expr {

  /// The literal's value.
  public let value: Int

  public let range: SourceRange?

  public init(value: Int, range: SourceRange?) {
    self.value = value
    self.range = range
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// A float literal.
public final class FloatLiteralExpr: Expr {

  /// The literal's value.
  public let value: Double

  public let range: SourceRange?

  public init(value: Double, range: SourceRange?) {
    self.value = value
    self.range = range
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// A string literal.
public final class StringLiteralExpr: Expr {

  /// The literal's value.
  public let value: String

  public let range: SourceRange?

  public init(value: String, range: SourceRange?) {
    self.value = value
    self.range = range
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// A magic identifier (e.g. `#file`) which expends out to a literal during SIL generation.
public final class MagicIdentifierLiteralExpr: Expr {

  public let range: SourceRange?

  public init(range: SourceRange?) {
    self.range = range
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// Represets a semantically erroneaus sub-expression.
public final class ErrorExpr: Expr {

  public let range: SourceRange?

  public init(range: SourceRange?) {
    self.range = range
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}
