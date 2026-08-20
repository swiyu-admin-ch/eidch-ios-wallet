import BITCredentialShared
import Foundation
import NavigatorUI
import SwiftUI

// MARK: - CredentialDestinations

public enum CredentialDestinations: NavigationDestination {
  case detail(CredentialDetailInput)
  case refresh(CredentialDetailRefreshInput)
  case updateCredentialInfo(CredentialIssuerDisplay?)
  case issuanceType(UUID)

  // MARK: Public

  public var method: NavigationMethod {
    switch self {
    case .detail: .managedSheet
    case .issuanceType,
         .refresh,
         .updateCredentialInfo: .push
    }
  }

  public var body: some View {
    switch self {
    case .detail(let input):
      CredentialDetailView(credentialId: input.credentialId)
    case .refresh(let route):
      CredentialDetailUpdateView(credential: route.credential)
    case .updateCredentialInfo(let issuerDisplay):
      CredentialDetailUpdateView(issuerDisplay: issuerDisplay)
    case .issuanceType(let credentialId):
      IssuanceTypeView(credentialId: credentialId)
    }
  }
}

// MARK: Hashable

extension CredentialDestinations {
  public static func == (lhs: CredentialDestinations, rhs: CredentialDestinations) -> Bool {
    switch (lhs, rhs) {
    case (.detail(let lhsInput), .detail(let rhsInput)):
      lhsInput == rhsInput
    case (.refresh(let lhsRoute), .refresh(let rhsRoute)):
      lhsRoute == rhsRoute
    case (.updateCredentialInfo(let lhsIssuerDisplay), .updateCredentialInfo(let rhsIssuerDisplay)):
      lhsIssuerDisplay?.id == rhsIssuerDisplay?.id
    case (.issuanceType(let lhsCredential), .issuanceType(let rhsCredential)):
      lhsCredential == rhsCredential
    default:
      false
    }
  }

  public func hash(into hasher: inout Hasher) {
    switch self {
    case .detail(let input):
      hasher.combine("detail")
      hasher.combine(input)
    case .refresh(let route):
      hasher.combine("refresh")
      hasher.combine(route)
    case .updateCredentialInfo(let issuerDisplay):
      hasher.combine("updateCredentialInfo")
      hasher.combine(issuerDisplay?.id)
    case .issuanceType(let credential):
      hasher.combine("issuanceType")
      hasher.combine(credential)
    }
  }
}
