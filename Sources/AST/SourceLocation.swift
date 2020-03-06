//
//  SourceLocation.swift
//  Utils
//
//  Created by Aurélien on 04.03.20.
//

/// A translation unit.
///
/// A translation unit is a reference to a source of code that needs to be translated by the
/// compiler.
public class TranslationUnit {
  
  /// The name of the unit.
  public let name: String
  
  /// The actual source code of the translation unit.
  public let source: String
  
  public init(name: String, source: String) {
    self.name = name
    self.source = source
  }

}

/// A location (line, column and character offset) in a source of code.
public struct SourceLocation {
  
  /// The source the location is referring to.
  public let translationUnit: TranslationUnit
  
  /// The line number of the location in the source (indexed starting from 1).
  public var line: Int
  
  /// The column number of the location in the source (indexed starting from 1).
  public var column: Int
  
  /// The character offset of the location in the source (indexed starting from 0).
  public var offset: Int
  
  public init(translationUnit: TranslationUnit, line: Int = 1, column: Int = 1, offset: Int = 0) {
    self.translationUnit = translationUnit
    self.line = line
    self.column = column
    self.offset = offset
  }
  
}

extension SourceLocation: Hashable {

  public static func == (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
    return lhs.translationUnit === rhs.translationUnit && lhs.offset == rhs.offset
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(translationUnit))
    hasher.combine(offset)
  }
  
}

extension SourceLocation: Comparable {
  
  public static func < (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
    return lhs.offset < rhs.offset
  }
  
}

extension SourceLocation: CustomStringConvertible {
  
  public var description: String {
    return "\(line):\(column)"
  }
  
}

/// A range between two locations in a source.
public typealias SourceRange = Range<SourceLocation>

extension SourceRange {
  
  public var translationUnit: TranslationUnit {
    return lowerBound.translationUnit
  }

  public static func union<C>(of subranges: C) -> SourceRange?
    where C: Collection, C.Element == SourceRange
  {
    guard !subranges.isEmpty
      else { return nil }

    let lower = subranges.min(by: { a, b in a.lowerBound < b.lowerBound })
    let upper = subranges.max(by: { a, b in a.upperBound < b.upperBound })
    return lower!.lowerBound ..< upper!.upperBound
  }
  
}
