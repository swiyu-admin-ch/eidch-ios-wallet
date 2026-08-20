#if DEBUG
import Foundation
@testable import BITCore

// MARK: CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported.Mock

extension CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported: Mockable {

  struct Mock {
    static let sampleData: Data = getData(fromFile: "vc-sd-jwt-configuration-supported", bundle: Bundle.module) ?? Data()
  }

}
#endif
