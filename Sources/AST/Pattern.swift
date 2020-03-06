/// A pattern.
public protocol Pattern: SourceRepresentable {
}

/// A pattern taht consists of an (untyped) sub-pattern and a type annotation.
public final class TypedPattern: Pattern {

  /// The (untyped) sub-pattern.
  public let subpattern: Pattern

  /// The type location annotating this pattern.
  public let annotation: TypeLocation

  public var range: SourceRange {
    return subpattern.range.lowerBound ..< annotation.range.upperBound
  }

  public init(subpattern: Pattern, annotation: TypeLocation) {
    self.subpattern = subpattern
    self.annotation = annotation
  }

}

/// A pattern which binds a name to a value of its type.
public final class NamedPattern: Pattern {

  /// The variable declaration associated with this pattern.
  public weak var decl: VarDecl?

  /// The name of this patterm.
  public let name: String

  public let range: SourceRange

  public init(name: String, range: SourceRange) {
    self.name = name
    self.range = range
  }

}

/// A pattern that consists of a tuple of patterns.
public final class TuplePattern: Pattern {

  /// The elements of this pattern.
  public var elements: [Pattern]

  public let range: SourceRange

  public init(elements: [Pattern], range: SourceRange) {
    self.elements = elements
    self.range = range
  }

}
