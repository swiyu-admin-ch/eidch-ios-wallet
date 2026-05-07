import Foundation

extension CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported {

  var typeMetadataUri: TypeMetadataUri? {
    if let vctMetadataUri {
      if let url = URL(string: vctMetadataUri), url.isValidHttpUrl {
        return TypeMetadataUri(url: url, integrity: vctMetadataUriIntegrity)
      }
      return nil
    }
    if let url = URL(string: vct), url.isValidHttpUrl {
      return TypeMetadataUri(url: url, integrity: vctIntegrity)
    }
    return nil
  }
}
