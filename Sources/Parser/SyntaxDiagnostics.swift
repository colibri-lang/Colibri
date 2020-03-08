import AST

let expectedError = DiagnosticTemplate(severity: .fatal, description: "expected %1$@")

let unexpectedError = DiagnosticTemplate(severity: .fatal, description: "unexpected %1$@")
