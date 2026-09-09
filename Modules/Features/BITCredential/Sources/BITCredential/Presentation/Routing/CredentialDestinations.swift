import BITCredentialShared
import Foundation
import NavigatorUI
import SwiftUI

// MARK: - CredentialDestinations

public enum CredentialDestinations: NavigationDestination {
  case detail(CredentialDetailInput)
  case refresh(CredentialDetailRefreshInput)
  case issuanceType(UUID)

  // MARK: Public

  public var method: NavigationMethod {
    switch self {
    case .detail: .managedSheet
    case .issuanceType,
         .refresh: .push
    }
  }

  public var body: some View {
    switch self {
    case .detail(let input):
      CredentialDetailView(credentialId: input.credentialId)
    case .refresh(let route):
      CredentialDetailUpdateView(credential: route.credential)
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
    case .issuanceType(let credential):
      hasher.combine("issuanceType")
      hasher.combine(credential)
    }
  }
}
