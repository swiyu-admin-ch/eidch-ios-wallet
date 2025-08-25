#if DEBUG
import Foundation
@testable import BITTestingCore

// swiftlint:disable force_try

extension CredentialMetadataWrapper: Mockable {
  struct Mock {
    static var sample = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "elfa-sdjwt", credentialMetadata: .Mock.sample, rawData: CredentialMetadata.Mock.sampleData)
    static var sampleNoClaims = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "elfa-sdjwt", credentialMetadata: .Mock.sampleNoClaims, rawData: CredentialMetadata.Mock.sampleNoClaimsData)
    static var sampleMultipass = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "sd_elfa_jwt", credentialMetadata: .Mock.sampleMultipass, rawData: CredentialMetadata.Mock.sampleMultipassData)
    static var sampleUnknownAlgorithm = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "elfa", credentialMetadata: .Mock.sampleUnknownAlgorithm, rawData: CredentialMetadata.Mock.sampleUnknownAlgorithmData)
    static var sampleWithoutProofTypes = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "elfa-sdjwt", credentialMetadata: .Mock.sampleWithoutProofTypes, rawData: CredentialMetadata.Mock.sampleWithoutProofTypesData)
    static var sampleKeyAttestationRequired = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "elfa-sdjwt", credentialMetadata: .Mock.simpleSampleKeyAttestationRequired, rawData: CredentialMetadata.Mock.simpleSampleKeyAttestationRequiredData)
    static var sampleEmptyKeyStorage = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "elfa-sdjwt", credentialMetadata: .Mock.sampleEmptyKeyStorage, rawData: CredentialMetadata.Mock.sampleEmptyKeyStorageData)
    static var sampleMultipleKeyStorage = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "elfa-sdjwt", credentialMetadata: .Mock.sampleMultipleKeyStorage, rawData: CredentialMetadata.Mock.sampleMultipleKeyStorageData)
  }
}
// swiftlint:enable all
#endif
