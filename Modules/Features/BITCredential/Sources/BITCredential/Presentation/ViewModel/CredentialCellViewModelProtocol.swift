import BITCredentialShared
import BITOpenID
import BITTheming
import Foundation
import SwiftUI

// MARK: - CredentialCellViewModelProtocol

public protocol CredentialCellViewModelProtocol {
  var issuerDisplay: CredentialIssuerDisplay? { get }
  var credentialDisplay: CredentialDisplay? { get }
  var environment: TrustEnvironment? { get }
  var statusText: String { get }
  var statusImage: Image { get }
  var statusTextAlt: String { get }
  var statusBadgeStyle: any BadgeStyle { get }
  var statusColor: Color { get }
}

// MARK: - CredentialViewModelProtocol

public protocol CredentialViewModelProtocol: Identifiable {
  associatedtype CredentialType where CredentialType: CredentialProtocol
  var credential: CredentialType { get }

  init(credential: CredentialType, colorScheme: String)

  associatedtype Content: View
  func view() -> Content

  var id: UUID { get }
}
