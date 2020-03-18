extension NodeTransformer {

  // MARK: Declarations

  public func visit(_ node: AccessModifier) -> Node {
    return node
  }

  public func visit(_ node: DeclModifier) -> Node {
    return node
  }

  public func visit(_ node: PatternBindingDecl) -> Node {
    node.pattern = node.pattern.accept(self) as! Pattern
    node.initializer = node.initializer.map({ child in child.accept(self) as! Expr })
    return node
  }

  public func visit(_ node: VarDecl) -> Node {
    return node
  }

  public func visit(_ node: FuncDecl) -> Node {
    node.signature = node.signature.accept(self) as! FuncSign
    node.body = node.body.map({ child in child.accept(self) as! BraceStmt })
    return node
  }

  public func visit(_ node: FuncSign) -> Node {
    node.parameters = node.parameters.accept(self) as! ParamList
    node.returnType = node.returnType.map({ child in child.accept(self) as! TypeLocation })
    return node
  }

  public func visit(_ node: ParamList) -> Node {
    node.decls = node.decls.map({ child in child.accept(self) as! ParamDecl })
    return node
  }

  public func visit(_ node: ParamDecl) -> Node {
    node.typeLocation = node.typeLocation.map({ child in child.accept(self) as! TypeLocation })
    return node
  }

  public func visit(_ node: OperatorDecl) -> Node {
    return node
  }

  // MARK: Expressions

  public func visit(_ node: AssignExpr) -> Node {
    node.source = node.source.accept(self) as! Expr
    node.target = node.target.accept(self) as! Expr
    return node
  }

  public func visit(_ node: UnresolvedDeclRefExpr) -> Node {
    return node
  }

  public func visit(_ node: NilLiteralExpr) -> Node {
    return node
  }

  public func visit(_ node: BooleanLiteralExpr) -> Node {
    return node
  }

  public func visit(_ node: IntegerLiteralExpr) -> Node {
    return node
  }

  public func visit(_ node: FloatLiteralExpr) -> Node {
    return node
  }

  public func visit(_ node: StringLiteralExpr) -> Node {
    return node
  }

  public func visit(_ node: MagicIdentifierLiteralExpr) -> Node {
    return node
  }

  public func visit(_ node: ErrorExpr) -> Node {
    return node
  }

  // MARK: Patterns

  public func visit(_ node: TypedPattern) -> Node {
    node.subpattern = node.subpattern.accept(self) as! Pattern
    node.annotation = node.annotation.accept(self) as! TypeLocation
    return node
  }

  public func visit(_ node: NamedPattern) -> Node {
    return node
  }

  public func visit(_ node: TuplePattern) -> Node {
    node.elements = node.elements.map({ child in child.accept(self) as! Pattern })
    return node
  }

  public func visit(_ node: WildcardPattern) -> Node {
    return node
  }

  public func visit(_ node: ErrorPattern) -> Node {
    return node
  }

  // MARK: Statements

  public func visit(_ node: BraceStmt) -> Node {
    node.statements = node.statements.map({ child in child.accept(self) })
    return node
  }

  public func visit(_ node: ReturnStmt) -> Node {
    node.expr = node.expr.map({ child in child.accept(self) as! Expr })
    return node
  }

  // MARK: Type locations

  public func visit(_ node: IdentTypeLocation) -> Node {
    return node
  }

}
