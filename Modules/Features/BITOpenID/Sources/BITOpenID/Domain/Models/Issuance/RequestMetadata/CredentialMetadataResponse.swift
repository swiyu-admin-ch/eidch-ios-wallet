import Foundation

public struct CredentialMetadataResponse {

  public init(metadata: CredentialMetadata, raw: Data) {
    self.metadata = metadata
    self.raw = raw
  }

  public let metadata: CredentialMetadata
  public let raw: Data
}
