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
    _ = try await validator.validate(jwsMock, did: issuer)

    XCTAssertEqual(didResolverSpy.getJWKSFromKeyIdentifierReceivedArguments?.did, issuer)
    XCTAssertEqual(didResolverSpy.getJWKSFromKeyIdentifierReceivedArguments?.keyIdentifier, jwsMock.header.keyIdentifier)
  }

  func testValidate_jwsWithOneValidPublicKey_returnsTrue() async throws {
    didResolverSpy.getJWKSFromKeyIdentifierReturnValue = [.Mock.validSample]

    let result = try await validator.validate(jwsMock, did: issuer)

    XCTAssertTrue(result)
  }

  func testValidate_jwsWithMultipleJWKsOneValid_returnsTrue() async throws {
    didResolverSpy.getJWKSFromKeyIdentifierReturnValue = [.Mock.invalidSample, .Mock.invalidSample, .Mock.validSample]

    let result = try await validator.validate(jwsMock, did: issuer)

    XCTAssertTrue(result)
  }

  func testValidate_jwsWithNoValidPublicKey_returnsFalse() async throws {
    didResolverSpy.getJWKSFromKeyIdentifierReturnValue = [.Mock.invalidSample, .Mock.invalidSample, .Mock.invalidSample]

    let result = try await validator.validate(jwsMock, did: issuer)

    XCTAssertFalse(result)
  }

  func testValidate_jwsWithNoPublicKey_returnFalse() async throws {
    didResolverSpy.getJWKSFromKeyIdentifierReturnValue = []

    let result = try await validator.validate(jwsMock, did: issuer)

    XCTAssertFalse(result)
  }

  func testValidate_didResolverThrows_throwsError() async throws {
    didResolverSpy.getJWKSFromKeyIdentifierThrowableError = TestingError.error

    do {
      _ = try await validator.validate(jwsMock, did: issuer)
      XCTFail("Expected to throw an error, but it did not.")
    } catch JWSSignatureValidatorError.cannotResolveDid(let error) {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testValidate_didDocumentDeactivated_returnsFalse() async throws {
    didResolverSpy.getJWKSFromKeyIdentifierThrowableError = DidResolverHelperError.didDocumentDeactivated

    let result = try await validator.validate(jwsMock, did: issuer)

    XCTAssertFalse(result)
  }

  // MARK: Private

  private let issuer = "did:example:123456789"
  private let kid = "did:example:123456789#key-01"
  private let jwsMock = JWTRegisteredPayload.Mock.sample

  private var didResolverSpy: DidResolverHelperProtocolSpy!

  private var validator: JWSSignatureValidator!
}

// swiftlint:enable all
