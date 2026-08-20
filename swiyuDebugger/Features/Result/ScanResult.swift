import BITCredential
import BITCredentialShared
import BITPresentation
import Foundation
import SwiftUI

// MARK: - ScanResult

enum ScanResult {
  case credential(any CredentialProtocol)
  case presentation(PresentationRequestContext)
  case error(Error)
}

// MARK: Hashable

extension ScanResult: Hashable {

  static func == (lhs: ScanResult, rhs: ScanResult) -> Bool {
    switch (lhs, rhs) {
    case (.credential(let leftCredential), .credential(let rightCredential)):
      leftCredential.id == rightCredential.id
    case (.presentation(let leftContext), .presentation(let rightContext)):
      leftContext == rightContext
    case (.error(let leftError), .error(let rightError)):
      String(describing: type(of: leftError)) == String(describing: type(of: rightError)) &&
        leftError.localizedDescription == rightError.localizedDescription
    default:
      false
    }
  }

  func hash(into hasher: inout Hasher) {
    switch self {
    case .credential(let credential):
      hasher.combine("credential")
      hasher.combine(credential.id)
    case .presentation(let context):
      hasher.combine("presentation")
      hasher.combine(context)
    case .error(let error):
      hasher.combine("error")
      hasher.combine(String(describing: type(of: error)))
      hasher.combine(error.localizedDescription)
    }
  }
}

// MARK: - ScanResult + UI

extension ScanResult {
  var title: String {
    switch self {
    case .credential:
      "Credential fetch successful 🎉!"
    case .presentation:
      "Request object fetch successful 🎉!"
    case .error:
      "Fetch fails 😱!"
    }
  }

  var headerSymbolName: String {
    switch self {
    case .error:
      "xmark.circle.fill"
    case .credential,
         .presentation:
      "checkmark.seal.fill"
    }
  }

  var headerColor: Color {
    switch self {
    case .error:
      .red
    case .credential,
         .presentation:
      .green
    }
  }

  var label: String {
    switch self {
    case .credential:
      "credential"
    case .presentation:
      "presentation"
    case .error:
      "error"
    }
  }
}
