import Foundation

public struct CredentialIssuerMetadataResponse {

  public init(metadata: CredentialIssuerMetadata, raw: Data) {
    self.metadata = metadata
    self.raw = raw
  }

  public let metadata: CredentialIssuerMetadata
  public let raw: Data
}
