import BITAnyCredentialFormat
import BITCore
import BITCrypto
import BITJWT
import BITSwiyuSharedKMP
import Factory
import Foundation

extension Container {

  // MARK: Public

  public var openIDRepository: Factory<OpenIDRepositoryProtocol> {
    self { OpenIDRepository() }
  }

  public var presentationRequestRepository: Factory<PresentationRequestRepositoryProtocol> {
    self { PresentationRequestRepository() }
  }

  public var fetchMetadataUseCase: Factory<FetchMetadataUseCaseProtocol> {
    self { FetchMetadataUseCase() }
  }

  public var fetchAnyVerifiableCredentialUseCase: Factory<FetchAnyVerifiableCredentialUseCaseProtocol> {
    self { FetchAnyVerifiableCredentialUseCase() }
  }

  public var refreshAnyVerifiableCredentialUseCase: Factory<RefreshAnyVerifiableCredentialUseCaseProtocol> {
    self { RefreshAnyVerifiableCredentialUseCase() }
  }

  public var issuanceDPoPKeyRepository: Factory<IssuanceDPoPKeyRepositoryProtocol> {
    self { IssuanceDPoPKeyRepository() }
  }

  public var dateBuffer: Factory<TimeInterval> {
    self { 15 }
  }

  public var presentationRequestService: Factory<PresentationRequestServiceProtocol> {
    self { PresentationRequestService() }
  }

  public var preferredKeyBindingAlgorithmsOrdered: Factory<[JWTAlgorithm]> {
    self { [.ES256] }
  }

  public var supportedDPoPSigningAlgorithms: Factory<[JWTAlgorithm]> {
    self { [.ES256] }
  }

  public var isDPoPEnabled: Factory<Bool> {
    self { false }
  }

  public var validateCredentialOfferInvitationUrlUseCase: Factory<ValidateCredentialOfferInvitationUrlUseCaseProtocol> {
    self { ValidateCredentialOfferInvitationUrlUseCase() }
  }

  public var checkInvitationTypeUseCase: Factory<CheckInvitationTypeUseCaseProtocol> {
    self { CheckInvitationTypeUseCase() }
  }

  public var additionalPresentationSchemes: Factory<[String]> {
    self { [] }
  }

  public var additionalCredentialOfferSchemes: Factory<[String]> {
    self { [] }
  }

  public var encryptionSupportedCurves: Factory<[String]> {
    self { ["P-256"] }
  }

  public var isBatchIssuanceEnabled: Factory<Bool> {
    self { false }
  }

  public var deferredCredentialRequestBodyGenerator: Factory<DeferredCredentialRequestBodyGeneratorProtocol> {
    self { DeferredCredentialRequestBodyGenerator() }
  }

  public var credentialEncryptionContextGenerator: Factory<CredentialEncryptionContextGeneratorProtocol> {
    self { CredentialEncryptionContextGenerator() }
  }

  public var dpopGenerator: Factory<DPoPGeneratorProtocol> {
    self { DPoPGenerator() }
  }

  // MARK: Internal

  var oAuthErrorParser: Factory<OAuthErrorParserProtocol> {
    self { OAuthErrorParser() }
  }

  var openID4VCIErrorParser: Factory<OpenID4VCIErrorParserProtocol> {
    self { OpenID4VCIErrorParser() }
  }

  var typeMetadataService: Factory<TypeMetadataServiceProtocol> {
    self { TypeMetadataService() }
  }

  var vcSchemaService: Factory<VcSchemaServiceProtocol> {
    self { VcSchemaService() }
  }

  var presentationRequestUrlParser: Factory<PresentationRequestUrlParserProtocol> {
    self { PresentationRequestUrlParser() }
  }

  var requestObjectValidator: Factory<RequestObjectValidatorProtocol> {
    self { RequestObjectValidator() }
  }

  var requestObjectEncryptionValidator: Factory<RequestObjectEncryptionValidatorProtocol> {
    self { RequestObjectEncryptionValidator() }
  }

  var jsonSchemaValidator: Factory<JsonSchemaValidatorProtocol> {
    self { JsonSchemaValidator() }
  }

  var vcSdJwtSchemaValidator: Factory<VcSdJwtSchemaValidatorProtocol> {
    self { VcSdJwtSchemaValidator() }
  }

