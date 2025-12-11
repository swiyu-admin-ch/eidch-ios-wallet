#if DEBUG
import Foundation
@testable import BITTestingCore

extension CredentialMetadata: Mockable {
  struct Mock {
    static let sample: CredentialMetadata = Mocker.decode(fromFile: "uetliberg-credential-metadata", bundle: Bundle.module)
    static let simpleSample: CredentialMetadata = Mocker.decode(fromFile: "credential-metadata-simple-sample", bundle: Bundle.module)
    static let simpleSampleWithoutOrder: CredentialMetadata = Mocker.decode(fromFile: "credential-metadata-simple-sample-without-order", bundle: Bundle.module)
    static let simpleSampleWithoutDisplays: CredentialMetadata = Mocker.decode(fromFile: "credential-metadata-empty-displays", bundle: Bundle.module)
    static let simpleSampleWithoutValueType: CredentialMetadata = Mocker.decode(fromFile: "credential-metadata-simple-sample-without-value-type", bundle: Bundle.module)
    static let simpleSampleKeyAttestationRequired: CredentialMetadata = Mocker.decode(fromFile: "credential-metadata-simple-sample-key-attestation-required", bundle: Bundle.module)
    static let sampleNoClaims: CredentialMetadata = Mocker.decode(fromFile: "uetliberg-credential-metadata-noclaims", bundle: Bundle.module)
    static let sampleMultipass: CredentialMetadata = Mocker.decode(fromFile: "multipass-credential-metadata", bundle: Bundle.module)
    static let sampleUnknownAlgorithm: CredentialMetadata = Mocker.decode(fromFile: "credential-metadata-unknown-algo", bundle: Bundle.module)
    static let sampleUnsupportedKeyStorage: CredentialMetadata = Mocker.decode(fromFile: "credential-metadata-unsupported-key-storage", bundle: Bundle.module)
    static let sampleEmptyKeyStorage: CredentialMetadata = Mocker.decode(fromFile: "credential-metadata-empty-key-storage", bundle: Bundle.module)
    static let sampleMultipleKeyStorage: CredentialMetadata = Mocker.decode(fromFile: "credential-metadata-multiple-key-storage", bundle: Bundle.module)
    static let sampleWithoutProofTypes: CredentialMetadata = Mocker.decode(fromFile: "credential-metadata-without-proof-types", bundle: Bundle.module)
    static let vctUrl: CredentialMetadata = Mocker.decode(fromFile: "credential-metadata-vct-url", bundle: Bundle.module)
    static let vctMetadataUri: CredentialMetadata = Mocker.decode(fromFile: "credential-metadata-vct-metadata-uri", bundle: Bundle.module)

    static let sampleUnsupportedProofTypeAlgorithmData: Data = Mocker.getData(fromFile: "credential-metadata-unsupported-proof-type-algorithm", bundle: Bundle.module) ?? Data()
    static let sampleUnsupportedCryptographicBindingMethodData: Data = Mocker.getData(fromFile: "credential-metadata-unsupported-cryptographic-binding-method", bundle: Bundle.module) ?? Data()

    static let sampleData: Data = Mocker.getData(fromFile: "uetliberg-credential-metadata", bundle: Bundle.module) ?? Data()
    static let simpleSampleData: Data = Mocker.getData(fromFile: "credential-metadata-simple-sample", bundle: Bundle.module) ?? Data()
    static let simpleSampleWithoutDisplaysData: Data = Mocker.getData(fromFile: "credential-metadata-empty-displays", bundle: Bundle.module) ?? Data()
    static let simpleSampleKeyAttestationRequiredData: Data = Mocker.getData(fromFile: "credential-metadata-simple-sample-key-attestation-required", bundle: Bundle.module) ?? Data()
    static let sampleNoClaimsData: Data = Mocker.getData(fromFile: "uetliberg-credential-metadata-noclaims", bundle: Bundle.module) ?? Data()
    static let sampleMultipassData: Data = Mocker.getData(fromFile: "multipass-credential-metadata", bundle: Bundle.module) ?? Data()
    static let sampleUnknownAlgorithmData: Data = Mocker.getData(fromFile: "credential-metadata-unknown-algo", bundle: Bundle.module) ?? Data()
    static let sampleUnsupportedKeyStorageData: Data = Mocker.getData(fromFile: "credential-metadata-unsupported-key-storage", bundle: Bundle.module) ?? Data()
    static let sampleEmptyKeyStorageData: Data = Mocker.getData(fromFile: "credential-metadata-empty-key-storage", bundle: Bundle.module) ?? Data()
    static let sampleMultipleKeyStorageData: Data = Mocker.getData(fromFile: "credential-metadata-multiple-key-storage", bundle: Bundle.module) ?? Data()
    static let sampleWithoutProofTypesData: Data = Mocker.getData(fromFile: "credential-metadata-without-proof-types", bundle: Bundle.module) ?? Data()
    static let sampleWithUnknownFormatData: Data = Mocker.getData(fromFile: "credential-metadata-with-unknown-format", bundle: Bundle.module) ?? Data()
  }
}
#endif
