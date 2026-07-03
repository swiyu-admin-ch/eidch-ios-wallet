import BITSdJWT
import Foundation

extension VcSdJwt {

  var typeMetadataUri: TypeMetadataUri? {
    get throws {
      if let vctMetadataUri {
        if let url = URL(string: vctMetadataUri), url.isValidHttpUrl {
          return TypeMetadataUri(url: url, integrity: vctMetadataUriIntegrity)
        }
        return nil
      }

      if let url = URL(string: vct), url.isValidHttpUrl {
        return TypeMetadataUri(url: url, integrity: vctIntegrity)
      }

      // vct#integrity must not be set when vct_metadata_uri not set and vct isn't a https URL
      guard vctIntegrity == nil else {
        throw VcMetadataForVcSdJwtError.superfluousVctIntegrity
      }

      return nil
    }
  }
}
