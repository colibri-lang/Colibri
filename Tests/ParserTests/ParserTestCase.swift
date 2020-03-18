import AST
import Parser

protocol ParserTestCase {

}

extension ParserTestCase {

  func tokenize(_ buffer: String) -> TokenStream {
    let unit = TranslationUnit(name: "<test>", source: buffer)
    return TokenStream(lexer: Lexer(translationUnit: unit))
  }

}
