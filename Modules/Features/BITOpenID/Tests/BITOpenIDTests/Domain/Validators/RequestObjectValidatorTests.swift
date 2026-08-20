// swiftlint:disable implicitly_unwrapped_optional force_try
import BITAppAttestation
import BITCrypto
import Factory
import Foundation
import Testing
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

@Suite(.serialized)
struct RequestObjectValidatorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let jwsValidatorMock = JWSValidatorMock<RequestObjectJWT>()
    let didResolverSpy = DidResolverHelperProtocolSpy()
    let trustStatementValidatorSpy = TrustStatementValidatorProtocolSpy<VerificationQueryPublicStatementJWT>()
    let jwsSignatureValidatorMock = JWSSignatureValidatorMock<RequestObjectJWT>()

    self.jwsValidatorMock = jwsValidatorMock
    self.didResolverSpy = didResolverSpy
    self.trustStatementValidatorSpy = trustStatementValidatorSpy
    self.jwsSignatureValidatorMock = jwsSignatureValidatorMock

    Container.shared.jwsValidator.register { jwsValidatorMock }
    Container.shared.didResolverHelper.register { didResolverSpy }
    Container.shared.trustStatementValidator.register { trustStatementValidatorSpy }
    Container.shared.trustEnvironmentDidRegex.register { #/^did:example:.*/# }

    validator = RequestObjectValidator()

    createSuccessState()
  }

  // MARK: Internal

  struct ValidationCase: Sendable {
    let build: @Sendable () -> RequestObjectJWS
    let expected: RequestObjectValidationError
  }

  // MARK: - decentralized_identifier prefix (network)

  @Test(arguments: [
    RequestObjectJWS.Mock.sample,
    RequestObjectJWS.Mock.clientIdDIDPrefix,
    RequestObjectJWS.Mock.noAudience,
  ])
  func validate_validCases_validates(jws: RequestObjectJWS) async throws {
    try await validator.validate(jws, transport: .network)

    #expect(jwsValidatorMock.validateActivationBufferCallsCount == 1)
    #expect(trustStatementValidatorSpy.validateForCallsCount == 1)
  }

  @Test
  func validate_validJwsWithoutVerifiedQuery_validates() async throws {
    let jws = RequestObjectJWS.Mock.sampleWithoutVerifiedQuery

    try await validator.validate(jws, transport: .network)

    #expect(jwsValidatorMock.validateActivationBufferCallsCount == 1)
    #expect(trustStatementValidatorSpy.validateForCallsCount == 0)
  }

  @Test(arguments: [
    ValidationCase(build: { RequestObjectJWS.Mock.unsupportedAlgorithm }, expected: .invalidJWSSignatureAlgorithm),
    ValidationCase(build: { RequestObjectJWS.Mock.clientIdMismatch }, expected: .invalidClientId),
    ValidationCase(build: { RequestObjectJWS.Mock.unsupportedResponseType }, expected: .invalidResponseType),
    ValidationCase(build: { RequestObjectJWS.Mock.transactionData }, expected: .transactionDataNotSupported),
    ValidationCase(build: { RequestObjectJWS.Mock.missingState }, expected: .invalidState),
    ValidationCase(build: { RequestObjectJWS.Mock.audienceIssuerMismatch }, expected: .invalidAudience),
  ])
  func validate_knownValidationErrors(testCase: ValidationCase) async {
    let jws = testCase.build()

    await #expect(throws: testCase.expected) {
      try await validator.validate(jws, transport: .network)
    }
  }

  @Test
  func validate_kidMismatch_throwsInvalidClientId() async {
    didResolverSpy.getDidFromReturnValue = "did:example:mismatch"

    await #expect(throws: RequestObjectValidationError.invalidClientId) {
      try await validator.validate(RequestObjectJWS.Mock.sample, transport: .network)
    }
  }

  @Test
  func validate_didResolverThrows_throws() async {
    didResolverSpy.getDidFromThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await validator.validate(RequestObjectJWS.Mock.sample, transport: .network)
    }
  }

  @Test
  func validate_jwsValidatorThrows_rethrowsError() async {
    jwsValidatorMock.validateThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await validator.validate(RequestObjectJWS.Mock.sample, transport: .network)
    }
  }

  @Test
  func validate_decentralizedIdentifierOnProximity_throwsNotSupported() async {
    await #expect(throws: RequestObjectValidationError.decentralizedIdentifierNotSupported) {
      try await validator.validate(RequestObjectJWS.Mock.clientIdDIDPrefix, transport: .proximity)
    }
  }

  // MARK: - verifier_attestation prefix (proximity)

  @Test
  func validate_verifierAttestationTrustedIssuer_succeeds() async throws {
    let validator = configureVerifierAttestation()

    try await validator.validate(RequestObjectJWS.Mock.verifierAttestationPrefix, transport: .proximity)

    #expect(jwsSignatureValidatorMock.validateWithJwkCallsCount == 1)
    #expect(jwsSignatureValidatorMock.validateWithJwkReceivedJwk == attestationBoundJwk)
  }

  @Test
  func validate_verifierAttestationUntrustedIssuer_throwsDidNotTrusted() async {
    let validator = configureVerifierAttestation(trustedDids: ["did:example:someoneElse"])

    await #expect(throws: RequestObjectValidationError.verifierAttestationDidNotTrusted) {
      try await validator.validate(RequestObjectJWS.Mock.verifierAttestationPrefix, transport: .proximity)
    }
    // Outer JWS signature is verified using the bound key even before the trust check.
    #expect(jwsSignatureValidatorMock.validateWithJwkCallsCount == 1)
  }

  @Test
  func validate_verifierAttestationMissingHeaderJwt_throwsInvalidVerifierAttestation() async {
    let validator = configureVerifierAttestation()

    await #expect(throws: RequestObjectValidationError.invalidVerifierAttestation) {
      try await validator.validate(RequestObjectJWS.Mock.verifierAttestationMissingHeader, transport: .proximity)
    }
  }

  @Test
  func validate_verifierAttestationSubjectMismatch_throwsInvalidVerifierAttestation() async {
    let validator = configureVerifierAttestation(attestationSubject: "not-the-client-id")

    await #expect(throws: RequestObjectValidationError.invalidVerifierAttestation) {
      try await validator.validate(RequestObjectJWS.Mock.verifierAttestationPrefix, transport: .proximity)
    }
  }

  @Test
  func validate_verifierAttestationWrongType_throwsInvalidVerifierAttestation() async {
    let validator = configureVerifierAttestation(headerType: "something-else+jwt")

    await #expect(throws: RequestObjectValidationError.invalidVerifierAttestation) {
      try await validator.validate(RequestObjectJWS.Mock.verifierAttestationPrefix, transport: .proximity)
    }
  }

  @Test
  func validate_verifierAttestationRequestObjectSignatureInvalid_throwsInvalidVerifierAttestation() async {
    let validator = configureVerifierAttestation()
    jwsSignatureValidatorMock.validateWithJwkThrowableError = JWSSignatureValidatorError.invalidSignature

    await #expect(throws: JWSSignatureValidatorError.invalidSignature) {
      try await validator.validate(RequestObjectJWS.Mock.verifierAttestationPrefix, transport: .proximity)
    }
  }

  @Test
  func validate_verifierAttestationInnerSignatureInvalid_rethrowsError() async {
    let validator = configureVerifierAttestation()
    jwsValidatorMock.validateThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await validator.validate(RequestObjectJWS.Mock.verifierAttestationPrefix, transport: .proximity)
    }
  }

  @Test
  func validate_verifierAttestationIssuerDidResolutionFails_throwsDidNotFound() async {
    let validator = configureVerifierAttestation()
    didResolverSpy.getDidFromThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await validator.validate(RequestObjectJWS.Mock.verifierAttestationPrefix, transport: .proximity)
    }
  }

  @Test
  func validate_verifierAttestationOnNetwork_throwsNotSupported() async {
    await #expect(throws: RequestObjectValidationError.verifierAttestationNotSupported) {
      try await validator.validate(RequestObjectJWS.Mock.verifierAttestationPrefix, transport: .network)
    }
  }

  // MARK: Private

  private var validator: RequestObjectValidator
  private var jwsValidatorMock: JWSValidatorMock<RequestObjectJWT>
  private var didResolverSpy: DidResolverHelperProtocolSpy
  private var trustStatementValidatorSpy: TrustStatementValidatorProtocolSpy<VerificationQueryPublicStatementJWT>
  private var jwsSignatureValidatorMock: JWSSignatureValidatorMock<RequestObjectJWT>

  private var attestationBoundJwk: JWK {
    JWK.Mock.validSample
  }

  private func createSuccessState() {
    didResolverSpy.getDidFromReturnValue = "did:example:12345"
  }

  private func configureVerifierAttestation(
    attestationSubject: String = "did:example:verifier-subject",
    headerType: String = VerifierAttestationJWT.expectedType,
    trustedDids: [String] = ["did:example:trustedAttestationIssuer"])
    -> RequestObjectValidator
  {
    let attestationJWT = makeVerifierAttestationJWT(subject: attestationSubject, jwk: attestationBoundJwk)
    let attestationHeader = JWSHeader(
      algorithm: JWTAlgorithm.ES256,
      type: headerType,
      keyIdentifier: "did:example:trustedAttestationIssuer#key-1")

    let decoderMock = JWSDecoderMock<VerifierAttestationJWT>(
      jwt: attestationJWT,
      header: attestationHeader)

    Container.shared.jwsDecoder.register { decoderMock }
    Container.shared.jwsSignatureValidator.register { jwsSignatureValidatorMock }
    Container.shared.attestationServiceTrustedDids.register { trustedDids }

    didResolverSpy.getDidFromReturnValue = "did:example:trustedAttestationIssuer"

    return RequestObjectValidator()
  }

  private func makeVerifierAttestationJWT(subject: String, jwk: JWK) -> VerifierAttestationJWT {
    var jwkDict: [String: Any] = [
      "kty": jwk.kty,
      "crv": jwk.crv,
      "x": jwk.x,
      "y": jwk.y,
    ]
    if let alg = jwk.alg { jwkDict["alg"] = alg }
    if let kid = jwk.kid { jwkDict["kid"] = kid }

    let json: [String: Any] = [
      "iss": "did:example:trustedAttestationIssuer",
      "sub": subject,
      "iat": 1722499200,
      "nbf": 1722499200,
      "exp": 1767168000,
      "cnf": ["jwk": jwkDict],
    ]

    let data = try! JSONSerialization.data(withJSONObject: json)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    return try! decoder.decode(VerifierAttestationJWT.self, from: data)
  }
}
