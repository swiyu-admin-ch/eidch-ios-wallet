import BITCredential
import BITCredentialShared
import BITPresentation
import Foundation
import SwiftUI

// MARK: - ScanResult

enum ScanResult {
  case credential(any CredentialProtocol, TrustInformation?)
  case presentation(PresentationRequestContext)
  case error(Error)
}

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
