import BITCredentialShared
import BITOpenID
import BITTheming
import Foundation
import SwiftUI

// MARK: - CredentialCardViewModelProtocol

@MainActor
public protocol CredentialCardViewModelProtocol {
  var issuerDisplay: CredentialIssuerDisplay? { get }
  var credentialDisplay: CredentialDisplay? { get }
  var environment: TrustEnvironment? { get }
  var isRefreshable: Bool { get }
  var isBatchPrivacyWarningVisible: Bool { get }
  var statusText: String { get }
  var statusImage: Image { get }
  var statusTextAlt: String { get }
  var statusBadgeStyle: BadgeStyle { get }
  var statusBadgeType: BadgeType { get }
  var cardStyle: CredentialCardStyle { get }
}

// MARK: - CredentialViewModelProtocol

@MainActor
public protocol CredentialViewModelProtocol: CredentialCardViewModelProtocol, Identifiable {
  associatedtype CredentialType where CredentialType: CredentialProtocol
  var credential: CredentialType { get }

  init(credential: CredentialType, colorScheme: String)

  associatedtype Content: View
  func view() -> Content

  var id: UUID { get }
}
