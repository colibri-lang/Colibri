/// An object that specifies a declaration context.
///
/// A declaration context refers to a region (a.k.a. lexical scope) in which entities, such as
/// types or functions can be declared.
public protocol DeclContext: AnyObject {

  /// The declaration context that lexically encloses this context.
  var parent: DeclContext? { get }

  /// The declarations that are contained in this context.
  var decls: [Decl] { get set }

}
