import CryptoKit
import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITCrypto
@testable import BITJWT
@testable import BITTestingCore

@Suite(.container)
struct JWSSignatureValidatorTests {

  // MARK: Lifecycle

  init() throws {
    let signingSecKey = SecKeyTestsHelper.createStaticPrivateKey()
    let representation = try #require(SecKeyCopyExternalRepresentation(signingSecKey, nil) as Data?)
    signingKey = try P256.Signing.PrivateKey(x963Representation: representation)
    detachedJWSSigningJWK = try JWK(from: SecKeyTestsHelper.getPublicKey(for: signingSecKey))

    let didResolverHelper = DidResolverHelperProtocolSpy()
    didResolverHelper.getJWKFromReturnValue = .Mock.validSample
    self.didResolverHelper = didResolverHelper

    Container.shared.didResolverHelper.register { didResolverHelper }

    validator = JWSSignatureValidator()
  }

  // MARK: Internal

  // MARK: Attached payload

  @Test
  func validate_resolvedKey_resolvesKeyIdentifierAndAccepts() async throws {
    try await validator.validate(jws)

    #expect(didResolverHelper.getJWKFromReceivedKid == jws.header.keyIdentifier)
  }

  @Test
  func validate_otherResolvedKey_throwsInvalidSignature() async throws {
    didResolverHelper.getJWKFromReturnValue = .Mock.invalidSample

    await #expect(throws: JWSSignatureValidatorError.invalidSignature) {
      try await validator.validate(jws)
    }
  }

  @Test
  func validate_unresolvableDid_throwsCannotResolveDid() async throws {
    didResolverHelper.getJWKFromThrowableError = TestingError.error

    await #expect(throws: JWSSignatureValidatorError.cannotResolveDid(TestingError.error)) {
      try await validator.validate(jws)
    }
  }

  @Test
  func validate_deactivatedDidDocument_throwsCannotResolveDid() async throws {
    didResolverHelper.getJWKFromThrowableError = DidResolverHelperError.didDocumentDeactivated

    await #expect(throws: JWSSignatureValidatorError.cannotResolveDid(DidResolverHelperError.didDocumentDeactivated)) {
      try await validator.validate(jws)
    }
  }

  @Test
  func validate_suppliedKey_acceptsWithoutResolvingDid() throws {
    try validator.validate(jws, with: .Mock.validSample)

    #expect(!didResolverHelper.getJWKFromCalled)
  }

  @Test
  func validate_suppliedOtherKey_throwsInvalidSignature() throws {
    #expect(throws: JWSSignatureValidatorError.invalidSignature) {
      try validator.validate(jws, with: .Mock.invalidSample)
    }
  }

  // MARK: Detached payload

  @Test
  func validate_detachedJWSSignedByResolvedKey_resolvesKeyIdentifierAndAccepts() async throws {
    didResolverHelper.getJWKFromReturnValue = detachedJWSSigningJWK
    let detachedJWS = try DetachedJWS.Mock.signed(over: payload, by: signingKey)

    try await validator.validate(detachedJWS, payload: payload)

    #expect(didResolverHelper.getJWKFromReceivedKid == DetachedJWS.Mock.keyIdentifier)
  }

  @Test
  func validate_detachedJWSOverTamperedPayload_throwsInvalidSignature() async throws {
    didResolverHelper.getJWKFromReturnValue = detachedJWSSigningJWK
    let detachedJWS = try DetachedJWS.Mock.signed(over: payload, by: signingKey)

    await #expect(throws: JWSSignatureValidatorError.invalidSignature) {
      try await validator.validate(detachedJWS, payload: Data(#"{"platform":"android"}"#.utf8))
    }
  }

  @Test
  func validate_detachedJWSSignedByAnotherKey_throwsInvalidSignature() async throws {
    didResolverHelper.getJWKFromReturnValue = detachedJWSSigningJWK
    let detachedJWS = try DetachedJWS.Mock.signed(over: payload, by: P256.Signing.PrivateKey())

    await #expect(throws: JWSSignatureValidatorError.invalidSignature) {
      try await validator.validate(detachedJWS, payload: payload)
    }
  }

  @Test
  func validate_detachedJWSWithUnresolvableDid_throwsCannotResolveDid() async throws {
    didResolverHelper.getJWKFromThrowableError = TestingError.error
    let detachedJWS = try DetachedJWS.Mock.signed(over: payload, by: signingKey)

    await #expect(throws: JWSSignatureValidatorError.cannotResolveDid(TestingError.error)) {
      try await validator.validate(detachedJWS, payload: payload)
    }
  }

  // MARK: Private

  private let validator: JWSSignatureValidator
  private let didResolverHelper: DidResolverHelperProtocolSpy
  private let signingKey: P256.Signing.PrivateKey
  private let detachedJWSSigningJWK: JWK
  private let jws = RegisteredClaimsJWT.Mock.sample
  private let payload = DetachedJWS.Mock.payload
}
