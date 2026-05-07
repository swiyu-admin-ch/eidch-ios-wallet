#if DEBUG
import Foundation
@testable import BITCore

// swiftlint:disable force_try

extension CredentialIssuerMetadataWrapper: Mockable {
  struct Mock {
    static var sample = try! CredentialIssuerMetadataWrapper(credentialConfigurationId: "elfa-sdjwt", credentialIssuerMetadata: .Mock.sample, rawData: CredentialIssuerMetadata.Mock.sampleData)
    static var sampleBatch = try! CredentialIssuerMetadataWrapper(credentialConfigurationId: "elfa-sdjwt", credentialIssuerMetadata: .Mock.sampleBatch, rawData: CredentialIssuerMetadata.Mock.sampleBatchData)
    static var sampleNoClaims = try! CredentialIssuerMetadataWrapper(credentialConfigurationId: "elfa-sdjwt", credentialIssuerMetadata: .Mock.sampleNoClaims, rawData: CredentialIssuerMetadata.Mock.sampleNoClaimsData)
    static var sampleMultipass = try! CredentialIssuerMetadataWrapper(credentialConfigurationId: "sd_elfa_jwt", credentialIssuerMetadata: .Mock.sampleMultipass, rawData: CredentialIssuerMetadata.Mock.sampleMultipassData)
    static var sampleUnknownAlgorithm = try! CredentialIssuerMetadataWrapper(credentialConfigurationId: "elfa", credentialIssuerMetadata: .Mock.sampleUnknownAlgorithm, rawData: CredentialIssuerMetadata.Mock.sampleUnknownAlgorithmData)
    static var sampleWithoutProofTypes = try! CredentialIssuerMetadataWrapper(credentialConfigurationId: "elfa-sdjwt", credentialIssuerMetadata: .Mock.sampleWithoutProofTypes, rawData: CredentialIssuerMetadata.Mock.sampleWithoutProofTypesData)
    static var sampleKeyAttestationRequired = try! CredentialIssuerMetadataWrapper(credentialConfigurationId: "elfa-sdjwt", credentialIssuerMetadata: .Mock.simpleSampleKeyAttestationRequired, rawData: CredentialIssuerMetadata.Mock.simpleSampleKeyAttestationRequiredData)
    static var sampleEmptyKeyStorage = try! CredentialIssuerMetadataWrapper(credentialConfigurationId: "elfa-sdjwt", credentialIssuerMetadata: .Mock.sampleEmptyKeyStorage, rawData: CredentialIssuerMetadata.Mock.sampleEmptyKeyStorageData)
    static var sampleMultipleKeyStorage = try! CredentialIssuerMetadataWrapper(credentialConfigurationId: "elfa-sdjwt", credentialIssuerMetadata: .Mock.sampleMultipleKeyStorage, rawData: CredentialIssuerMetadata.Mock.sampleMultipleKeyStorageData)
    static var sampleChasseralIssuer01 = try! CredentialIssuerMetadataWrapper(credentialConfigurationId: "chasseral-vc", credentialIssuerMetadata: .Mock.chasseralIssuer01, rawData: CredentialIssuerMetadata.Mock.chasseralIssuer01Data)
  }
}
// swiftlint:enable all
#endif
