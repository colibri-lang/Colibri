//
//  SourceLocation.swift
//  Utils
//
//  Created by Aurélien on 04.03.20.
//

import Utils

/// A reference to a source of code (a TextInputBuffer).
public class SourceReference {
  
  /// The name of the source.
  public let name: String
  /// The actual text of the source.
  public let source: TextInputBuffer
  
  public init(name: String, source: TextInputBuffer) {
    self.name = name
    self.source = source
  }

}

/// A location (line, column and character offset) in a source of code.
public struct SourceLocation {
  
  /// The source the location is referring to.
  public let sourceRef: SourceReference
  /// The line number of the location in the source (indexed starting from 1).
  public var line: Int
  /// The column number of the location in the source (indexed starting from 1).
  public var column: Int
  /// The character offset of the location in the source (indexed starting from 0).
  public var offset: Int
  
  public init(sourceRef: SourceReference, line: Int = 1, column: Int = 1, offset: Int = 0) {
    self.sourceRef = sourceRef
    self.line = line
    self.column = column
    self.offset = offset
  }
  
}

extension SourceLocation: Hashable {

  public static func == (lhs: SourceLocation, rhs: SourceLocation) -> Bool {
    return lhs.sourceRef === rhs.sourceRef && lhs.offset == rhs.offset
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(sourceRef))
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

/// A range between two location in a source.
public typealias SourceRange = Range<SourceLocation>

extension SourceRange {
  
  public var sourceRef: SourceReference {
    return lowerBound.sourceRef
  }
  
}
