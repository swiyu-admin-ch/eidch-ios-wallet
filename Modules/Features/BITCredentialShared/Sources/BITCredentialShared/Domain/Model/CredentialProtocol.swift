import BITAnyCredentialFormat
import Foundation

// MARK: - CredentialDisplayOrderable

public protocol CredentialDisplayOrderable {
  var displayOrder: CredentialDisplayOrder { get }
  var createdAt: Date { get }
}

// MARK: - CredentialProtocol

public protocol CredentialProtocol: CredentialDisplayOrderable {
  var id: UUID { get }
  var format: CredentialFormat { get }
  var issuerUrl: URL { get }
  var selectedConfigurationId: String? { get }
  var authentication: CredentialAuthentication { get }
  var issuerDisplays: [CredentialIssuerDisplay] { get }
  var displays: [CredentialDisplay] { get }
  var createdAt: Date { get }
  var rawCredentialData: RawCredentialData? { get }
}
