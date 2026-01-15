#if DEBUG
import Foundation
@testable import BITTestingCore

// swiftlint:disable force_try

extension CredentialMetadataWrapper: Mockable {
  struct Mock {
    static var sample = try! CredentialMetadataWrapper(credentialConfigurationId: "elfa-sdjwt", credentialMetadata: .Mock.sample, rawData: CredentialMetadata.Mock.sampleData)
    static var sampleNoClaims = try! CredentialMetadataWrapper(credentialConfigurationId: "elfa-sdjwt", credentialMetadata: .Mock.sampleNoClaims, rawData: CredentialMetadata.Mock.sampleNoClaimsData)
    static var sampleMultipass = try! CredentialMetadataWrapper(credentialConfigurationId: "sd_elfa_jwt", credentialMetadata: .Mock.sampleMultipass, rawData: CredentialMetadata.Mock.sampleMultipassData)
    static var sampleUnknownAlgorithm = try! CredentialMetadataWrapper(credentialConfigurationId: "elfa", credentialMetadata: .Mock.sampleUnknownAlgorithm, rawData: CredentialMetadata.Mock.sampleUnknownAlgorithmData)
    static var sampleWithoutProofTypes = try! CredentialMetadataWrapper(credentialConfigurationId: "elfa-sdjwt", credentialMetadata: .Mock.sampleWithoutProofTypes, rawData: CredentialMetadata.Mock.sampleWithoutProofTypesData)
    static var sampleKeyAttestationRequired = try! CredentialMetadataWrapper(credentialConfigurationId: "elfa-sdjwt", credentialMetadata: .Mock.simpleSampleKeyAttestationRequired, rawData: CredentialMetadata.Mock.simpleSampleKeyAttestationRequiredData)
    static var sampleEmptyKeyStorage = try! CredentialMetadataWrapper(credentialConfigurationId: "elfa-sdjwt", credentialMetadata: .Mock.sampleEmptyKeyStorage, rawData: CredentialMetadata.Mock.sampleEmptyKeyStorageData)
    static var sampleMultipleKeyStorage = try! CredentialMetadataWrapper(credentialConfigurationId: "elfa-sdjwt", credentialMetadata: .Mock.sampleMultipleKeyStorage, rawData: CredentialMetadata.Mock.sampleMultipleKeyStorageData)
    static var sampleChasseralIssuer01 = try! CredentialMetadataWrapper(credentialConfigurationId: "chasseral-vc", credentialMetadata: .Mock.chasseralIssuer01, rawData: CredentialMetadata.Mock.chasseralIssuer01Data)
  }
}
// swiftlint:enable all
#endif
