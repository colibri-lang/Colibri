import AST

/// The lexical scoping pass of the parser.
///
/// Lexical scoping consists of binding named declarations to the proper declaration context. This
/// is a global pass that should be ran before any kind of name binding can occur.
public struct LexicalScopingPass {

  public func run(_ module: Module) {
    let binder = ScopeBinder(currentDeclContext: module)

    for decl in module.decls {
      _ = decl.accept(binder) as! Decl
    }
  }

}

fileprivate final class ScopeBinder: NodeTransformer {

  /// A reference to the closest declaration context being visited.
  private var currentDeclContext: DeclContext

  fileprivate init(currentDeclContext: DeclContext) {
    self.currentDeclContext = currentDeclContext
  }

  fileprivate func visit(_ node: VarDecl) -> Node {
    currentDeclContext.decls.append(node)
    return node
  }

  fileprivate func visit(_ node: FuncDecl) -> Node {
    currentDeclContext.decls.append(node)
    node.parent = currentDeclContext

    // Visit the function's signature and body, scoping parameter and generic type declarations
    // directly within the function's context. Declarations in the function's body however will be
    // scoped within the brace statement context.
    currentDeclContext = node
    defer { currentDeclContext = node.parent! }
    return traverse(node)
  }

  fileprivate func visit(_ node: ParamDecl) -> Node {
    currentDeclContext.decls.append(node)
    return traverse(node)
  }

  fileprivate func visit(_ node: BraceStmt) -> Node {
    node.parent = currentDeclContext

    // Scope the declarations contained within the brace statement.
    currentDeclContext = node
    defer { currentDeclContext = node.parent! }
    return traverse(node)
  }

}
