public protocol Expr: SourceRepresentable {
  
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
