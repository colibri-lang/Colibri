import AST

public struct PatternBindingDeclParser: Parser {

  public typealias Element = PatternBindingDecl

  public func parse(
    stream: inout TokenStream,
    diagnostics: inout [Diagnostic]
  ) -> PatternBindingDecl? {
    // Parses the `let` or `var` keyword at the beginning of the declaration.
    guard let letOrVarTok = stream.consume([.let, .var]) else {
      diagnostics.append(expectedError.instantiate(
        at: stream.nextNonCommentToken?.range,
        with: "let"))
      return nil
    }

    let pattern = PatternParser.get.parse(stream: &stream, diagnostics: &diagnostics)
      ?? InvalidPattern(range: stream.peek().range)

    // Create the declaration.
    return PatternBindingDecl(letVarKeywordRange: letOrVarTok.range, pattern: pattern)
  }

  public static let get = PatternBindingDeclParser()

}

/// A parser for function declarations.
public struct FuncDeclParser: Parser {

  public typealias Element = FuncDecl

  /// The sub-parser used to parse function declaration identifiers.
  private let declIdentParser = DeclIdentNameParser(
    declarationKind: "function",
    recoverIfNextSatisfies: { token in
      return (token.kind == .leftParenthesis)
          || (token.kind == .leftBrace)
          || (token.kind == .arrow)
          || (token.value?.starts(with: "<") ?? false)
    })

  public func parse(stream: inout TokenStream, diagnostics: inout [Diagnostic]) -> FuncDecl? {
    // All function declarations must start with `func`.
    guard let funcTok = stream.consume(.func) else {
      diagnostics.append(expectedError.instantiate(
        at: stream.nextNonCommentToken?.range,
        with: "func"))
      return nil
    }

    // Parse the function's name.
    var name: String
    if let operatorTok = stream.consume(if: { tok in tok.isOperator }) {
      // If the name is an operator token that ends in '<' the following token is an identifier,
      // split the '<' off as a separate token, so that things like `func ==<T>(x: T, y: T)` can
      // be parsed as `==` and a generic parameter `<T>` as expected.
      let operatorName = operatorTok.value!
      if (operatorName.last == "<") && (stream.peek().kind == .identifier) {
        name = String(operatorName.dropLast())
      } else {
        name = operatorName
      }
    } else if let ident = declIdentParser.parse(stream: &stream, diagnostics: &diagnostics) {
      name = ident.value
    } else {
      return nil
    }

    // TODO: Parse the function's generic parameters, if present.
    // Note that we should probably set a flag if we parsed an operator that ends with '<'.

    // Parse the function's parameter list.

    // TODO:
    // If we're parsing a method, add an implement first pattern to match 'self'. This should allow
    // a method '(Int) -> Int' on 'Foo' to turn into into '(inout self: Foo) -> (Int) -> Int', and
    // a static method '(Int) -> Int' to turn into '(self: Foot.Type) -> (Int) -> Int'.

    // Parse the function's signature. Since this sub-parser is fairly resilient, so we don't try
    // to recover if it gets stuck on a hard failure.
    guard let signature = FuncSignParser.get.parse(stream: &stream, diagnostics: &diagnostics)
      else { return nil }

    // TODO: Parse the function's generic clause.

    // Parse the function's body, if present.
    var body: BraceStmt?
    if stream.peek().kind == .leftBrace {
      body = BraceStmtParser.get.parse(stream: &stream, diagnostics: &diagnostics)
    }

    let upperRange = body?.range ?? signature.range ?? funcTok.range
    return FuncDecl(
      name: name,
      signature: signature,
      body: body,
      range: funcTok.range.lowerBound ..< upperRange.upperBound)
  }

  public static let get = FuncDeclParser()

}

public struct DeclIdentNameParser: Parser {

  public typealias Element = (value: String, range: SourceRange)

  /// The name of the declaration for which this parser should parse a name.
  public let declarationKind: String

  /// A predicate that holds for the token the call site expects to see after the identifier.
  ///
  /// This function is used to determine whether the parser should try to recover when it sees an
  /// invalid identifier.
  public let nextProperty: (Token) -> Bool

  public init(
    declarationKind: String,
    recoverIfNextSatisfies nextProperty: @escaping (Token) -> Bool
  ) {
    self.declarationKind = declarationKind
    self.nextProperty = nextProperty
  }

