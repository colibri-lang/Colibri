// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import XCTest

import AST

@testable import Parser

class LexerTests: XCTestCase {
  // MARK: Helper functions.
  /// Tokenize a String.
  private func tokenize(_ source: String) -> [Token] {
    let translationUnit = TranslationUnit(name: "test", source: source)
    let lexer = Lexer(translationUnit: translationUnit)
    return Array(lexer)
  }

  /// Compare the result of the lexer on a String with expected tokens.
  private func checkLex(
    _ source: String,
    _ expectedTokenKinds: [TokenKind],
    _ expectedTokenLengths: [Int]
  ) {
    let tokens = tokenize(source)
    XCTAssertEqual(tokens.map({ $0.kind }), expectedTokenKinds)
    let tokenLengths = tokens.map({ $0.range.upperBound.offset - $0.range.lowerBound.offset })
    XCTAssertEqual(tokenLengths, expectedTokenLengths)
  }

  /// Compare the result of the lexer on a String with an expected keyword kind.
  private func checkLexKeyword(_ source: String, _ expectedTokenKind: TokenKind) {
    let tokens = tokenize(source)
    XCTAssertEqual(tokens.map({ $0.kind })[0], expectedTokenKind)
  }

  // MARK: Test lexing on comments.

  func testLexComments() {
    let source = "//Blah\n(/*yo*/)"
    let expectedTokenKinds: [TokenKind] = [
      .comment, .newline, .leftParenthesis, .multilineComment, .rightParenthesis, .eof
    ]
    let expectedTokenLengths = [6, 1, 1, 6, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testUnterminatedComment() {
    let source = "/* Blah"
    let expectedTokenKinds: [TokenKind] = [.unterminatedComment, .eof]
    let expectedTokenLengths = [7, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexTrailingComments() {
    let source = "//  comment\naaa //xx \n/* x */"
    let expectedTokenKinds: [TokenKind] = [
      .comment, .newline, .identifier, .comment, .newline, .multilineComment, .eof
    ]
    let expectedTokenLengths = [11, 1, 3, 5, 1, 7, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  // MARK: Test lexing on operators.

  func testLexOperatorThenComment() {
    let source = "a%&/*A comment*/"
    let expectedTokenKinds: [TokenKind] = [.identifier, .postfixOperator, .multilineComment, .eof]
    let expectedTokenLengths = [1, 2, 13, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexEqual() {
    let source = "a = 0"
    let expectedTokenKinds: [TokenKind] = [.identifier, .equal, .integerLiteral, .eof]
    let expectedTokenLengths = [1, 1, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexUnaryEqual() {
    let source = "a =0"
    let expectedTokenKinds: [TokenKind] = [.identifier, .unaryEqual, .integerLiteral, .eof]
    let expectedTokenLengths = [1, 1, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexAmpersandPrefix() {
    let source = "&someVar"
    let expectedTokenKinds: [TokenKind] = [.ampersandPrefix, .identifier, .eof]
    let expectedTokenLengths = [1, 7, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexPeriodPrefix() {
    let source = ".someEnumCase"
    let expectedTokenKinds: [TokenKind] = [.periodPrefix, .identifier, .eof]
    let expectedTokenLengths = [1, 12, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexPeriod() {
    let source = "a.b"
    let expectedTokenKinds: [TokenKind] = [.identifier, .period, .identifier, .eof]
    let expectedTokenLengths = [1, 1, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexPeriodStartingOperator() {
    let source = "a .<. b"
    let expectedTokenKinds: [TokenKind] = [.identifier, .infixOperator, .identifier, .eof]
    let exptectedTokenLengths = [1, 3, 1, 0]
    checkLex(source, expectedTokenKinds, exptectedTokenLengths)
  }

  func testLexOperatorThenPeriod() {
    let source = "a<%.b"
    let expectedTokenKinds: [TokenKind] = [
      .identifier, .postfixOperator, .period, .identifier, .eof
    ]
    let expectedTokenLengths = [1, 2, 1, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexQuestionPostfix() {
    let source = "a? b"
    let expectedTokenKinds: [TokenKind] = [.identifier, .questionPostfix, .identifier, .eof]
    let expectedTokenLengths = [1, 1, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexQuestionInfix() {
    let source = "a ? b"
    let expectedTokenKinds: [TokenKind] = [.identifier, .questionInfix, .identifier, .eof]
    let expectedTokenLengths = [1, 1, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexArrow() {
    let source = "(Int, Int) -> Bool"
    let expectedTokenKinds: [TokenKind] = [
      .leftParenthesis, .identifier, .comma, .identifier, .rightParenthesis, .arrow, .identifier,
      .eof
    ]
    let expectedTokenLengths = [1, 3, 1, 3, 1, 2, 4, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexUnexpectedCommentEnd() {
    let source = "a */ b"
    let expectedTokenKinds: [TokenKind] = [.identifier, .unexpectedCommentEnd, .identifier, .eof]
    let expectedTokenLengths = [1, 2, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testPrefixOperator() {
    let source = "a <<=b"
    let expectedTokenKinds: [TokenKind] = [.identifier, .prefixOperator, .identifier, .eof]
    let expectedTokenLengths = [1, 3, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testPostfixOperator() {
    let source = "a*-=> b"
    let expectedTokenKinds: [TokenKind] = [.identifier, .postfixOperator, .identifier, .eof]
    let expectedTokenLengths = [1, 4, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testInfixOperator() {
    let source = "a <=> b"
    let expectedTokenKinds: [TokenKind] = [.identifier, .infixOperator, .identifier, .eof]
    let expectedTokenLengths = [1, 3, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  // MARK: Test lexing on identifiers.

  func testLexUnderscore() {
    let source = "_ = 0"
    let expectedTokenKinds: [TokenKind] = [.underscore, .equal, .integerLiteral, .eof]
    let expectedTokenLengths = [1, 1, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexEscapedIdentifier() {
    let source = "`class`"
    let expectedTokenKinds: [TokenKind] = [.escapedIdentifier, .eof]
    let expectedTokenLengths = [7, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexUnterminatedEscapedIdentifier() {
    let source = "`class "
    let expectedTokenKinds: [TokenKind] = [.unterminatedEscapedIdentifier, .eof]
    let expectedTokenLengths = [6, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexDollarIdentifier() {
    let source = "$0 == 1"
    let expectedTokenKinds: [TokenKind] = [.dollarIdentifier, .infixOperator, .integerLiteral, .eof]
    let expectedTokenLengths = [2, 2, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexDollarIdentifier2() {
    let source = "$id"
    let expectedTokenKinds: [TokenKind] = [.identifier, .eof]
    let expectedTokenLengths = [3, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexDollar() {
    let source = "$ id"
    let expectedTokenKinds: [TokenKind] = [.unknown, .identifier, .eof]
    let expectedTokenLengths = [1, 2, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexIdentifier() {
    let source = "let myConst = 0"
    let expectedTokenKinds: [TokenKind] = [
      .let, .identifier, .equal, .integerLiteral, .eof
    ]
    let expectedTokenLengths = [3, 7, 1, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexUnderscoreIdentifier() {
    let source = "_identifier"
    let expectedTokenKinds: [TokenKind] = [.identifier, .eof]
    let expectedTokenLengths = [11, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexNumberThenIdentifier() {
    let source = "3id"
    let expectedTokenKinds: [TokenKind] = [.integerLiteral, .identifier, .eof]
    let expectedTokenLengths = [1, 2, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  // MARK: Test lexing on keywords.

  func testLexassociatedtype() {
      let source = "associatedtype"
      let expectedTokenKinds: TokenKind = .associatedtype
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexclass() {
      let source = "class"
      let expectedTokenKinds: TokenKind = .class
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexdeinit() {
    let source = "deinit"
    let expectedTokenKind: TokenKind = .`deinit`
    checkLexKeyword(source, expectedTokenKind)
  }

  func testLexenum() {
      let source = "enum"
      let expectedTokenKinds: TokenKind = .enum
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexextension() {
      let source = "extension"
      let expectedTokenKinds: TokenKind = .extension
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexfileprivate() {
      let source = "fileprivate"
      let expectedTokenKinds: TokenKind = .fileprivate
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexfunc() {
      let source = "func"
      let expectedTokenKinds: TokenKind = .func
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLeximport() {
      let source = "import"
      let expectedTokenKinds: TokenKind = .import
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexinit() {
    let source = "init"
    let expectedTokenKind: TokenKind = .`init`
    checkLexKeyword(source, expectedTokenKind)
  }

  func testLexinout() {
      let source = "inout"
      let expectedTokenKinds: TokenKind = .inout
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexinternal() {
      let source = "internal"
      let expectedTokenKinds: TokenKind = .internal
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexlet() {
      let source = "let"
      let expectedTokenKinds: TokenKind = .let
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexopen() {
      let source = "open"
      let expectedTokenKinds: TokenKind = .open
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexoperator() {
      let source = "operator"
      let expectedTokenKinds: TokenKind = .operator
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexprivate() {
      let source = "private"
      let expectedTokenKinds: TokenKind = .private
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexprotocol() {
      let source = "protocol"
      let expectedTokenKinds: TokenKind = .protocol
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexpublic() {
      let source = "public"
      let expectedTokenKinds: TokenKind = .public
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexrethrows() {
      let source = "rethrows"
      let expectedTokenKinds: TokenKind = .rethrows
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexstatic() {
      let source = "static"
      let expectedTokenKinds: TokenKind = .static
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexstruct() {
      let source = "struct"
      let expectedTokenKinds: TokenKind = .struct
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexsubscript() {
      let source = "subscript"
      let expectedTokenKinds: TokenKind = .subscript
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLextypealias() {
      let source = "typealias"
      let expectedTokenKinds: TokenKind = .typealias
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexvar() {
      let source = "var"
      let expectedTokenKinds: TokenKind = .var
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexbreak() {
      let source = "break"
      let expectedTokenKinds: TokenKind = .break
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexcase() {
      let source = "case"
      let expectedTokenKinds: TokenKind = .case
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexcontinue() {
      let source = "continue"
      let expectedTokenKinds: TokenKind = .continue
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexdefault() {
      let source = "default"
      let expectedTokenKinds: TokenKind = .default
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexdefer() {
      let source = "defer"
      let expectedTokenKinds: TokenKind = .defer
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexdo() {
      let source = "do"
      let expectedTokenKinds: TokenKind = .do
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexelse() {
      let source = "else"
      let expectedTokenKinds: TokenKind = .else
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexfallthrough() {
      let source = "fallthrough"
      let expectedTokenKinds: TokenKind = .fallthrough
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexfor() {
      let source = "for"
      let expectedTokenKinds: TokenKind = .for
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexguard() {
      let source = "guard"
      let expectedTokenKinds: TokenKind = .guard
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexif() {
      let source = "if"
      let expectedTokenKinds: TokenKind = .if
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexin() {
      let source = "in"
      let expectedTokenKinds: TokenKind = .in
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexrepeat() {
      let source = "repeat"
      let expectedTokenKinds: TokenKind = .repeat
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexreturn() {
      let source = "return"
      let expectedTokenKinds: TokenKind = .return
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexswitch() {
      let source = "switch"
      let expectedTokenKinds: TokenKind = .switch
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexwhere() {
      let source = "where"
      let expectedTokenKinds: TokenKind = .where
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexwhile() {
      let source = "while"
      let expectedTokenKinds: TokenKind = .while
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexas() {
      let source = "as"
      let expectedTokenKinds: TokenKind = .as
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexAny() {
      let source = "Any"
      let expectedTokenKinds: TokenKind = .Any
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexcatch() {
      let source = "catch"
      let expectedTokenKinds: TokenKind = .catch
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexfalse() {
      let source = "false"
      let expectedTokenKinds: TokenKind = .false
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexis() {
      let source = "is"
      let expectedTokenKinds: TokenKind = .is
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexnil() {
      let source = "nil"
      let expectedTokenKinds: TokenKind = .nil
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexsuper() {
      let source = "super"
      let expectedTokenKinds: TokenKind = .super
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexself() {
    let source = "self"
    let expectedTokenKind: TokenKind = .`self`
    checkLexKeyword(source, expectedTokenKind)
  }

  func testLexSelf() {
    let source = "Self"
    let expectedTokenKind: TokenKind = .`Self`
    checkLexKeyword(source, expectedTokenKind)
  }

  func testLexthrow() {
      let source = "throw"
      let expectedTokenKinds: TokenKind = .throw
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexthrows() {
      let source = "throws"
      let expectedTokenKinds: TokenKind = .throws
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLextrue() {
      let source = "true"
      let expectedTokenKinds: TokenKind = .true
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLextry() {
      let source = "try"
      let expectedTokenKinds: TokenKind = .try
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexassociativity() {
      let source = "associativity"
      let expectedTokenKinds: TokenKind = .associativity
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexconvenience() {
      let source = "convenience"
      let expectedTokenKinds: TokenKind = .convenience
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexdynamic() {
      let source = "dynamic"
      let expectedTokenKinds: TokenKind = .dynamic
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexdidSet() {
      let source = "didSet"
      let expectedTokenKinds: TokenKind = .didSet
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexfinal() {
      let source = "final"
      let expectedTokenKinds: TokenKind = .final
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexget() {
      let source = "get"
      let expectedTokenKinds: TokenKind = .get
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexinfix() {
      let source = "infix"
      let expectedTokenKinds: TokenKind = .infix
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexindirect() {
      let source = "indirect"
      let expectedTokenKinds: TokenKind = .indirect
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexlazy() {
      let source = "lazy"
      let expectedTokenKinds: TokenKind = .lazy
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexleft() {
      let source = "left"
      let expectedTokenKinds: TokenKind = .left
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexmutating() {
      let source = "mutating"
      let expectedTokenKinds: TokenKind = .mutating
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexnone() {
      let source = "none"
      let expectedTokenKinds: TokenKind = .none
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexnonmutating() {
      let source = "nonmutating"
      let expectedTokenKinds: TokenKind = .nonmutating
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexoptional() {
      let source = "optional"
      let expectedTokenKinds: TokenKind = .optional
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexoverride() {
      let source = "override"
      let expectedTokenKinds: TokenKind = .override
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexpostfix() {
      let source = "postfix"
      let expectedTokenKinds: TokenKind = .postfix
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexprecedence() {
      let source = "precedence"
      let expectedTokenKinds: TokenKind = .precedence
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexprefix() {
      let source = "prefix"
      let expectedTokenKinds: TokenKind = .prefix
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexProtocol() {
      let source = "Protocol"
      let expectedTokenKinds: TokenKind = .Protocol
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexrequired() {
      let source = "required"
      let expectedTokenKinds: TokenKind = .required
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexright() {
      let source = "right"
      let expectedTokenKinds: TokenKind = .right
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexset() {
      let source = "set"
      let expectedTokenKinds: TokenKind = .set
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexType() {
      let source = "Type"
      let expectedTokenKinds: TokenKind = .Type
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexunowned() {
      let source = "unowned"
      let expectedTokenKinds: TokenKind = .unowned
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexweak() {
      let source = "weak"
      let expectedTokenKinds: TokenKind = .weak
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexwillset() {
      let source = "willset"
      let expectedTokenKinds: TokenKind = .willset
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexowned() {
      let source = "owned"
      let expectedTokenKinds: TokenKind = .owned
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLexshared() {
      let source = "shared"
      let expectedTokenKinds: TokenKind = .shared
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_available() {
      let source = "#available"
      let expectedTokenKinds: TokenKind = ._available
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_colorLiteral() {
      let source = "#colorLiteral"
      let expectedTokenKinds: TokenKind = ._colorLiteral
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_column() {
      let source = "#column"
      let expectedTokenKinds: TokenKind = ._column
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_else() {
      let source = "#else"
      let expectedTokenKinds: TokenKind = ._else
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_elseif() {
      let source = "#elseif"
      let expectedTokenKinds: TokenKind = ._elseif
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_endif() {
      let source = "#endif"
      let expectedTokenKinds: TokenKind = ._endif
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_error() {
      let source = "#error"
      let expectedTokenKinds: TokenKind = ._error
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_file() {
      let source = "#file"
      let expectedTokenKinds: TokenKind = ._file
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_fileLiteral() {
      let source = "#fileLiteral"
      let expectedTokenKinds: TokenKind = ._fileLiteral
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_function() {
      let source = "#function"
      let expectedTokenKinds: TokenKind = ._function
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_if() {
      let source = "#if"
      let expectedTokenKinds: TokenKind = ._if
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_imageLiteral() {
      let source = "#imageLiteral"
      let expectedTokenKinds: TokenKind = ._imageLiteral
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_line() {
      let source = "#line"
      let expectedTokenKinds: TokenKind = ._line
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_selector() {
      let source = "#selector"
      let expectedTokenKinds: TokenKind = ._selector
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_sourceLocation() {
      let source = "#sourceLocation"
      let expectedTokenKinds: TokenKind = ._sourceLocation
      checkLexKeyword(source, expectedTokenKinds)
    }

  func testLex_warning() {
      let source = "#warning"
      let expectedTokenKinds: TokenKind = ._warning
      checkLexKeyword(source, expectedTokenKinds)
    }


  // MARK: Test lexing on number literals.

  func testLexIntegerLiteral() {
    let source = "42"
    let expectedTokenKinds: [TokenKind] = [.integerLiteral, .eof]
    let expectedTokenLengths = [2, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexFloatLiteral() {
    let source = "1.2"
    let expectedTokenKinds: [TokenKind] = [.floatLiteral, .eof]
    let expectedTokenLengths = [3, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexFloatWithExponent() {
    let source = "1.25e-23"
    let expectedTokenKinds: [TokenKind] = [.floatLiteral, .eof]
    let expectedTokenLengths = [8, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexInvalidFloat() {
    let source = "1.25efail"
    let expectedTokenKinds: [TokenKind] = [.invalidFloatLiteral, .identifier, .eof]
    let expectedTokenLengths = [5, 4, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  // MARK: Test lexing on string literals.

  func testStringLiteral() {
    let source = "\"meow\""
    let expectedTokenKinds: [TokenKind] = [.stringLiteral, .eof]
    let expectedTokenLengths = [6, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexStringLiteralWithAlternativeQuotes() {
    let source = "'woof'"
    let expectedTokenKinds: [TokenKind] = [.stringLiteral, .eof]
    let expectedTokenLengths = [6, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexMultilineStringLiteral() {
    let source = "\"\"\"She said\n'Haha!'\"\"\""
    let expectedTokenKinds: [TokenKind] = [.multilineStringLiteral, .eof]
    let expectedTokenLengths = [22, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexMultilineStringLiteral2() {
    let source = "\"\"\"She said\n\"Haha!\" \"\"\""
    let expectedTokenKinds: [TokenKind] = [.multilineStringLiteral, .eof]
    let expectedTokenLengths = [23, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexInterpolatedString() {
    let source = "\"An \\(interpolated) value\""
    let expectedTokenKinds: [TokenKind] = [.interpolatedStringLiteral, .eof]
    let expectedTokenLengths = [26, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexMultilineInterpolatedString() {
    let source = "\"\"\"Another \\(interpolated)\n value\"\"\""
    let expectedTokenKinds: [TokenKind] = [.multilineInterpolatedStringLiteral, .eof]
    let expectedTokenLengths = [36, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexBrokenStringLiteral1() {
    let source = "\"meow\0"
    let expectedTokenKinds: [TokenKind] = [.unterminatedStringLiteral, .eof]
    let expectedTokenLengths = [6, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexBrokenStringLiteral2() {
    let source = "\"\\meow\0"
    let expectedTokenKinds: [TokenKind] = [.unterminatedStringLiteral, .eof]
    let expectedTokenLengths = [7, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexBrokenStringLiteral3() {
    let source = "\"\"\"Some unterminated\n multiline string\"\""
    let expectedTokenKinds: [TokenKind] = [.unterminatedStringLiteral, .eof]
    let expectedTokenLengths = [40, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexStringLiteralWithNull() {
    let source = "\"\0\""
    let expectedTokenKinds: [TokenKind] = [.stringLiteral, .eof]
    let expectedTokenLengths = [3, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  // MARK: Test lexing on punctuation.

  func testLexNewline() {
    let source = "a\nb"
    let expectedTokenKinds: [TokenKind] = [.identifier, .newline, .identifier, .eof]
    let exptectedTokenLengths = [1, 1, 1, 0]
    checkLex(source, expectedTokenKinds, exptectedTokenLengths)
  }

  func testLexSemicolon() {
    let source = "let a = 0; b = 1"
    let expectedTokenKinds: [TokenKind] = [
      .let, .identifier, .equal, .integerLiteral, .semicolon, .identifier, .equal, .integerLiteral,
      .eof
    ]
    let exptectedTokenLengths = [3, 1, 1, 1, 1, 1, 1, 1, 0]
    checkLex(source, expectedTokenKinds, exptectedTokenLengths)
  }

  func testLexAt() {
    let source = "@id"
    let expectedTokenKinds: [TokenKind] = [.at, .identifier, .eof]
    let exptectedTokenLengths = [1, 2, 0]
    checkLex(source, expectedTokenKinds, exptectedTokenLengths)
  }

  func testLexParentheses() {
    let source = "(a + b)"
    let expectedTokenKinds: [TokenKind] = [
      .leftParenthesis, .identifier, .infixOperator, .identifier, .rightParenthesis, .eof
    ]
    let expectedTokenLengths = [1, 1, 1, 1, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexBraces() {
    let source = "{\na\n}"
    let expectedTokenKinds: [TokenKind] = [
      .leftBrace, .newline, .identifier, .newline, .rightBrace, .eof
    ]
    let expectedTokenLengths = [1, 1, 1, 1, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexBrackets() {
    let source = "[1, 2, 3]"
    let expectedTokenKinds: [TokenKind] = [
      .leftBracket, .integerLiteral, .comma, .integerLiteral, .comma, .integerLiteral,
      .rightBracket, .eof
    ]
    let expectedTokenLengths = [1, 1, 1, 1, 1, 1, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexComma() {
    let source = "(a, b)"
    let expectedTokenKinds: [TokenKind] = [
      .leftParenthesis, .identifier, .comma, .identifier, .rightParenthesis, .eof
    ]
    let expectedTokenLengths = [1, 1, 1, 1, 1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexColon() {
    let source = "let a: Int"
    let expectedTokenKinds: [TokenKind] = [
      .let, .identifier, .colon, .identifier, .eof
    ]
    let expectedTokenLengths = [3, 1, 1, 3, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

  func testLexBackslash() {
    let source = "\\"
    let expectedTokenKinds: [TokenKind] = [.backslash, .eof]
    let expectedTokenLengths = [1, 0]
    checkLex(source, expectedTokenKinds, expectedTokenLengths)
  }

}
