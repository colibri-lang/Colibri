/// A node with syntactic representation in a translation unit.
public protocol SourceRepresentable {

  /// The source range corresponding to this node.
  ///
  /// - Note: This property might be `nil` if the node is implicit.
  var range: SourceRange? { get }

}
