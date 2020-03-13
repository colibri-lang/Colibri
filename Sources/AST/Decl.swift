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

  /// the function's signature.
  public let signature: FuncSign

  /// The body of this function declaration.
  public let body: BraceStmt?

  public var range: SourceRange?

  public init(
    name: String,
    signature: FuncSign,
    body: BraceStmt?,
    range: SourceRange?
  ) {
    self.name = name
    self.signature = signature
    self.body = body
    self.range = range
  }

}

/// A function signature.
public struct FuncSign: SourceRepresentable {

  /// A kind of throwing behavior.
  public enum ThrowingBehavior {

    case none
    case `throws`
    case `rethrows`

  }

  /// The function's parameters.
  public let parameters: ParamList

  /// The function's return type.
  public let returnType: TypeLocation?

  /// The function's throwing behavior.
  public let throwingBehavior: ThrowingBehavior

  /// The range of the `throws` or `rethrows` keyword, if present.
  public let throwsKeywordRange: SourceRange?

  public var range: SourceRange? {
    guard let lower = parameters.range ?? returnType?.range ?? throwsKeywordRange
      else { return nil }
    let upper = throwsKeywordRange ?? returnType?.range ?? lower
    return lower.lowerBound ..< upper.upperBound
  }

  public init(
    parameters: ParamList,
    returnType: TypeLocation?,
    throwingBehavior: ThrowingBehavior,
    throwsKeywordRange: SourceRange?
  ) {
    self.parameters = parameters
    self.returnType = returnType
    self.throwingBehavior = throwingBehavior
    self.throwsKeywordRange = throwsKeywordRange
  }

}

/// A list of function parameter declarations.
public struct ParamList: ParenthesizedNode {

  /// The declarations in this list.
  public let decls: [ParamDecl]

  public var leftParenthesisRange: SourceRange?

  public var rightParenthesisRange: SourceRange?

  public var contentRange: SourceRange? {
    SourceRange.union(of: decls.compactMap({ $0.range }))
  }

  public init(
    decls: [ParamDecl] = [],
    leftParenthesisRange: SourceRange? = nil,
    rightParenthesisRange: SourceRange? = nil
  ) {
    self.decls = decls
    self.leftParenthesisRange = leftParenthesisRange
    self.rightParenthesisRange = rightParenthesisRange
  }

}

extension ParamList: Collection {

  public var startIndex: Int { 0 }

  public var endIndex: Int { decls.count }

  public func index(after i: Int) -> Int { i + 1 }

  public subscript(index: Int) -> ParamDecl {
    decls[index]
  }

}

/// A parameter declaration.
public final class ParamDecl: SourceRepresentable {

  /// The external name of this parameter.
  public let externalName: String?

  /// The internal name of this parameter.
  public let internalName: String?

  /// The type location annotating this parameter.
  public let typeLocation: TypeLocation?

  public let range: SourceRange?

  public init(
    externalName: String?,
    internalName: String?,
    typeLocation: TypeLocation?,
    range: SourceRange?
  ) {
    self.externalName = externalName
    self.internalName = internalName
    self.typeLocation = typeLocation
    self.range = range
  }

}

/// An operator declaration.
public class OperatorDecl {

}
