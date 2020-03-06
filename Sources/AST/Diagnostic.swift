import Foundation

/// Enumeration of issue severity levels of a problem or issue.
public enum Severity {

  /// Denotes an issue that prevents compilation.
  case fatal

  /// Denotes an issue that does not prevent compilation, but is indicative of either a possibly
  /// erroneous situation, or a discouraged practice.
  case warning

}

/// A template that can be used to generate diagnostics.
public class DiagnosticTemplate: CustomStringConvertible {

  /// The severity of this diagnostic.
  public let severity: Severity

  /// The description template for this template.
  public let description: String

  public init(severity: Severity, description: String) {
    self.severity = severity
    self.description = description
  }

  /// Instantiates this template.
  ///
  /// - Parameters:
  ///   - range: The source range at which the error occured.
  ///   - arguments: The arguments of the diagnostic description.
  public func instantiate(at range: SourceRange, with arguments: [String] = []) -> Diagnostic {
    return Diagnostic(
      severity: severity,
      description: String(format: description, arguments: arguments),
      range: range)
  }

}

/// A problem or issue that should be reported to the user.
public struct Diagnostic: Error, CustomStringConvertible {

  /// The severity of this diagnostic.
  public let severity: Severity

  /// The description of this diagnostic.
  public let description: String

  /// The source range at which the error reported by this diagnostic occured.
  public let range: SourceRange

  public init(severity: Severity, description: String, range: SourceRange) {
    self.severity = severity
    self.description = description
    self.range = range
  }

}
