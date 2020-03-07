/// An access control modifier.
public final class AccessModifier: SourceRepresentable {

  /// An access control level.
  public enum Level {

    case open
    case `public`
    case `internal`
    case `fileprivate`
    case `private`

  }

  /// The access control level designated by this node.
  public let level: Level

  public let range: SourceRange

  public init(level: Level, range: SourceRange) {
    self.level = level
    self.range = range
  }

}

/// A declaration modifier.
public final class DeclModifier: SourceRepresentable {

  /// A kind of declaration modifier.
  public enum Kind {

    case `class`
    case convenience
    case final
    case infix
    case lazy
    case override
    case postfix
    case prefix
    case required
    case `static`
    case unowned
    case weak

  }

  /// The kind of this declaration modifier.
  public let kind: Kind

  public let range: SourceRange

  public init(kind: Kind, range: SourceRange) {
    self.kind = kind
    self.range = range
  }

}

/// A declaration that consists of a pattern and an optional initializer for the variables declared
/// in this pattern.
///
/// For example, the following declaration contains a tuple pattern (which consists itself of two
/// named patterns) that is bound to the result of a function call.
///
/// ```colibri
/// let (a, b) = foo()
/// ```
public final class PatternBindingDecl {

  /// The access control modifiers attached to this declaration.
  public var accessModifiers: [AccessModifier]

  /// The declaration modifiers attached to this declaration.
  public var declModifiers: [DeclModifier]

  /// The source range of the `let` or `var` keyword.
  public let letVarKeywordRange: SourceRange

  /// The pattern being bound.
  public let pattern: Pattern

  /// The initializer for the variables declared by the pattern.
  public let initializer: Expr?

  public var range: SourceRange {
    let start = [
      accessModifiers.map({ $0.range.lowerBound }),
      declModifiers.map({ $0.range.lowerBound }),
    ].joined().min() ?? letVarKeywordRange.lowerBound

    return start ..< start
  }

  public init(
    accessModifiers: [AccessModifier] = [],
    declModifiers: [DeclModifier] = [],
    letVarKeywordRange: SourceRange,
    pattern: Pattern,
    initializer: Expr? = nil
  ) {
    self.accessModifiers = accessModifiers
    self.declModifiers = declModifiers
    self.letVarKeywordRange = letVarKeywordRange
    self.pattern = pattern
    self.initializer = initializer
  }

}

/// A variable declaration.
public final class VarDecl: SourceRepresentable {

  /// The variable's name.
  public let name: String

  /// The pattern from which this variable declaration is implied.
  public var pattern: Pattern?

  public let range: SourceRange

  public init(name: String, range: SourceRange) {
    self.name = name
    self.range = range
  }

}
