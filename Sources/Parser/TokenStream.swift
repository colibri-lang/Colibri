public typealias TokenStream = ArraySlice<Token>

extension TokenStream {

  /// Returns this token stream without its leading newlines.
  var trimmed: TokenStream {
    drop(while: { $0.kind == .newline })
  }

}
