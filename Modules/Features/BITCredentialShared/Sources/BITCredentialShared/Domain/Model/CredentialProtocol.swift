import Foundation

// MARK: - CredentialProtocol

public protocol CredentialProtocol {
  var id: UUID { get }
  var format: String { get }
  var issuerUrl: String { get }
  var selectedConfigurationId: String? { get }
  var authentication: CredentialAuthentication { get }
  var issuerDisplays: [CredentialIssuerDisplay] { get }
  var displays: [CredentialDisplay] { get }
  var createdAt: Date { get }
  var rawCredentialData: RawCredentialData? { get }
}
