#if DEBUG
import Foundation
@testable import BITCore

extension CredentialIssuerMetadata: Mockable {
  struct Mock {
    static let sample: CredentialIssuerMetadata = Mocker.decode(fromFile: "uetliberg-credential-metadata", bundle: Bundle.module)
    static let sampleBatch: CredentialIssuerMetadata = Mocker.decode(fromFile: "uetliberg-credential-metadata-batch", bundle: Bundle.module)
    static let simpleSample: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-metadata-simple-sample", bundle: Bundle.module)
    static let simpleSampleWithoutDisplays: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-metadata-empty-displays", bundle: Bundle.module)
    static let simpleSampleWithoutValueType: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-metadata-simple-sample-without-value-type", bundle: Bundle.module)
    static let simpleSampleKeyAttestationRequired: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-metadata-simple-sample-key-attestation-required", bundle: Bundle.module)
    static let sampleNoClaims: CredentialIssuerMetadata = Mocker.decode(fromFile: "uetliberg-credential-metadata-noclaims", bundle: Bundle.module)
    static let sampleMultipass: CredentialIssuerMetadata = Mocker.decode(fromFile: "multipass-credential-metadata", bundle: Bundle.module)
    static let sampleUnknownAlgorithm: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-metadata-unknown-algo", bundle: Bundle.module)
    static let sampleUnsupportedKeyStorage: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-metadata-unsupported-key-storage", bundle: Bundle.module)
    static let sampleEmptyKeyStorage: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-metadata-empty-key-storage", bundle: Bundle.module)
    static let sampleMultipleKeyStorage: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-metadata-multiple-key-storage", bundle: Bundle.module)
    static let sampleWithoutProofTypes: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-metadata-without-proof-types", bundle: Bundle.module)
    static let vctUrl: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-metadata-vct-url", bundle: Bundle.module)
    static let vctMetadataUri: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-metadata-vct-metadata-uri", bundle: Bundle.module)
    static let chasseralIssuer01: CredentialIssuerMetadata = Mocker.decode(fromFile: "chsseral-issuer-01-metadata", bundle: Bundle.module)
    static let displayLocaleVariants: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-metadata-display-locale-variants", bundle: Bundle.module)
    static let sampleWithBatchSizeLowerBound: CredentialIssuerMetadata = Mocker.decode(fromFile: "credential-issuer-metadata-with-lower-bound-batch-size", bundle: Bundle.module)

    static let sampleUnsupportedProofTypeAlgorithmData: Data = Mocker.getData(fromFile: "credential-metadata-unsupported-proof-type-algorithm", bundle: Bundle.module) ?? Data()
    static let sampleUnsupportedCryptographicBindingMethodData: Data = Mocker.getData(fromFile: "credential-metadata-unsupported-cryptographic-binding-method", bundle: Bundle.module) ?? Data()

    static let sampleData: Data = Mocker.getData(fromFile: "uetliberg-credential-metadata", bundle: Bundle.module) ?? Data()
    static let sampleBatchData: Data = Mocker.getData(fromFile: "uetliberg-credential-metadata-batch", bundle: Bundle.module) ?? Data()
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
    static let sampleWithBatchSizeLowerBoundData: Data = Mocker.getData(fromFile: "credential-issuer-metadata-with-lower-bound-batch-size", bundle: Bundle.module) ?? Data()
    static let sampleWithBatchSizeUpperBoundData: Data = Mocker.getData(fromFile: "credential-issuer-metadata-with-upper-bound-batch-size", bundle: Bundle.module) ?? Data()
    static let sampleWithTooSmallBatchSizeData: Data = Mocker.getData(fromFile: "credential-issuer-metadata-with-too-small-batch-size", bundle: Bundle.module) ?? Data()
    static let sampleWithTooBigBatchSizeData: Data = Mocker.getData(fromFile: "credential-issuer-metadata-with-too-big-batch-size", bundle: Bundle.module) ?? Data()
    static let sampleWithNegativeBatchSizeData: Data = Mocker.getData(fromFile: "credential-issuer-metadata-with-negative-batch-size", bundle: Bundle.module) ?? Data()

    static let chasseralIssuer01Data: Data = Mocker.getData(fromFile: "chsseral-issuer-01-metadata", bundle: Bundle.module) ?? Data()
    static let displayLocaleVariantsData: Data = Mocker.getData(fromFile: "credential-metadata-display-locale-variants", bundle: Bundle.module) ?? Data()
    static let chasseralIssuerUnsupportedNonceData: Data = Mocker.getData(fromFile: "chsseral-issuer-unsupported-nonce", bundle: Bundle.module) ?? Data()

  }
}
#endif
