#if DEBUG
import Foundation
@testable import BITCore

extension CredentialIssuerMetadata: Mockable {
  struct Mock {
    static let sample: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-metadata-sample", bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "credential-metadata-sample", bundle: Bundle.module) ?? Data()
    static let simpleSample: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-metadata-simple-sample", bundle: Bundle.module)
    static let simpleSampleWithoutDisplays: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-metadata-simple-sample-without-displays", bundle: Bundle.module)
    static let credentialComplex: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-complex", bundle: Bundle.module) // https://www.rfc-editor.org/rfc/rfc9901.html#name-complex-structured-sd-jwt
  }
}
#endif
