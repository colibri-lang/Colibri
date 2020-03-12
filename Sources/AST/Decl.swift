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

  public let range: SourceRange?

  public init(level: Level, range: SourceRange?) {
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

  public let range: SourceRange?

  public init(kind: Kind, range: SourceRange?) {
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

  /// The source range of the `let` or `var` keyword.
  public let letVarKeywordRange: SourceRange

  /// The pattern being bound.
  public let pattern: Pattern

  /// The initializer for the variables declared by the pattern.
  public let initializer: Expr?

  public var range: SourceRange? {
    let start = letVarKeywordRange.lowerBound
    let end = pattern.range?.upperBound ?? letVarKeywordRange.upperBound
    return start ..< end
  }

  public init(
    letVarKeywordRange: SourceRange,
    pattern: Pattern,
    initializer: Expr? = nil
  ) {
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

  public let range: SourceRange?

  public init(name: String, range: SourceRange?) {
    self.name = name
    self.range = range
  }

}

/// A function declaration.
public final class FuncDecl: SourceRepresentable {

  /// The source range of the `func` keyword.
  public let funcKeywordRange: SourceRange

  /// The function's name.
  ///
  /// Note:
  ///   This property is an instance of `DeclName` (defined in `AST/Identifier.h`) in swiftc rather
  ///   than a simple string. A `DeclName` can be a single identifier or a compound declaration
  ///   name which I think is something of the form `foo(bar:baz:)`.
  public let name: String

  /// The declaration of the operator corresponding to this function's identifier, if it implements
  /// an operator.
  public var operatorDecl: OperatorDecl? {
    willSet {
      // TODO: make sure `name` is an operator.
    }
  }

  /// The parameters of this function declaration.
  public let parameters: ParameterList

  /// The optional return type annotation of this function declaration.
  public let returnTypeAnnotation: TypeLocation?

  /// The body of this function declaration.
  public let body: BraceStmt?

  public var range: SourceRange? {
    return funcKeywordRange
  }

  public init(
    funcKeywordRange: SourceRange,
    name: String,
    parameters: ParameterList,
    returnTypeAnnotation: TypeLocation? = nil,
    body: BraceStmt
  ) {
    self.funcKeywordRange = funcKeywordRange
    self.name = name
    self.parameters = parameters
    self.returnTypeAnnotation = returnTypeAnnotation
    self.body = body
  }

}

/// A list of function parameters.
public struct ParameterList: ParenthesizedNode {

  /// The parameters in this list.
  public let parameters: [ParamDecl]

  public var leftParenthesisRange: SourceRange?

  public var rightParenthesisRange: SourceRange?

  public var contentRange: SourceRange? {
    SourceRange.union(of: parameters.compactMap({ $0.range }))
  }

  public init(
    parameters: [ParamDecl],
    leftParenthesisRange: SourceRange?,
    rightParenthesisRange: SourceRange?
  ) {
    self.parameters = parameters
    self.leftParenthesisRange = leftParenthesisRange
    self.rightParenthesisRange = rightParenthesisRange
  }

}

extension ParameterList: Collection {

  public var startIndex: Int { 0 }

  public var endIndex: Int { parameters.count }

  public func index(after i: Int) -> Int { i + 1 }

  public subscript(index: Int) -> ParamDecl {
    parameters[index]
  }

}

/// A parameter declaration.
public final class ParamDecl: SourceRepresentable {

  public let range: SourceRange?

  public init(range: SourceRange?) {
    self.range = range
  }

}

/// An operator declaration.
public class OperatorDecl {
}
