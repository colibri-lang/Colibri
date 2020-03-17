public protocol TypeLocation: SourceRepresentable {
}

/// A an identifer type location.
public final class IdentTypeLocation: TypeLocation {

  /// The name of the identifier.
  public let name: String

  public let range: SourceRange?

  public init(name: String, range: SourceRange?) {
    self.name = name
    self.range = range
  }

}
