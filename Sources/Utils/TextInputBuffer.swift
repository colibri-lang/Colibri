//
//  TextInputBuffer.swift
//  Utils
//
//  Created by Aurélien on 03.03.20.
//

/// An object with methods to read the characters from some buffer as Strings.
public protocol TextInputBuffer {
  
  /// Read all the characters from the buffer into a String.
  func read() throws -> String
  
  /// Read 'count' characters from the buffer, starting from an offset.
  func read(count: Int, from offset: Int) -> String
  
}

extension String: TextInputBuffer {
  
  public func read() throws -> String {
    return self
  }
  
  public func read(count: Int, from offset: Int) -> String {
    return String(self.dropFirst(offset).prefix(count))
  }
  
}
