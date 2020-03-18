/// A pattern.
public protocol Pattern: Node, SourceRepresentable {
}

/// A pattern taht consists of an (untyped) sub-pattern and a type annotation.
public final class TypedPattern: Pattern {

  /// The (untyped) sub-pattern.
  public var subpattern: Pattern

  /// The type location annotating this pattern.
  public var annotation: TypeLocation

  public var range: SourceRange? {
    guard let lower = subpattern.range ?? annotation.range
      else { return nil }
    let upper = annotation.range ?? lower
    return lower.lowerBound ..< upper.upperBound
  }

  public init(subpattern: Pattern, annotation: TypeLocation) {
    self.subpattern = subpattern
    self.annotation = annotation
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// A pattern which binds a name to a value of its type.
public final class NamedPattern: Pattern {

  /// The variable declaration associated with this pattern.
  public weak var decl: VarDecl?

  /// The name of this patterm.
  public let name: String

  public let range: SourceRange?

  public init(name: String, range: SourceRange) {
    self.name = name
    self.range = range
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// A pattern that consists of a tuple of patterns.
public final class TuplePattern: Pattern, ParenthesizedNode {

  /// The elements of this pattern.
  public var elements: [Pattern]

  public let leftParenthesisRange: SourceRange?

  public let rightParenthesisRange: SourceRange?

  public var contentRange: SourceRange? {
    SourceRange.union(of: elements.compactMap({ $0.range }))
  }

  public init(
    elements: [Pattern],
    leftParenthesisRange: SourceRange? = nil,
    rightParenthesisRange: SourceRange? = nil)
  {
    self.elements = elements
    self.leftParenthesisRange = leftParenthesisRange
    self.rightParenthesisRange = rightParenthesisRange
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// A pattern that matches an arbitrary value, but does not bind it to a name.
///
/// - Note: This corresponds to `AnyPattern` in swiftc.
public final class WildcardPattern: Pattern {

  public let range: SourceRange?

  public init(range: SourceRange?) {
    self.range = range
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// An error pattern.
///
/// This type is used to represent ill-formed ASTs.
public struct ErrorPattern: Pattern {

  public let range: SourceRange?

  public init(range: SourceRange?) {
    self.range = range
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}
