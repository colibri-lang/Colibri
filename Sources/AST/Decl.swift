/// A declaration.
public protocol Decl: Node {

}

/// An access control modifier.
public final class AccessModifier: Node, SourceRepresentable {

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

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// A declaration modifier.
public final class DeclModifier: Decl, SourceRepresentable {

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

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
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
public final class PatternBindingDecl: Decl, SourceRepresentable {

  /// The source range of the `let` or `var` keyword.
  public let letVarKeywordRange: SourceRange

  /// The pattern being bound.
  public var pattern: Pattern

  /// The initializer for the variables declared by the pattern.
  public var initializer: Expr?

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

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// A variable declaration.
public final class VarDecl: Decl, SourceRepresentable {

  /// The variable's name.
  public let name: String

  /// The pattern from which this variable declaration is implied.
  public var pattern: Pattern?

  public let range: SourceRange?

  public init(name: String, range: SourceRange?) {
    self.name = name
    self.range = range
  }

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// A function declaration.
public final class FuncDecl: Decl, DeclContext, SourceRepresentable {

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
  public var signature: FuncSign

  /// The body of this function declaration.
  public var body: BraceStmt?

  public var range: SourceRange?

  public weak var parent: DeclContext?

  public var decls: [Decl] = []

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

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// A function signature.
public final class FuncSign: Node, SourceRepresentable {

  /// A kind of throwing behavior.
  public enum ThrowingBehavior {

    case none
    case `throws`
    case `rethrows`

  }

  /// The function's parameters.
  public var parameters: ParamList

  /// The function's return type.
  public var returnType: TypeLocation?

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

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// A list of function parameter declarations.
public final class ParamList: Node, ParenthesizedNode {

  /// The declarations in this list.
  public var decls: [ParamDecl]

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

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
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
public final class ParamDecl: Decl, SourceRepresentable {

  /// The external name of this parameter.
  public let externalName: String?

  /// The internal name of this parameter.
  public let internalName: String?

  /// The type location annotating this parameter.
  public var typeLocation: TypeLocation?

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

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}

/// An operator declaration.
public class OperatorDecl: Decl {

  public func accept<T>(_ transformer: T) -> Node where T: NodeTransformer {
    transformer.visit(self)
  }

}
