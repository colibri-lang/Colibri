/// A stream of token.
///
/// This type wraps a lexer to produce a buffered token stream that can be used for look-ahead and
/// backtracking through a collection of helper methods.
public struct TokenStream {

  /// The wrapped lexer.
  private var lexer: Lexer

  /// A buffer containing the tokens that are left in memory (for backtracking) and those that have
  /// already been pulled from the lexer for the look-ahead.
  private var buffer: [Token]

  /// The current offset in the buffer.
  ///
  /// This is relative to the start index of the buffer and not to the beginning of the stream.
  public private(set) var offset: Int = 0

  public init(lexer: Lexer) {
    self.lexer = lexer
    self.buffer = [self.lexer.next()!]
  }

  // MARK: Non-consuming helpers

  /// Returns the first token that satisfies the given predicate, without consuming the stream.
  public mutating func first(
    ignoringSkippable: Bool = true,
    where predicate: (Token) -> Bool
  ) -> Token? {
    let p = ignoringSkippable
      ? { token in !token.isSkippable && predicate(token) }
      : predicate

    if offset < buffer.count {
      if let token = buffer.suffix(from: offset).first(where: p) {
        return token
      }
    }

    while let next = lexer.next() {
      buffer.append(next)
      if p(next) {
        return next
      }
    }
    return nil
  }

  /// The token that will be returned by `consume()`.
  public mutating func peek(ignoringSkippable: Bool = true) -> Token {
    // The forced unwrap is based on the assumption that the lexer always produces `EOF`.
    return first(ignoringSkippable: ignoringSkippable, where: { _ in true })!
  }

  /// The token that will be returned by the `n`-th application of `consume()`.
  public mutating func lookahead(ignoringSkippable: Bool = true, n: Int) -> Token {
    assert(n > 0)
    var m = 1
    return first(ignoringSkippable: ignoringSkippable, where: { _ in
      defer { m = m + 1 }
      return m == n
    })!
  }

  /// The next non-comment token.
  public var nextNonCommentToken: Token? {
    mutating get {
      first(ignoringSkippable: false, where: { token in !token.isComment })
    }
  }

  /// Indicates whether the next token returned by `consume()` starts a statement.
  public var isAtStartOfStmt: Bool {
    mutating get {
      switch peek().kind {
      case .return, .throw, .defer, .if, .guard, .while, .do, .repeat, .for, .break, .continue,
           .fallthrough, .switch, .case, .default, ._if, ._warning, ._error, ._sourceLocation:
        return true

      case ._line:
        // `#line` at the start of a line is a directive, when within, it is an expr.
        return peek().isAtStartOfLine

      case .identifier:
        // <identifier> ":" ("for" | "while" | ...) is a label on a loop.
        guard lookahead(n: 2).kind == .colon
          else { return false }

        switch lookahead(n: 3).kind {
        case .while, .do, .repeat, .for, .switch:
          return true
        default:
          return false
        }

      default:
        return false
      }
    }
  }

  // MARK: Consuming helpers

  /// Consumes the next token from the stream.
  @discardableResult
  public mutating func consume(ignoringSkippable: Bool = true) -> Token {
    for i in offset ..< buffer.count {
      let token = buffer[i]
      if token.kind != .eof {
        offset = offset + 1
      }

      if !token.isSkippable || !ignoringSkippable {
        return token
      }
    }

    while let next = lexer.next() {
      buffer.append(next)
      offset = offset + 1
      if !next.isSkippable || !ignoringSkippable {
        return next
      }
    }

    fatalError("unreachable")
  }

  /// Consumes the next token from the stream if it is of the given kind.
  @discardableResult
  public mutating func consume(ignoringSkippable: Bool = true, _ kind: TokenKind) -> Token? {
    return peek(ignoringSkippable: ignoringSkippable).kind == kind
      ? consume(ignoringSkippable: ignoringSkippable)
      : nil
  }

  /// Consumes the next token from the stream if it is of one of the given kinds.
  @discardableResult
  public mutating func consume(ignoringSkippable: Bool = true, _ kinds: Set<TokenKind>) -> Token? {
    return kinds.contains(peek(ignoringSkippable: ignoringSkippable).kind)
      ? consume(ignoringSkippable: ignoringSkippable)
      : nil
  }

  /// Consumes the next token from the stream if it satisfies the given predicate.
  @discardableResult
  public mutating func consume(
    ignoringSkippable: Bool = true,
    if predicate: (Token) -> Bool
  ) -> Token? {
    return predicate(peek(ignoringSkippable: ignoringSkippable))
      ? consume(ignoringSkippable: ignoringSkippable)
      : nil
  }

  /// Consumes the next tokens from the stream as long as they satisfy the given predicate.
  @discardableResult
  public mutating func consume(
    ignoringSkippable: Bool = true,
    while predicate: (Token) -> Bool
  ) -> LazyFilterSequence<ArraySlice<Token>> {
    let start = offset
    while let next = consume(ignoringSkippable: ignoringSkippable, if: predicate) {
      guard next.kind != .eof
        else { break }
    }

    return buffer[start ..< offset].lazy.filter({ token in
      !token.isSkippable || !ignoringSkippable
    })
  }

  // MARK: Backtracking

  /// Rewinds the stream for `count` positions.
  ///
  /// - Parameter count:
  ///   The distance to rewind. `count` must be greater or erqual to 0 and smaller than the current
  ///   lenght of the look-behind buffer.
  public mutating func rewind(count: Int = 1) {
    assert((count >= 0) && (count <= offset))
    offset = offset - count
  }

  /// Clears the look-behind buffer.
  public mutating func clear() {
    buffer.removeFirst(offset)
    offset = 0
  }

}
