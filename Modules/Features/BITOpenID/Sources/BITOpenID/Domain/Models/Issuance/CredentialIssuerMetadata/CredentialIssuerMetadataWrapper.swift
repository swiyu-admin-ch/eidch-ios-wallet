import BITJWT
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

  // MARK: Lifecycle

  public init(offer: CredentialOffer, metadataJws: JWS<CredentialIssuerMetadataJWT>) throws {
    guard let configurationId = offer.credentialConfigurationIds.first else {
      throw CredentialIssuerMetadataWrapperError.selectedCredentialNotFound
    }
    try self.init(credentialConfigurationId: configurationId, metadataJws: metadataJws)
  }

  public init(credentialConfigurationId: String, metadataJws: JWS<CredentialIssuerMetadataJWT>) throws {
    self.metadataJws = metadataJws
    self.credentialConfigurationId = credentialConfigurationId
    guard let selectedCredential = metadataJws.payload.credentialIssuerMetadata.credentialConfigurationsSupported.first(where: { $0.key == credentialConfigurationId })?.value else {
      throw CredentialIssuerMetadataWrapperError.selectedCredentialNotFound
    }
    self.selectedCredential = selectedCredential
  }

  // MARK: Public

  public let metadataJws: JWS<CredentialIssuerMetadataJWT>
  public let selectedCredential: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported
  public let credentialConfigurationId: String

  public var credentialIssuerMetadata: CredentialIssuerMetadata {
    metadataJws.payload.credentialIssuerMetadata
  }

  public var rawData: Data {
    Data(metadataJws.rawPayload.utf8)
  }

}
