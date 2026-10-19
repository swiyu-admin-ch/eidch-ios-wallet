import BITJWT
import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITAppInfo

@Suite(.container)
struct VersionEnforcementSignatureValidatorTests {

  // MARK: Lifecycle

  init() {
    let didResolverHelper = DidResolverHelperProtocolSpy()
    didResolverHelper.getDidFromReturnValue = Self.versioningServiceDid
    self.didResolverHelper = didResolverHelper

    let signatureValidator = JWSSignatureValidatorMock<RegisteredClaimsJWT>()
    self.signatureValidator = signatureValidator

    Container.shared.didResolverHelper.register { didResolverHelper }
    Container.shared.jwsSignatureValidator.register { signatureValidator }
    Container.shared.versionEnforcementTrustedDids.register { [Self.versioningServiceDid] }

    validator = VersionEnforcementSignatureValidator()
  }

  // MARK: Internal

  @Test
  func validate_trustedSigner_forwardsDetachedJWSAndPayload() async throws {
    let detachedJWS = try DetachedJWS.Mock.rawJWS(keyIdentifier: Self.versioningServiceKeyIdentifier)

    try await validator.validate(Self.payload, detachedJWS: detachedJWS)

    let arguments = try #require(await signatureValidator.validateDetachedJWSReceivedArguments)
    #expect(arguments.detachedJWS.rawJWS == detachedJWS)
    #expect(arguments.payload == Self.payload)
    #expect(didResolverHelper.getDidFromReceivedKid == Self.versioningServiceKeyIdentifier)
  }

  @Test
  func validate_untrustedSigner_throwsUntrustedSignerWithoutValidatingSignature() async throws {
    didResolverHelper.getDidFromReturnValue = "did:webvh:scid:identifier-reg.example.com:api:v1:did:untrusted"
    let detachedJWS = try DetachedJWS.Mock.rawJWS(keyIdentifier: Self.versioningServiceKeyIdentifier)

    await #expect(throws: VersionEnforcementSignatureValidatorError.untrustedSigner) {
      try await validator.validate(Self.payload, detachedJWS: detachedJWS)
    }
    #expect(await !signatureValidator.validateDetachedJWSCalled)
  }

  @Test
  func validate_malformedDetachedJWS_throwsDecodingError() async throws {
    await #expect(throws: DecodingError.self) {
      try await validator.validate(Self.payload, detachedJWS: "not-a-detached-jws")
    }
    #expect(!didResolverHelper.getDidFromCalled)
  }

  @Test
  func validate_algorithmOutsideSupportedAlgorithms_throwsUnsupportedAlgorithmWithoutResolvingDid() async throws {
    let detachedJWS = try DetachedJWS.Mock.rawJWS(algorithm: "ES384", keyIdentifier: Self.versioningServiceKeyIdentifier)

    await #expect(throws: VersionEnforcementSignatureValidatorError.unsupportedAlgorithm) {
      try await validator.validate(Self.payload, detachedJWS: detachedJWS)
    }
    #expect(!didResolverHelper.getDidFromCalled)
  }

  @Test
  func validate_invalidSignature_throwsSignatureValidatorError() async throws {
    signatureValidator.validateDetachedJWSThrowableError = JWSSignatureValidatorError.invalidSignature
    let detachedJWS = try DetachedJWS.Mock.rawJWS(keyIdentifier: Self.versioningServiceKeyIdentifier)

    await #expect(throws: JWSSignatureValidatorError.invalidSignature) {
      try await validator.validate(Self.payload, detachedJWS: detachedJWS)
    }
  }

  // MARK: Private

  private static let payload = Data(#"{"platform":"ios"}"#.utf8)

  private static let versioningServiceDid = "did:webvh:scid:identifier-reg.example.com:api:v1:did:versioning"
  private static let versioningServiceKeyIdentifier = "\(versioningServiceDid)#version-assertion-1"

  private let validator: VersionEnforcementSignatureValidator
  private let didResolverHelper: DidResolverHelperProtocolSpy
  private let signatureValidator: JWSSignatureValidatorMock<RegisteredClaimsJWT>

}
