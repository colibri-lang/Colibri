public protocol NodeTransformer {

  // MARK: Declarations

  func visit(_ node: AccessModifier) -> Node
  func visit(_ node: DeclModifier) -> Node
  func visit(_ node: PatternBindingDecl) -> Node
  func visit(_ node: VarDecl) -> Node
  func visit(_ node: FuncDecl) -> Node
  func visit(_ node: FuncSign) -> Node
  func visit(_ node: ParamList) -> Node
  func visit(_ node: ParamDecl) -> Node
  func visit(_ node: OperatorDecl) -> Node

  // MARK: Expressions

  func visit(_ node: AssignExpr) -> Node
  func visit(_ node: UnresolvedDeclRefExpr) -> Node
  func visit(_ node: NilLiteralExpr) -> Node
  func visit(_ node: BooleanLiteralExpr) -> Node
  func visit(_ node: IntegerLiteralExpr) -> Node
  func visit(_ node: FloatLiteralExpr) -> Node
  func visit(_ node: StringLiteralExpr) -> Node
  func visit(_ node: MagicIdentifierLiteralExpr) -> Node
  func visit(_ node: ErrorExpr) -> Node

  // MARK: Patterns

  func visit(_ node: TypedPattern) -> Node
  func visit(_ node: NamedPattern) -> Node
  func visit(_ node: TuplePattern) -> Node
  func visit(_ node: WildcardPattern) -> Node
  func visit(_ node: ErrorPattern) -> Node

  // MARK: Statements

  func visit(_ node: BraceStmt) -> Node
  func visit(_ node: ReturnStmt) -> Node

  // MARK: Type locations

  func visit(_ node: IdentTypeLocation) -> Node

}
