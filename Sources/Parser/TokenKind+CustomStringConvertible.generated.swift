// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

extension TokenKind: CustomStringConvertible {

  public var description: String {
    switch self {
      case .comment: return "comment"
      case .multilineComment: return "multilineComment"
      case .identifier: return "identifier"
      case .underscore: return "underscore"
      case .associatedtype: return "associatedtype"
      case .class: return "class"
      case .`deinit`: return "deinit"
      case .enum: return "enum"
      case .extension: return "extension"
      case .fileprivate: return "fileprivate"
      case .func: return "func"
      case .import: return "import"
      case .`init`: return "init"
      case .inout: return "inout"
      case .internal: return "internal"
      case .let: return "let"
      case .open: return "open"
      case .operator: return "operator"
      case .private: return "private"
      case .protocol: return "protocol"
      case .public: return "public"
      case .rethrows: return "rethrows"
      case .static: return "static"
      case .struct: return "struct"
      case .subscript: return "subscript"
      case .typealias: return "typealias"
      case .var: return "var"
      case .break: return "break"
      case .case: return "case"
      case .continue: return "continue"
      case .default: return "default"
      case .defer: return "defer"
      case .do: return "do"
      case .else: return "else"
      case .fallthrough: return "fallthrough"
      case .for: return "for"
      case .guard: return "guard"
      case .if: return "if"
      case .in: return "in"
      case .repeat: return "repeat"
      case .return: return "return"
      case .switch: return "switch"
      case .where: return "where"
      case .while: return "while"
      case .as: return "as"
      case .Any: return "Any"
      case .catch: return "catch"
      case .false: return "false"
      case .is: return "is"
      case .nil: return "nil"
      case .super: return "super"
      case .`self`: return "self"
      case .`Self`: return "Self"
      case .throw: return "throw"
      case .throws: return "throws"
      case .true: return "true"
      case .try: return "try"
      case ._available: return "_available"
      case ._colorLiteral: return "_colorLiteral"
      case ._column: return "_column"
      case ._else: return "_else"
      case ._elseif: return "_elseif"
      case ._endif: return "_endif"
      case ._error: return "_error"
      case ._file: return "_file"
      case ._fileLiteral: return "_fileLiteral"
      case ._function: return "_function"
      case ._if: return "_if"
      case ._imageLiteral: return "_imageLiteral"
      case ._line: return "_line"
      case ._selector: return "_selector"
      case ._sourceLocation: return "_sourceLocation"
      case ._warning: return "_warning"
      case .associativity: return "associativity"
      case .convenience: return "convenience"
      case .dynamic: return "dynamic"
      case .didSet: return "didSet"
      case .final: return "final"
      case .get: return "get"
      case .infix: return "infix"
      case .indirect: return "indirect"
      case .lazy: return "lazy"
      case .left: return "left"
      case .mutating: return "mutating"
      case .none: return "none"
      case .nonmutating: return "nonmutating"
      case .optional: return "optional"
      case .override: return "override"
      case .postfix: return "postfix"
      case .precedence: return "precedence"
      case .prefix: return "prefix"
      case .Protocol: return "Protocol"
      case .required: return "required"
      case .right: return "right"
      case .set: return "set"
      case .Type: return "Type"
      case .unowned: return "unowned"
      case .weak: return "weak"
      case .willset: return "willset"
      case .leftParenthesis: return "leftParenthesis"
      case .rightParenthesis: return "rightParenthesis"
      case .leftBrace: return "leftBrace"
      case .rightBrace: return "rightBrace"
      case .leftBracket: return "leftBracket"
      case .rightBracket: return "rightBracket"
      case .dot: return "dot"
      case .comma: return "comma"
      case .colon: return "colon"
      case .assign: return "assign"
      case .at: return "at"
      case .pound: return "pound"
      case .arrow: return "arrow"
      case .backtick: return "backtick"
      case .newline: return "newline"
      case .semicolon: return "semicolon"
      case .eof: return "eof"
      case .integerLiteral: return "integerLiteral"
      case .floatLiteral: return "floatLiteral"
      case .stringLiteral: return "stringLiteral"
      case .op: return "op"
      case .unterminatedComment: return "unterminatedComment"
      case .unterminatedString: return "unterminatedString"
      case .unknown: return "unknown"
    }
  }

}
