//
//  TokenKind.swift
//  Parser
//
//  Created by Aurélien on 03.03.20.
//

public enum TokenKind: UInt64 {
  
  // MARK: Comments
  
  case comment
  case multilineComment
  
  // MARK: Identifiers
  
  case identifier
  case escapedIdentifier
  case dollarIdentifier
  
  // MARK: Pattern keywords
  
  case underscore
  
  // MARK: Declaration keywords
  
  // sourcery:begin: keyword
  case `associatedtype`
  case `class`
  case `deinit`
  case `enum`
  case `extension`
  case `fileprivate`
  case `func`
  case `import`
  case `init`
  case `inout`
  case `internal`
  case `let`
  case `open`
  case `operator`
  case `private`
  case `protocol`
  case `public`
  case `rethrows`
  case `static`
  case `struct`
  case `subscript`
  case `typealias`
  case `var`
  
  // MARK: Statement keywords
  
  case `break`
  case `case`
  case `continue`
  case `default`
  case `defer`
  case `do`
  case `else`
  case `fallthrough`
  case `for`
  case `guard`
  case `if`
  case `in`
  case `repeat`
  case `return`
  case `switch`
  case `where`
  case `while`
  
  // MARK: Expression keywords

  case `as`
  case `Any`
  case `catch`
  case `false`
  case `is`
  case `nil`
  case `super`
  case `self`
  case `Self`
  case `throw`
  case `throws`
  case `true`
  case `try`
  
  // MARK: Other keywords

  case associativity
  case convenience
  case dynamic
  case didSet
  case final
  case get
  case infix
  case indirect
  case lazy
  case left
  case mutating
  case none
  case nonmutating
  case optional
  case override
  case postfix
  case precedence
  case prefix
  case `Protocol`
  case required
  case right
  case set
  case `Type`
  case unowned
  case weak
  case willset
  case owned
  case shared
  // sourcery:end
  
  // MARK: Pound keywords

  // sourcery:begin: poundkeyword
  case _available
  case _colorLiteral
  case _column
  case _else
  case _elseif
  case _endif
  case _error
  case _file
  case _fileLiteral
  case _function
  case _if
  case _imageLiteral
  case _line
  case _selector
  case _sourceLocation
  case _warning
  // sourcery:end

  // MARK: Punctuation
  
  case leftParenthesis
  case rightParenthesis
  case leftBrace
  case rightBrace
  case leftBracket
  case rightBracket
  case comma
  case colon
  case at
  case pound
  case arrow
  case backtick
  case backslash

  // MARK: Terminators
  
  case newline
  case semicolon
  case eof
  
  // MARK: Literals
  
  case integerLiteral
  
  case floatLiteral
  
  case stringLiteral
  case multilineStringLiteral
  case interpolatedStringLiteral
  case multilineInterpolatedStringLiteral
  
  // MARK: Operators
  
  case equal
  
  case period
  case periodPrefix
  
  case prefixOperator
  case infixOperator
  case postfixOperator
  
  case exclamationPostfix
  
  case questionPostfix
  case questionInfix
  
  case ampersandPrefix
  
  // MARK: Error tokens
  
  case unaryEqual
  
  case unterminatedEscapedIdentifier
  
  case unexpectedCommentEnd
  case unterminatedComment
  
  case invalidFloatLiteral
  
  case unterminatedStringLiteral
  
  case unknown

}
