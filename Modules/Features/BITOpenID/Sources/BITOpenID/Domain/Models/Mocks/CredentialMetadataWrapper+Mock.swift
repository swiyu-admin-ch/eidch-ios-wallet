#if DEBUG
import Foundation
@testable import BITTestingCore

// swiftlint:disable force_try

extension CredentialMetadataWrapper: Mockable {
  struct Mock {
    static var sample = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "elfa-sdjwt", credentialMetadata: .Mock.sample)
    static var sampleNoClaims = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "elfa-sdjwt", credentialMetadata: .Mock.sampleNoClaims)
    static var sampleMultipass = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "sd_elfa_jwt", credentialMetadata: .Mock.sampleMultipass)
    static var sampleUnknownAlgorithm = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "elfa", credentialMetadata: .Mock.sampleUnknownAlgorithm)
    static var sampleWithoutProofTypes = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "elfa-sdjwt", credentialMetadata: .Mock.sampleWithoutProofTypes)
  }
}
// swiftlint:enable all
#endif
