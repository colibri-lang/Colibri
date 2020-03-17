import AST

let expectedError = DiagnosticTemplate(
  severity: .fatal,
  description: "expected %1$@")

let unexpectedError = DiagnosticTemplate(
  severity: .fatal,
  description: "unexpected %1$@")

let numberAsDeclName = DiagnosticTemplate(
  severity: .fatal,
  description: "%1$@ identifier can only start with a letter or underscore, not a number")

let keywordAsDeclIdent = DiagnosticTemplate(
  severity: .fatal,
  description: "keyword '%1$@' cannot be used as an identifier here")

let funcDeclWithoutParams = DiagnosticTemplate(
  severity: .fatal,
  description: "expected '(' in parameter list of a function declaration")

let specifierBeforeParamName = DiagnosticTemplate(
  severity: .fatal,
  description:
  "'%1$@' before a parameter name is not allowed, place it before the parameter type instead")

let paramRequiresExplicitType = DiagnosticTemplate(
  severity: .fatal,
  description: "parameter requires an explicit type")
