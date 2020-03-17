/// A node with syntactic representation in a translation unit.
public protocol SourceRepresentable {

  /// The source range corresponding to this node.
  ///
  /// - Note: This property might be `nil` if the node is implicit.
  var range: SourceRange? { get }

}

/// A node delimited by parentheses.
public protocol ParenthesizedNode: SourceRepresentable {

  /// The source range of the left parenthesis token.
  var leftParenthesisRange: SourceRange? { get }

  /// The source range of the right parenthesis token.
  var rightParenthesisRange: SourceRange? { get }

  /// The range of the content the node's content.
  var contentRange: SourceRange? { get }

  var range: SourceRange? { get }

}

extension ParenthesizedNode {

  public var range: SourceRange? {
     if let lower = leftParenthesisRange, let upper = rightParenthesisRange {
       return lower.lowerBound ..< upper.upperBound
     }

     let lower = leftParenthesisRange ?? contentRange ?? rightParenthesisRange
     let upper = rightParenthesisRange ?? contentRange ?? leftParenthesisRange

     return lower != nil
       ? lower!.lowerBound ..< upper!.upperBound
       : nil
   }

}
