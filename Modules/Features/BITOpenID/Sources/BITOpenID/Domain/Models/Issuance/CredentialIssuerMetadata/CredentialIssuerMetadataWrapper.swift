import Foundation

// MARK: - CredentialIssuerMetadataWrapperError

enum CredentialIssuerMetadataWrapperError: Error {
  case selectedCredentialNotFound
}

// MARK: - CredentialIssuerMetadataWrapper

/*
 - Description: CredentialIssuerMetadataWrapper handles the mapping between the selectedCredential coming from the metadata and the metadata themselves. That selectedCredentialID will allow us to find later on the correct rawCredential payload and map the corresponding claims.
 */

public struct CredentialIssuerMetadataWrapper {

  public var credentialIssuerMetadata: CredentialIssuerMetadata
  public var selectedCredential: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported
  public var rawData: Data
  public var credentialConfigurationId: String

  public init(credentialConfigurationId: String, credentialIssuerMetadata: CredentialIssuerMetadata, rawData: Data) throws {
    self.credentialIssuerMetadata = credentialIssuerMetadata
    self.credentialConfigurationId = credentialConfigurationId
    guard let selectedCredential = credentialIssuerMetadata.credentialConfigurationsSupported.first(where: { $0.key == credentialConfigurationId })?.value else {
      throw CredentialIssuerMetadataWrapperError.selectedCredentialNotFound
    }
    self.selectedCredential = selectedCredential
    self.rawData = rawData
  }

}
