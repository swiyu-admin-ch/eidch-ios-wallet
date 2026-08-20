// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import Foundation
import Testing
@testable import BITAnyCredentialFormat
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

@Suite(.serialized)
struct TrustStatementValidatorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let jwsValidatorMock = JWSValidatorMock<IdentityTrustStatementJWT>()
    let didResolverSpy = DidResolverHelperProtocolSpy()
    let tokenStatusListValidatorSpy = AnyStatusCheckValidatorProtocolSpy()
    let trustRegistryUrlMapperSpy = TrustRegistryUrlMapperProtocolSpy()

    self.jwsValidatorMock = jwsValidatorMock
    self.didResolverSpy = didResolverSpy
    self.tokenStatusListValidatorSpy = tokenStatusListValidatorSpy
    self.trustRegistryUrlMapperSpy = trustRegistryUrlMapperSpy

    Container.shared.jwsValidator.register { jwsValidatorMock }
    Container.shared.didResolverHelper.register { didResolverSpy }
    Container.shared.tokenStatusListValidator.register { tokenStatusListValidatorSpy }
    Container.shared.trustRegistryTrustedDids.register { Self.trustedDids }
    Container.shared.trustRegistryUrlMapper.register { trustRegistryUrlMapperSpy }
    Container.shared.trustEnvironmentDidRegex.register { #/^subject$/# }

    validator = TrustStatementValidator()

    createSuccessState()
  }

  // MARK: Internal

  @Test
  func validate_valid_validates() async throws {
    try await validator.validate(trustStatementMock, for: subjectMock)

    #expect(jwsValidatorMock.validateActivationBufferCallsCount == 1)
    #expect(tokenStatusListValidatorSpy.validateIssuerCallsCount == 1)
  }

  @Test
  func validate_valid_argumentsPassed() async throws {
    try await validator.validate(trustStatementMock, for: subjectMock)

    #expect(trustRegistryUrlMapperSpy.mapDidCallsCount == 1)
    #expect(trustRegistryUrlMapperSpy.mapDidReceivedDid == issuerMock)

    #expect(jwsValidatorMock.validateActivationBufferCallsCount == 1)
    #expect(jwsValidatorMock.validateActivationBufferReceivedJws?.rawJWS == trustStatementMock.rawJWS)

    #expect(tokenStatusListValidatorSpy.validateIssuerCallsCount == 1)
    #expect(tokenStatusListValidatorSpy.validateIssuerReceivedArguments?.anyStatus.type == trustStatementMock.payload.status?.type)
    #expect(tokenStatusListValidatorSpy.validateIssuerReceivedArguments?.issuer == issuerMock)
  }

  @Test(arguments: [
    IdentityTrustStatementJWT.Mock.wrongSubject,
    IdentityTrustStatementJWT.Mock.wrongAlgorithm,
    IdentityTrustStatementJWT.Mock.missingProfileVersion,
    IdentityTrustStatementJWT.Mock.wrongProfileVersion,
  ])
  func validate_knownValidationErrors(trustStatement: IdentityTrustStatement) async {
    await #expect(throws: TrustStatementServiceError.self) {
      try await validator.validate(trustStatement, for: subjectMock)
    }
  }

  @Test
  func validate_withoutSubjectDid_validates() async throws {
    try await validator.validate(trustStatementMock, for: nil)

    #expect(jwsValidatorMock.validateActivationBufferCallsCount == 1)
    #expect(tokenStatusListValidatorSpy.validateIssuerCallsCount == 1)
  }

  @Test
  func validate_withoutStatus_validatesWithoutStatusCheck() async throws {
    let trustStatement = try makeVerificationQueryPublicStatement()

    try await validator.validate(trustStatement, for: nil)

    #expect(jwsValidatorMock.validateActivationBufferCallsCount == 1)
    #expect(tokenStatusListValidatorSpy.validateIssuerCallsCount == 0)
  }

  @Test
  func validate_trustedDidsForTrustStatementTypes_validates() async throws {
    let verificationQueryPublicStatement = try makeVerificationQueryPublicStatement()

    await #expect(throws: Never.self) {
      try await validator.validate(verificationQueryPublicStatement)
      try await validator.validate(IdentityTrustStatementJWT.Mock.validSample)
      try await validator.validate(ProtectedIssuanceTrustListStatementJWT.Mock.sample)
      try await validator.validate(ProtectedIssuanceAuthorizationTrustStatementJWT.Mock.sample)
      try await validator.validate(makeNonComplianceTrustListStatement())
      try await validator.validate(ProtectedVerificationAuthorizationTrustStatementJWT.Mock.sample)
    }
  }

  @Test
  func validate_untrustedDid_throwsValidationError() async {
    didResolverSpy.getDidFromReturnValue = "untrustedDid"

    await #expect(throws: TrustStatementServiceError.validationFailed) {
      try await validator.validate(trustStatementMock, for: subjectMock)
    }
  }

  @Test
  func validate_jwsValidatorThrows_rethrowsError() async {
    jwsValidatorMock.validateThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await validator.validate(trustStatementMock, for: subjectMock)
    }
  }

  @Test
  func validate_didResolverThrows_rethrowsError() async {
    didResolverSpy.getDidFromThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await validator.validate(trustStatementMock, for: subjectMock)
    }
  }

  @Test(arguments: [
    VcStatus.revoked,
    VcStatus.suspended,
    VcStatus.unknown,
    VcStatus.unsupported,
  ])
  func validate_notValidStatus_throwsValidationError(status: VcStatus) async {
    tokenStatusListValidatorSpy.validateIssuerReturnValue = status

    await #expect(throws: TrustStatementServiceError.self) {
      try await validator.validate(trustStatementMock, for: subjectMock)
    }
  }

  // MARK: Private

  private static let trustedDids: TrustRegistryTrustedDids = [
    "example.com": [
      TrustStatementType.verificationQueryPublic: ["did"],
      TrustStatementType.identity: ["did", "subject"],
      TrustStatementType.protectedIssuanceTrustList: ["did"],
      TrustStatementType.protectedIssuanceAuthorization: ["did"],
      TrustStatementType.nonComplianceTrustList: ["did"],
      TrustStatementType.protectedVerificationAuthorization: ["did"],
    ],
  ]

  private let trustStatementMock = IdentityTrustStatementJWT.Mock.validSample
  private let subjectMock = "subject"
  private let issuerMock = "did"

  private var validator: TrustStatementValidator
  private var jwsValidatorMock: JWSValidatorMock<IdentityTrustStatementJWT>
  private var didResolverSpy: DidResolverHelperProtocolSpy
  private var tokenStatusListValidatorSpy: AnyStatusCheckValidatorProtocolSpy
  private var trustRegistryUrlMapperSpy: TrustRegistryUrlMapperProtocolSpy

  private func createSuccessState() {
    tokenStatusListValidatorSpy.validateIssuerReturnValue = .valid
    didResolverSpy.getDidFromReturnValue = issuerMock
    trustRegistryUrlMapperSpy.mapDidReturnValue = URL(string: "https://example.com")
  }

  private func makeVerificationQueryPublicStatement() throws -> VerificationQueryPublicStatement {
    let data = VerificationQueryPublicStatementJWT.Mock.validSampleData
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    let payload = try decoder.decode(VerificationQueryPublicStatementJWT.self, from: data)

    return JWS(
      payload: payload,
      rawPayload: String(data: data, encoding: .utf8) ?? "",
      rawJWS: "rawJWS",
      header: JWSHeader(algorithm: JWTAlgorithm.ES256, keyIdentifier: "did:example:issuer#key-1", profileVersion: "swiss-profile-trust:1.0"))
  }

  private func makeNonComplianceTrustListStatement() -> ProtectedVerificationAuthorizationTrustStatement {
    let sample = ProtectedVerificationAuthorizationTrustStatementJWT.Mock.sample
    var payload = sample.payload
    payload.type = TrustStatementType.nonComplianceTrustList

    return JWS(
      payload: payload,
      rawPayload: sample.rawPayload,
      rawJWS: sample.rawJWS,
      header: sample.header)
  }
}
