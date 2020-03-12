public protocol Stmt: SourceRepresentable {
}

public final class BraceStmt: Stmt {

  public let range: SourceRange?

  public init(range: SourceRange?) {
    self.range = range
  }

}
