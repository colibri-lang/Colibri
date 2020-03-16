public protocol Expr: Node, SourceRepresentable {
  
}

/// A value assignment, like `x = y`.
public struct AssignExpr: Expr {

  /// The source range of the `=` operator.
  public let equalOperatorRange: SourceRange

  /// The left part of the assignment (i.e. the expression to which the value is assigned).
  public let target: Expr

  /// The right part of the assignment (i.e. the value being assigned).
  public let source: Expr

  public var range: SourceRange? {
    return SourceRange.union(of: [
      target.range,
      equalOperatorRange,
      source.range,
    ].compactMap({ $0 }))
  }

  public init(
    equalOperatorRange: SourceRange,
    target: Expr,
    source: Expr
  ) {
    self.equalOperatorRange = equalOperatorRange
    self.target = target
    self.source = source
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

}

/// A `nil` literal.
public final class NilLiteralExpr: Expr {

  public let range: SourceRange?

  public init(range: SourceRange?) {
    self.range = range
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

}

/// A magic identifier (e.g. `#file`) which expends out to a literal during SIL generation.
public final class MagicIdentifierLiteralExpr: Expr {

  public let range: SourceRange?

  public init(range: SourceRange?) {
    self.range = range
  }

}

/// Represets a semantically erroneaus sub-expression.
public final class ErrorExpr: Expr {

  public let range: SourceRange?

  public init(range: SourceRange?) {
    self.range = range
  }

}
