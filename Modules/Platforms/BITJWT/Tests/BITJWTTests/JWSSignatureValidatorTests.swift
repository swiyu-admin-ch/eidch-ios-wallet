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
    didResolverSpy.getJWKFromReturnValue = .Mock.validSample

    Container.shared.didResolverHelper.register { self.didResolverSpy }

    validator = JWSSignatureValidator()
  }

  func testValidate_validJws_argumentsPassed() async throws {
    _ = try await validator.validate(jwsMock)

    XCTAssertEqual(didResolverSpy.getJWKFromReceivedKid, jwsMock.header.keyIdentifier)
  }

  func testValidate_jwsWithOneValidPublicKey_doesNotThrow() async throws {
    didResolverSpy.getJWKFromReturnValue = .Mock.validSample

    do {
      try await validator.validate(jwsMock)
    } catch {
      XCTFail("Expected not to throw an error")
    }
  }

  func testValidate_jwsWithNoValidPublicKey_throwsInvalidSignature() async throws {
    didResolverSpy.getJWKFromReturnValue = .Mock.invalidSample

    do {
      try await validator.validate(jwsMock)
      XCTFail("Expected to throw an error")
    } catch {
      XCTAssertEqual(error as? JWSSignatureValidatorError, .invalidSignature)
    }
  }

  func testValidate_didResolverThrows_throwsError() async throws {
    didResolverSpy.getJWKFromThrowableError = TestingError.error

    do {
      _ = try await validator.validate(jwsMock)
      XCTFail("Expected to throw an error, but it did not.")
    } catch JWSSignatureValidatorError.cannotResolveDid(let error) {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testValidate_didDocumentDeactivated_throwsCannotResolveDid() async throws {
    didResolverSpy.getJWKFromThrowableError = DidResolverHelperError.didDocumentDeactivated

    do {
      try await validator.validate(jwsMock)
      XCTFail("Expected to throw an error")
    } catch JWSSignatureValidatorError.cannotResolveDid(let error) {
      XCTAssertEqual(error as? DidResolverHelperError, .didDocumentDeactivated)
    }
  }

  func testValidate_withSuppliedValidJwk_doesNotThrow() throws {
    XCTAssertNoThrow(try validator.validate(jwsMock, with: .Mock.validSample))
    XCTAssertNil(didResolverSpy.getJWKFromReceivedKid, "Supplying a JWK should bypass DID resolution")
  }

  func testValidate_withSuppliedInvalidJwk_throwsInvalidSignature() throws {
    XCTAssertThrowsError(try validator.validate(jwsMock, with: .Mock.invalidSample)) { error in
      XCTAssertEqual(error as? JWSSignatureValidatorError, .invalidSignature)
    }
  }

  // MARK: Private

  private let kid = "did:example:123456789#key-01"
  private let jwsMock = RegisteredClaimsJWT.Mock.sample

  private var didResolverSpy: DidResolverHelperProtocolSpy!

  private var validator: JWSSignatureValidator!
}
