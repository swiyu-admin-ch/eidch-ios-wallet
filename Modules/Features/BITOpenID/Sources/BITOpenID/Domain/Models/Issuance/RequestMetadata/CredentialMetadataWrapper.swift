import Foundation

// MARK: - CredentialMetadataWrapperErrorTest

enum CredentialMetadataWrapperErrorTest: Error {
  case selectedCredentialNotFound
}

// MARK: - CredentialMetadataWrapper

/*
 - Description: CredentialMetadataWrapper handles the mapping between the selectedCredential coming from the metadata and the metadata themselves. That selectedCredentialID will allow us to find later on the correct rawCredential payload and map the corresponding claims.
 */

public struct CredentialMetadataWrapper {

  public var credentialMetadata: CredentialMetadata
  public var selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported
  public var rawData: Data
  public var credentialConfigurationId: String

  public init(credentialConfigurationId: String, credentialMetadata: CredentialMetadata, rawData: Data) throws {
    self.credentialMetadata = credentialMetadata
    self.credentialConfigurationId = credentialConfigurationId
    guard let selectedCredential = credentialMetadata.credentialConfigurationsSupported.first(where: { $0.key == credentialConfigurationId })?.value else {
      throw CredentialMetadataWrapperErrorTest.selectedCredentialNotFound
    }
    self.selectedCredential = selectedCredential
    self.rawData = rawData
  }

}