  var credentialResponseEncryptionKeyRepository: Factory<CredentialResponseEncryptionKeyRepositoryProtocol> {
    self { CredentialResponseEncryptionKeyRepository() }
  }

  var credentialEncryptionValidator: Factory<CredentialEncryptionValidatorProtocol> {
    self { CredentialEncryptionValidator() }
  }

  var credentialRequestBodyGenerator: Factory<CredentialRequestBodyGeneratorProtocol> {
    self { CredentialRequestBodyGenerator() }
  }

  var sdJwtBatchCredentialConsistencyValidator: Factory<SdJwtBatchCredentialConsistencyValidatorProtocol> {
    self { SdJwtBatchCredentialConsistencyValidator() }
  }

  var sdJwtCredentialConsistencyChecker: Factory<SdJwtCredentialConsistencyCheckerProtocol> {
    self { SdJwtCredentialConsistencyChecker() }
  }

}

// MARK: - AnyFetcher

extension Container {

  // MARK: Public

  public var anyVpTokenGenerator: Factory<AnyVpTokenGeneratorProtocol> {
    self { AnyVpTokenGenerator() }
  }

  public var fetchVcMetadataUseCase: Factory<FetchVcMetadataUseCaseProtocol> {
    self { FetchVcMetadataUseCase() }
  }

  // MARK: Internal

  var anyFetchCredentialDispatcher: Factory<[CredentialFormat: FetchAnyCredentialUseCaseProtocol]> {
    self {
      [
        CredentialFormat.vcSdJwt: FetchVcSdJwtCredentialUseCase(),
      ]
    }
  }

  var anyVpTokenGeneratorDispatcher: Factory<[CredentialFormat: AnyVpTokenGeneratorProtocol]> {
    self {
      [
        CredentialFormat.vcSdJwt: VcSdJwtVpTokenGenerator(),
      ]
    }
  }

  var fetchVcMetadataForAnyCredentialDispatcher: Factory<[CredentialFormat: FetchVcMetadataForCredentialUseCaseProtocol]> {
    self {
      [
        CredentialFormat.vcSdJwt: FetchVcMetadataForVcSdJwtUseCase(),
      ]
    }
  }
}

// MARK: - VcStatus

extension Container {

  // MARK: Public

  public var statusValidators: Factory<[AnyStatusType: any AnyStatusCheckValidatorProtocol]> {
    self {
      [
        AnyStatusType.tokenStatusList: self.tokenStatusListValidator(),
      ]
    }
  }

  // MARK: Internal

  var tokenStatusListDecoder: Factory<TokenStatusListDecoderProtocol> {
    self { TokenStatusListDecoder() }
  }

  var tokenStatusListByteDecoder: Factory<TokenStatusListByteDecoderProtocol> {
    self { TokenStatusListByteDecoder() }
  }

  var tokenStatusListValidator: Factory<AnyStatusCheckValidatorProtocol> {
    self { TokenStatusListValidator() }
  }

}

// MARK: - Trust statement

extension Container {

  // MARK: Public

  public var trustStatementService: Factory<TrustStatementServiceProtocol> {
    self { TrustStatementService() }
  }

  public var trustStatementRepository: Factory<TrustStatementRepositoryProtocol> {
    self { TrustStatementRepository() }
  }

  public var trustRegistryMapping: Factory<[String: String]> {
    self {
      [
        self.baseRegistryInt(): self.trustRegistryInt(),
        self.baseRegistry(): self.trustRegistry(),
      ]
    }
  }

  public var trustRegistryTrustedDidsV1: Factory<TrustRegistryTrustedDidsV1> {
    self {
      [
        self.trustRegistry(): [self.trustRegistryDidProd()],
        self.trustRegistryInt(): [self.trustRegistryDidIntProd()],
      ]
    }
  }

  public var trustRegistryTrustedDids: Factory<TrustRegistryTrustedDids> {
    self {
      [
        self.trustRegistry(): self.trustStatementTrustedDids(
          trustStatementIssuer: self.trustStatementIssuerProd(),
          publicTransparencyStatementIssuer: self.publicTransparencyStatementIssuerProd()),
        self.trustRegistryInt(): self.trustStatementTrustedDids(
          trustStatementIssuer: self.trustStatementIssuerIntProd(),
          publicTransparencyStatementIssuer: self.publicTransparencyStatementIssuerIntProd()),
      ]
    }
  }

