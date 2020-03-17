import AST

public struct TypeLocationParser: Parser {

  public typealias Element = TypeLocation

  public func parse(stream: inout TokenStream, diagnostics: inout [Diagnostic]) -> TypeLocation? {
    switch stream.peek().kind {
    case .Self, .Any, .identifier:
      let identTok = stream.consume()
      let location = IdentTypeLocation(name: identTok.value!, range: identTok.range)
      return location

    default:
      diagnostics.append(expectedError.instantiate(
        at: stream.nextNonCommentToken?.range,
        with: "type"))
      return nil
    }
  }

  public static let get = TypeLocationParser()

}
