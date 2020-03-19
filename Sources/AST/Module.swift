/// A module.
///
/// A module (a.k.a. a compilation unit in Clang/LLVM's parlance) is a collection of types and
/// function declarations declared in one or several source files (a.k.a. translation units).
public final class Module: DeclContext {

  /// The top-level declarations of the module.
  public var decls: [Decl] = []

  public let parent: DeclContext? = nil

  public init() {
  }

}
