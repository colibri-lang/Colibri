import AST

public struct PatternBindingDeclParser: Parser {

  public typealias Element = PatternBindingDecl

  public func parse(
    stream: inout TokenStream,
    diagnostics: inout [Diagnostic]
  ) -> PatternBindingDecl? {
    // Parses the `let` or `var` keyword at the beginning of the declaration.
    guard let letOrVarTok = stream.consume([.let, .var]) else {
      diagnostics.append(expectedError.instantiate(at: stream.peek().range, with: "let"))
      return nil
    }

    let pattern = PatternParser.get.parse(stream: &stream, diagnostics: &diagnostics)
      ?? InvalidPattern(range: stream.peek().range)

    // Create the declaration.
    return PatternBindingDecl(letVarKeywordRange: letOrVarTok.range, pattern: pattern)
  }

  public static let get = PatternBindingDeclParser()

}

///// A parser for function declarations.
//public struct FuncDeclParser: Parser {
//
//  public typealias Element = FuncDecl
//
//  public func parse(_ stream: TokenStream) -> ParseResult<FuncDecl> {
//    // All function declarations must start with `func`.
//    guard let funcKeyword = stream.first, funcKeyword.kind == .func else {
//
//    }
//
//  }
//
//  public static let get = FuncDeclParser()
//
//}
