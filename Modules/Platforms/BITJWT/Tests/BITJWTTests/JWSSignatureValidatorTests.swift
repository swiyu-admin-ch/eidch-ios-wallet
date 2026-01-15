import Factory
import XCTest
@testable import BITCrypto
@testable import BITJWT
@testable import BITTestingCore

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional

final class JWSSignatureValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    didResolverSpy = DidResolverHelperProtocolSpy()
    didResolverSpy.getJWKSFromKeyIdentifierReturnValue = [.Mock.validSample]

    Container.shared.didResolverHelper.register { self.didResolverSpy }

    validator = JWSSignatureValidator()
  }

  func testValidate_validJws_argumentsPassed() async throws {
    _ = try await validator.validate(jwsMock, issuerDid: issuer)

    XCTAssertEqual(didResolverSpy.getJWKSFromKeyIdentifierReceivedArguments?.did, issuer)
    XCTAssertEqual(didResolverSpy.getJWKSFromKeyIdentifierReceivedArguments?.keyIdentifier, jwsMock.header.keyIdentifier)
  }

  func testValidate_jwsWithOneValidPublicKey_doesNotThrow() async throws {
    didResolverSpy.getJWKSFromKeyIdentifierReturnValue = [.Mock.validSample]

    do {
      try await validator.validate(jwsMock, issuerDid: issuer)
    } catch {
      XCTFail("Expected not to throw an error")
    }
  }

  func testValidate_jwsWithMultipleJWKsOneValid_doesNotThrow() async throws {
    didResolverSpy.getJWKSFromKeyIdentifierReturnValue = [.Mock.invalidSample, .Mock.invalidSample, .Mock.validSample]

    do {
      try await validator.validate(jwsMock, issuerDid: issuer)
    } catch {
      XCTFail("Expected not to throw an error")
    }
  }

  func testValidate_jwsWithNoValidPublicKey_throwsInvalidSignature() async throws {
    didResolverSpy.getJWKSFromKeyIdentifierReturnValue = [.Mock.invalidSample, .Mock.invalidSample, .Mock.invalidSample]

    do {
      try await validator.validate(jwsMock, issuerDid: issuer)
      XCTFail("Expected to throw an error")
    } catch {
      XCTAssertEqual(error as? JWSSignatureValidatorError, .invalidSignature)
    }
  }

  func testValidate_jwsWithNoPublicKey_throwsInvalidSignature() async throws {
    didResolverSpy.getJWKSFromKeyIdentifierReturnValue = []

    do {
      try await validator.validate(jwsMock, issuerDid: issuer)
      XCTFail("Expected to throw an error")
    } catch {
      XCTAssertEqual(error as? JWSSignatureValidatorError, .invalidSignature)
    }
  }

  func testValidate_didResolverThrows_throwsError() async throws {
    didResolverSpy.getJWKSFromKeyIdentifierThrowableError = TestingError.error

    do {
      _ = try await validator.validate(jwsMock, issuerDid: issuer)
      XCTFail("Expected to throw an error, but it did not.")
    } catch JWSSignatureValidatorError.cannotResolveDid(let error) {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testValidate_didDocumentDeactivated_throwsInvalidSignature() async throws {
    didResolverSpy.getJWKSFromKeyIdentifierThrowableError = DidResolverHelperError.didDocumentDeactivated

    do {
      try await validator.validate(jwsMock, issuerDid: issuer)
      XCTFail("Expected to throw an error")
    } catch {
      XCTAssertEqual(error as? JWSSignatureValidatorError, .invalidSignature)
    }
  }

  // MARK: Private

  private let issuer = "did:example:123456789"
  private let kid = "did:example:123456789#key-01"
  private let jwsMock = RegisteredClaimsJWT.Mock.sample

  private var didResolverSpy: DidResolverHelperProtocolSpy!

  private var validator: JWSSignatureValidator!
}

// swiftlint:enable all
