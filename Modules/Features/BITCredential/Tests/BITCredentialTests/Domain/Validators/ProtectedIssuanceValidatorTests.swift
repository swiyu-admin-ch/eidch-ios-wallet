// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

import BITClaimsPathPointer
import BITCore
import Factory
import Foundation
import Testing
@testable import BITAnalytics
@testable import BITAnyCredentialFormat
@testable import BITCredential
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

@Suite(.serialized)
struct ProtectedIssuanceValidatorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()
    registerMocks()
    success()
    validator = ProtectedIssuanceValidator()
  }

  // MARK: Internal

  @Test
  func validate_unprotected_doesNotValidate() async throws {
    trustStatementRepository.fetchProtectedIssuanceTrustListStatementForReturnValue = ProtectedIssuanceTrustListStatementJWT.Mock.unprotected

    try await validator.validate(anyCredential: anyCredentialMock, metadataWrapper: makeMetadataWrapper())

    #expect(trustStatementRepository.fetchProtectedIssuanceTrustListStatementForCallsCount == 1)
    #expect(trustStatementRepository.fetchProtectedIssuanceTrustListStatementForReceivedSubjectDid == anyCredentialMock.issuer)
    #expect(trustInformationService.fetchVcSchemaTrustForTypeVcSchemaIdCallsCount == 0)
  }

  @Test
  func validate_protected_validatesPiaTS() async throws {
    let authorizationTrustStatement = ProtectedIssuanceAuthorizationTrustStatementJWT.Mock.sample

    try await validator.validate(
      anyCredential: anyCredentialMock,
      metadataWrapper: makeMetadataWrapper(authorizationTrustStatement: authorizationTrustStatement))

    #expect(trustStatementRepository.fetchProtectedIssuanceTrustListStatementForCallsCount == 1)
    #expect(trustStatementValidator.validateCallsCount == 1)
    #expect(trustStatementValidator.validateForCallsCount == 1)
    #expect(trustStatementValidator.validateForReceivedTrustStatement == authorizationTrustStatement)
    #expect(trustStatementValidator.validateForReceivedSubjectDid == anyCredentialMock.issuer)
    #expect(trustInformationService.fetchForTypeVcSchemaIdCallsCount == 0)
    #expect(trustInformationService.fetchVcSchemaTrustForTypeVcSchemaIdCallsCount == 0)
  }

  @Test
  func validate_protectedWithInvalidPiaTS_throws() async throws {
    trustStatementValidator.validateForThrowingError = TestingError.error

    await #expect(throws: GovernanceError.unauthorizedIssuance) {
      try await validator.validate(
        anyCredential: anyCredentialMock,
        metadataWrapper: makeMetadataWrapper(authorizationTrustStatement: ProtectedIssuanceAuthorizationTrustStatementJWT.Mock.sample))
    }

    #expect(analyticsProvider.logCounter == 1)
  }

  @Test
  func validate_protectedWithPiaTSotherVct_throws() async throws {
    await #expect(throws: GovernanceError.unauthorizedIssuance) {
      try await validator.validate(
        anyCredential: anyCredentialMock,
        metadataWrapper: makeMetadataWrapper(authorizationTrustStatement: ProtectedIssuanceAuthorizationTrustStatementJWT.Mock.otherVct))
    }

    #expect(trustStatementValidator.validateForCallsCount == 0)
    #expect(analyticsProvider.logCounter == 1)
  }

  @Test
  func validate_protectedWithoutPiaTS_usesTrust1_0VcSchemaTrust() async throws {
    trustInformationService.fetchVcSchemaTrustForTypeVcSchemaIdReturnValue = .trusted

    try await validator.validate(anyCredential: anyCredentialMock, metadataWrapper: makeMetadataWrapper())

    #expect(trustInformationService.fetchForTypeVcSchemaIdCallsCount == 0)
    #expect(trustInformationService.fetchVcSchemaTrustForTypeVcSchemaIdCallsCount == 1)
    #expect(analyticsProvider.logCounter == 0)
    #expect(trustInformationService.fetchVcSchemaTrustForTypeVcSchemaIdReceivedArguments?.subjectDid == anyCredentialMock.issuer)
    #expect(trustInformationService.fetchVcSchemaTrustForTypeVcSchemaIdReceivedArguments?.type == .issuance)
    #expect(trustInformationService.fetchVcSchemaTrustForTypeVcSchemaIdReceivedArguments?.vcSchemaId == anyCredentialMock.vcSchemaId)
  }

  @Test
  func validate_protectedWithoutPiaTSAndFailingTrust1_0VcSchemaTrust_throws() async throws {
    trustInformationService.fetchVcSchemaTrustForTypeVcSchemaIdReturnValue = .untrusted

    await #expect(throws: GovernanceError.unauthorizedIssuance) {
      try await validator.validate(anyCredential: anyCredentialMock, metadataWrapper: makeMetadataWrapper())
    }

    #expect(trustInformationService.fetchForTypeVcSchemaIdCallsCount == 0)
    #expect(trustInformationService.fetchVcSchemaTrustForTypeVcSchemaIdCallsCount == 1)
    #expect(analyticsProvider.logCounter == 1)
  }

  @Test
  func validate_protectedWithoutPiaTSAndNoTrust1_throws() async throws {
    trustInformationService.fetchVcSchemaTrustForTypeVcSchemaIdReturnValue = .notProtected

    await #expect(throws: GovernanceError.unauthorizedIssuance) {
      try await validator.validate(anyCredential: anyCredentialMock, metadataWrapper: makeMetadataWrapper())
    }

    #expect(trustInformationService.fetchVcSchemaTrustForTypeVcSchemaIdCallsCount == 1)
    #expect(analyticsProvider.logCounter == 1)
  }

  @Test
  func validate_trustListRepositoryThrows_throws() async throws {
    trustStatementRepository.fetchProtectedIssuanceTrustListStatementForThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await validator.validate(anyCredential: anyCredentialMock, metadataWrapper: makeMetadataWrapper())
    }
  }

  @Test
  func validate_trustListValidationThrows_throws() async throws {
    trustStatementValidator.validateThrowingError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await validator.validate(anyCredential: anyCredentialMock, metadataWrapper: makeMetadataWrapper())
    }
  }

  // MARK: Private

  private let anyCredentialMock = MockAnyCredential()

  private var validator: ProtectedIssuanceValidator!
  private var trustStatementRepository: TrustStatementRepositoryProtocolSpy!
  private var trustStatementValidator: TrustStatementValidatorProtocolSpy<ProtectedIssuanceAuthorizationTrustStatementJWT>!
  private var trustInformationService: TrustInformationServiceProtocolSpy!
  private var analyticsProvider: MockProvider!

  private mutating func registerMocks() {
    let trustStatementService = TrustStatementServiceProtocolSpy()
    let trustStatementRepository = TrustStatementRepositoryProtocolSpy()
    let trustStatementValidator = TrustStatementValidatorProtocolSpy<ProtectedIssuanceAuthorizationTrustStatementJWT>()
    let trustInformationService = TrustInformationServiceProtocolSpy()
    let analyticsProvider = MockProvider()
    let analytics = AnalyticsSpy()
    analytics.register(analyticsProvider)

    self.trustStatementRepository = trustStatementRepository
    self.trustStatementValidator = trustStatementValidator
    self.trustInformationService = trustInformationService
    self.analyticsProvider = analyticsProvider

    Container.shared.trustStatementService.register { trustStatementService }
    Container.shared.trustStatementRepository.register { trustStatementRepository }
    Container.shared.trustStatementValidator.register { trustStatementValidator }
    Container.shared.trustInformationService.register { trustInformationService }
    Container.shared.analytics.register { analytics }
  }

  private func success() {
    trustStatementRepository.fetchProtectedIssuanceTrustListStatementForReturnValue = ProtectedIssuanceTrustListStatementJWT.Mock.sample
    trustInformationService.fetchVcSchemaTrustForTypeVcSchemaIdReturnValue = .notProtected
  }

  private func makeMetadataWrapper(
    authorizationTrustStatement: ProtectedIssuanceAuthorizationTrustStatement? = nil) throws
    -> CredentialIssuerMetadataWrapper
  {
    var selectedCredential = MockAnyCredentialConfigurationSupported()
    selectedCredential.protectedIssuanceAuthorizationTrustStatement = authorizationTrustStatement

    let metadata = CredentialIssuerMetadata.Mock.sample.changing(\.credentialConfigurationsSupported, to: ["configuration": selectedCredential])
    let metadataJws = CredentialIssuerMetadataJWT.Mock.createJWS(from: metadata)
    return try CredentialIssuerMetadataWrapper(credentialConfigurationId: "configuration", metadataJws: metadataJws)
  }
}
