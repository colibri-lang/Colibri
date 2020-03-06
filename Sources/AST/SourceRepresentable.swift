/// A node with syntactic representation in a translation unit.
public protocol SourceRepresentable {

  /// The source range corresponding to this node.
  var range: SourceRange { get }

}
