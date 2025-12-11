import Foundation

public protocol CredentialProtocol {
  var id: UUID { get }
  var format: String { get }
  var selectedConfigurationId: String? { get }
  var issuerDisplays: [CredentialIssuerDisplay] { get }
  var displays: [CredentialDisplay] { get }
  var createdAt: Date { get }
  var keyBinding: CredentialKeyBinding? { get }
  var rawCredentialData: RawCredentialData? { get }
}