  public func parse(
    stream: inout TokenStream,
    diagnostics: inout [Diagnostic]
  ) -> (value: String, range: SourceRange)? {
    if let identTok = stream.consume(.identifier) {
      return (value: identTok.value!, range: identTok.range)
    }

    // The following handles common invalid identifiers and provides diagnostics accordingly. In
    // most case we try to recover anyway, but make sure to return an invalid identifier so nothing
    // can resolve to it during the sema.

    if let litTok = stream.consume([.integerLiteral, .floatLiteral]) {
      diagnostics.append(numberAsDeclName.instantiate(
        at: litTok.range,
        with: [declarationKind]))

      // Numbers cannot be used as identifiers without triggering other random errors. For instance
      // `1()` won't be callable. Hence we can use the literal's value as a name.
      return (value: litTok.value!, range: litTok.range)
    }

    if let kwTok = stream.consume(if: { $0.isKeyword }) {
      diagnostics.append(keywordAsDeclIdent.instantiate(
        at: kwTok.range,
        with: [kwTok.value!]))

      if nextProperty(stream.peek()) {
        // We can recover if the next token satisfies `nextProperty` (e.g. it one of the tokens the
        // caller expects to parse after the identifier). We just append an invalid character to
        // the keyword value so that it nothing can resolve to it.
        return (value: kwTok.value! + "#", range: kwTok.range)
      }

      return nil
    }

    diagnostics.append(expectedError.instantiate(
      at: stream.nextNonCommentToken?.range,
      with: ["identifier"]))
    return nil
  }

}

public struct FuncSignParser: Parser {

  public typealias Element = FuncSign

  public func parse(stream: inout TokenStream, diagnostics: inout [Diagnostic]) -> FuncSign? {
    // Parse the parameter list.
    let parameters: ParamList
    let leftParenthesis = stream.consume(.leftParenthesis)

    if leftParenthesis != nil {
      // If we got the leading `(`, parse a list of parameter declarations.
      let decls = ParamDeclParser.get.list(terminatedBy: .rightParenthesis)
        .parse(stream: &stream, diagnostics: &diagnostics)
      let rightParenthesis = stream.consume(.rightParenthesis)
      parameters = ParamList(
        decls: decls ?? [],
        leftParenthesisRange: leftParenthesis?.range,
        rightParenthesisRange: rightParenthesis?.range)
    } else {
      // Complain if we didn't get the leading `(`, but recover with an empty parameter list.
      diagnostics.append(funcDeclWithoutParams.instantiate(at: stream.nextNonCommentToken?.range))
      parameters = ParamList()
    }

    // Parses a `throws` or `rethrows` keyword, if present.
    let throwsKeywordTok = stream.consume([.throws, .rethrows])
    let throwingBehavior: FuncSign.ThrowingBehavior
    switch throwsKeywordTok?.kind {
    case .throws  : throwingBehavior = .throws
    case .rethrows: throwingBehavior = .rethrows
    default       : throwingBehavior = .none
    }

    // Parse the return type location, if present.
    let returnType: TypeLocation?
    if stream.consume(.arrow) != nil {
      returnType = TypeLocationParser.get.parse(stream: &stream, diagnostics: &diagnostics)
    } else {
      returnType = nil
    }

    return FuncSign(
      parameters: parameters,
      returnType: returnType,
      throwingBehavior: throwingBehavior,
      throwsKeywordRange: throwsKeywordTok?.range)
  }

  public static let get = FuncSignParser()

}

public struct ParamDeclParser: Parser {

  public typealias Element = ParamDecl

  public func parse(stream: inout TokenStream, diagnostics: inout [Diagnostic]) -> ParamDecl? {
    // Complain if the declaration starts with specifiers, but keep them anyway.
    var specifierToks: [Token] = []
    while let specifierTok = stream.consume(.inout) {
      diagnostics.append(specifierBeforeParamName.instantiate(
        at: specifierTok.range,
        with: [specifierTok.value!]))
      specifierToks.append(specifierTok)
    }

    // Parse the parameter labels.
    guard let firstLabelTok = stream.consume([.underscore, .identifier]) else {
      diagnostics.append(expectedError.instantiate(
        at: stream.nextNonCommentToken?.range,
        with: ["identifier"]))
      return nil
    }
    let secondLabelTok = stream.consume(.identifier)

    let externalName = firstLabelTok.kind == .identifier
      ? firstLabelTok.value
      : nil
    let internalName = secondLabelTok?.value ?? externalName

    // Parse a colon, followed by a type location.
    let typeLocation: TypeLocation?
    var upper = secondLabelTok?.range ?? firstLabelTok.range

    if stream.consume(.colon) == nil {
      diagnostics.append(paramRequiresExplicitType.instantiate(
        at: stream.nextNonCommentToken?.range))

      typeLocation = nil
    } else {
      typeLocation = TypeLocationParser.get.parse(stream: &stream, diagnostics: &diagnostics)
      upper = typeLocation?.range ?? upper
    }

    return ParamDecl(
      externalName: externalName,
      internalName: internalName,
      typeLocation: typeLocation,
      range: firstLabelTok.range.lowerBound ..< upper.upperBound)
  }

  public static let get = ParamDeclParser()

}
