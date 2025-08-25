import Foundation

public struct CredentialMetadataResponse {

  public init(metadata: CredentialMetadata, raw: Data) {
    self.metadata = metadata
    self.raw = raw
  }

  let metadata: CredentialMetadata
  let raw: Data
}
