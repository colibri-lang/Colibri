/// A pattern.
public protocol Pattern: SourceRepresentable {
}

/// A pattern taht consists of an (untyped) sub-pattern and a type annotation.
public final class TypedPattern: Pattern {

  /// The (untyped) sub-pattern.
  public let subpattern: Pattern

  /// The type location annotating this pattern.
  public let annotation: TypeLocation

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

}

/// A pattern that consists of a tuple of patterns.
public final class TuplePattern: Pattern {

  /// The elements of this pattern.
  public var elements: [Pattern]

  /// The source range of the left parenthesis token.
  public let leftParenthesisRange: SourceRange?

  /// The source range of the right parenthesis token.
  public let rightParenthesisRange: SourceRange?

  public var range: SourceRange? {
    if let lower = leftParenthesisRange, let upper = rightParenthesisRange {
      return lower.lowerBound ..< upper.upperBound
    }

    let elementsRange = SourceRange.union(of: elements.compactMap({ $0.range }))
    let lower = leftParenthesisRange ?? elementsRange ?? rightParenthesisRange
    let upper = rightParenthesisRange ?? elementsRange ?? leftParenthesisRange

    return lower != nil
      ? lower!.lowerBound ..< upper!.upperBound
      : nil
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

}

/// An invalid pattern.
///
/// This type is used to represent ill-formed ASTs.
public struct InvalidPattern: Pattern {

  public let range: SourceRange?

  public init(range: SourceRange?) {
    self.range = range
  }

}
