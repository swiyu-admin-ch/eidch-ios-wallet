import BITAnyCredentialFormat
import BITCore
import BITCrypto
import BITJWT
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

  public var dateBuffer: Factory<TimeInterval> {
    self { 15 }
  }

  public var presentationRequestService: Factory<PresentationRequestServiceProtocol> {
    self { PresentationRequestService() }
  }

  public var trustRegistryMapping: Factory<[String: String]> {
    self {
      [
        self.baseRegistryInt(): self.trustRegistryInt(),
        self.baseRegistry(): self.trustRegistry(),
      ]
    }
  }

  public var trustRegistryTrustedDids: Factory<[String]> {
    self { [ self.trustRegistryDidIntProd(), self.trustRegistryDidProd() ] }
  }

  public var presentationFieldsValidator: Factory<PresentationFieldsValidatorProtocol> {
    self { PresentationFieldsValidator() }
  }

  public var preferredKeyBindingAlgorithmsOrdered: Factory<[JWTAlgorithm]> {
    self { [.ES256] }
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

  public var declinePresentationUseCase: Factory<DeclinePresentationUseCaseProtocol> {
    self { DeclinePresentationUseCase() }
  }

  // MARK: Internal

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

  var jsonSchemaValidator: Factory<JsonSchemaValidatorProtocol> {
    self { JsonSchemaValidator() }
  }

  var vcSdJwtSchemaValidator: Factory<VcSdJwtSchemaValidatorProtocol> {
    self { VcSdJwtSchemaValidator() }
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
}

// MARK: - AnyFetcher

extension Container {

  // MARK: Public

  public var anyDescriptorMapGenerator: Factory<AnyDescriptorMapGeneratorProtocol> {
    self { AnyDescriptorMapGenerator() }
  }

  public var anyVpTokenGenerator: Factory<AnyVpTokenGeneratorProtocol> {
    self { AnyVpTokenGenerator() }
  }

  public var fetchVcMetadataUseCase: Factory<FetchVcMetadataUseCaseProtocol> {
    self { FetchVcMetadataUseCase() }
  }

  // MARK: Internal

  var anyDescriptorMapGeneratorDispatcher: Factory<[CredentialFormat: AnyDescriptorMapGeneratorProtocol]> {
    self {
      [
        CredentialFormat.vcSdJwt: VcSdJwtDescriptorMapGenerator(),
      ]
    }
  }

  var anyFetchCredentialDispatcher: Factory<[CredentialFormat: FetchAnyCredentialUseCaseProtocol]> {
    self {
      [
        CredentialFormat.vcSdJwt: FetchVcSdJwtCredentialUseCase(),
      ]
    }
  }

  var anyCredentialJsonGenerator: Factory<AnyCredentialJsonGeneratorProtocol> {
    self { AnyCredentialJsonGenerator() }
  }

  var anyCredentialJsonGeneratorDispatcher: Factory<[CredentialFormat: AnyCredentialJsonGeneratorProtocol]> {
    self {
      [
        CredentialFormat.vcSdJwt: VcSdJwtCredentialJsonGenerator(),
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

  var fetchVcMetadataForAnyCredentialDispatcher: Factory<[CredentialFormat: FetchVcMetadataForAnyCredentialUseCaseProtocol]> {
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

  var tokenStatusListValidator: Factory<AnyStatusCheckValidatorProtocol> { self { TokenStatusListValidator() } }

}

// MARK: - Trust statement

extension Container {

  // MARK: Public

  public var trustStatementService: Factory<TrustStatementServiceProtocol> {
    self { TrustStatementService() }
  }

  public var baseRegistryDomainPattern: Factory<String> {
    self { #"^did:tdw:[^:]+:([^:]+\.swiyu(-int)?\.admin\.ch):[^:]+"# }
  }

  public var trustRegistryRepository: Factory<TrustRegistryRepositoryProtocol> {
    self { TrustRegistryRepository() }
  }

  // MARK: Internal

  var trustStatementValidator: Factory<TrustStatementValidatorProtocol> {
    self { TrustStatementValidator() }
  }

}