  public var trustEnvironmentDidRegex: Factory<Regex<Substring>> {
    self { #/^did:(?:tdw|webvh):[^:]+:identifier-reg\.trust-infra\.swiyu\.admin\.ch:.*/# }
  }

  public var demoTrustEnvironmentDidRegex: Factory<Regex<Substring>> {
    self { #/^did:(?:tdw|webvh):[^:]+:identifier-reg\.trust-infra\.swiyu-int\.admin\.ch:.*/# }
  }

  public var trustRegistryUrlMapper: Factory<TrustRegistryUrlMapperProtocol> {
    self { TrustRegistryUrlMapper() }
  }

  // MARK: Internal

  var trustStatementValidator: Factory<TrustStatementValidatorProtocol> {
    self { TrustStatementValidator() }
  }

  // MARK: Private

  private var baseRegistryInt: Factory<String> {
    self { "identifier-reg.trust-infra.swiyu-int.admin.ch" }
  }

  private var trustRegistryInt: Factory<String> {
    self { "trust-reg.trust-infra.swiyu-int.admin.ch" }
  }

  private var baseRegistry: Factory<String> {
    self { "identifier-reg.trust-infra.swiyu.admin.ch" }
  }

  private var trustRegistry: Factory<String> {
    self { "trust-reg.trust-infra.swiyu.admin.ch" }
  }

  private var trustRegistryDidIntProd: Factory<String> {
    self { "did:tdw:QmWrXWFEDenvoYWFXxSQGFCa6Pi22Cdsg2r6weGhY2ChiQ:identifier-reg.trust-infra.swiyu-int.admin.ch:api:v1:did:2e246676-209a-4c21-aceb-721f8a90b212" }
  }

  private var trustRegistryDidProd: Factory<String> {
    self { "did:tdw:QmerEFUx69M5AB7oyoPQG6P17MbZQUHoe2Jxz9tXk7cSdf:identifier-reg.trust-infra.swiyu.admin.ch:api:v1:did:02ee8aca-041f-4683-b878-8c6efa977292" }
  }

  private var trustStatementIssuerProd: Factory<String> {
    self { "did:webvh:QmaemSxuZiADoV3F5aBxyvemrUgbWURCv67KU222midYSo:identifier-reg.trust-infra.swiyu.admin.ch:api:v1:did:cc6c0cc8-0743-4cf0-a6b8-c87e30c78d31" }
  }

  private var publicTransparencyStatementIssuerProd: Factory<String> {
    self { "did:webvh:QmUtTiwizd74sn8vv2XfsjjrzjaEuPTbgeT2u3MpFCCqHu:identifier-reg.trust-infra.swiyu.admin.ch:api:v1:did:82b5f3c4-ce00-464d-bc45-b28d3a04ee73" }
  }

  private var trustStatementIssuerIntProd: Factory<String> {
    self { "did:webvh:QmdVPcfEJgvQAJKEjaTWAhskT1kc59KZQiXNenqHBB7iH5:identifier-reg.trust-infra.swiyu-int.admin.ch:api:v1:did:4c131dc4-ced1-454b-bbd4-9401c7512e37" }
  }

  private var publicTransparencyStatementIssuerIntProd: Factory<String> {
    self { "did:webvh:QmNTHuhETA3u2ypoujoaEMaZGKf5HpPwkV6ktfgzu7JzMp:identifier-reg.trust-infra.swiyu-int.admin.ch:api:v1:did:5e5de412-0e7d-4982-a0ed-bd55a0f25a04" }
  }

  private func trustStatementTrustedDids(
    trustStatementIssuer: String,
    publicTransparencyStatementIssuer: String)
    -> [String: [String]]
  {
    [
      TrustStatementType.verificationQueryPublic: [publicTransparencyStatementIssuer],
      TrustStatementType.identity: [trustStatementIssuer],
      TrustStatementType.protectedIssuanceTrustList: [trustStatementIssuer],
      TrustStatementType.protectedIssuanceAuthorization: [trustStatementIssuer],
      TrustStatementType.nonComplianceTrustList: [trustStatementIssuer],
      TrustStatementType.protectedVerificationAuthorization: [trustStatementIssuer],
    ]
  }
}
