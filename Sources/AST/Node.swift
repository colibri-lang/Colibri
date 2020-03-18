/// An AST node.
public protocol Node {

  /// Accepts the given node transformer.
  ///
  /// - Parameter transformer: A node transformer.
  /// - Returns: The node produced by the transformer.
  func accept<T>(_ transformer: T) -> Node where T: NodeTransformer

}
