import Factory
import XCTest
@testable import BITCrypto
@testable import BITJWT
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional

final class JWSValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    jwsSignatureValidatorMock = JWSSignatureValidatorMock()
    jwsSignatureValidatorMock.validateIssuerDidReturnValue = true

    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidatorMock }
    Container.shared.currentDate.register { self.dateMock }

    validator = JWSValidator()
  }

  func testValidate_validJws_argumentsPassed() async throws {
    _ = try await validator.validate(jwsMock, issuerDid: issuer)

    XCTAssertEqual(jwsSignatureValidatorMock.validateIssuerDidCallsCount, 1)
    XCTAssertEqual(jwsSignatureValidatorMock.validateIssuerDidReceivedJws, jwsMock)
    XCTAssertEqual(jwsSignatureValidatorMock.validateIssuerDidReceivedDid, issuer)
  }

  func testValidate_validActivatedAtAndExpiredAt_returnsTrue() async throws {
    let jws = Self.createJws(from: JWTRegisteredPayload(expiredAt: dateMock, activatedAt: dateMock))

    let result = try await validator.validate(jws, issuerDid: issuer)

    XCTAssertTrue(result)
  }

  func testValidate_validActivatedAtAndInvalidExpiredAt_returnsFalse() async throws {
    let jws = Self.createJws(from: JWTRegisteredPayload(expiredAt: dateMock.addingTimeInterval(-1), activatedAt: dateMock))

    let result = try await validator.validate(jws, issuerDid: issuer)

    XCTAssertEqual(jwsSignatureValidatorMock.validateIssuerDidCallsCount, 0)
    XCTAssertFalse(result)
  }

  func testValidate_invalidActivatedAtAndValidExpiredAt_returnsFalse() async throws {
    let jws = Self.createJws(from: JWTRegisteredPayload(expiredAt: dateMock, activatedAt: dateMock.addingTimeInterval(1)))

    let result = try await validator.validate(jws, issuerDid: issuer)

    XCTAssertEqual(jwsSignatureValidatorMock.validateIssuerDidCallsCount, 0)
    XCTAssertFalse(result)
  }

  func testValidate_invalidActivatedAtAndInvalidExpiredAt_returnsFalse() async throws {
    let jws = Self.createJws(from: JWTRegisteredPayload(expiredAt: dateMock.addingTimeInterval(-1), activatedAt: dateMock.addingTimeInterval(1)))

    let result = try await validator.validate(jws, issuerDid: issuer)

    XCTAssertFalse(result)
  }

  func testValidate_validActivatedAt_returnsTrue() async throws {
    let jws = Self.createJws(from: JWTRegisteredPayload(activatedAt: dateMock))

    let result = try await validator.validate(jws, issuerDid: issuer)

    XCTAssertTrue(result)
  }

  func testValidate_validActivatedAtWithBuffer_returnsTrue() async throws {
    let jws = Self.createJws(from: JWTRegisteredPayload(activatedAt: dateMock.addingTimeInterval(10)))

    let result = try await validator.validate(jws, issuerDid: issuer, activationBuffer: 10)

    XCTAssertTrue(result)
  }

  func testValidate_invalidActivatedAt_returnsFalse() async throws {
    let jws = Self.createJws(from: JWTRegisteredPayload(activatedAt: dateMock.addingTimeInterval(1)))

    let result = try await validator.validate(jws, issuerDid: issuer)

    XCTAssertFalse(result)
  }

  func testValidate_invalidActivatedAtWithBuffer_returnsTrue() async throws {
    let jws = Self.createJws(from: JWTRegisteredPayload(activatedAt: dateMock.addingTimeInterval(9)))

    let result = try await validator.validate(jws, issuerDid: issuer, activationBuffer: 10)

    XCTAssertTrue(result)
  }

  func testValidate_validExpiredAt_returnsTrue() async throws {
    let jws = Self.createJws(from: JWTRegisteredPayload(expiredAt: dateMock))

    let result = try await validator.validate(jws, issuerDid: issuer)

    XCTAssertTrue(result)
  }

  func testValidate_invalidExpiredAt_returnsFalse() async throws {
    let jws = Self.createJws(from: JWTRegisteredPayload(expiredAt: dateMock.addingTimeInterval(-1)))

    let result = try await validator.validate(jws, issuerDid: issuer)

    XCTAssertFalse(result)
  }

  func testValidate_noDatesButValidSignature_returnsTrue() async throws {
    let jws = Self.createJws(from: JWTRegisteredPayload())

    let result = try await validator.validate(jws, issuerDid: issuer)

    XCTAssertTrue(result)
  }

  func testValidate_jwsSignatureValidatorReturnsFalse_returnsFalse() async throws {
    jwsSignatureValidatorMock.validateIssuerDidReturnValue = false

    let result = try await validator.validate(jwsMock, issuerDid: issuer)

    XCTAssertFalse(result)
  }

  func testValidate_jwsSignatureValidatorThrows_throwsError() async throws {
    jwsSignatureValidatorMock.validateIssuerDidThrowableError = TestingError.error

    do {
      _ = try await validator.validate(jwsMock, issuerDid: issuer)
      XCTFail("Expected to throw an error, but it did not.")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let issuer = "issuer"
  private let jwsMock = createJws(from: JWTRegisteredPayload())
  private let dateMock = Date()

  private var jwsSignatureValidatorMock: JWSSignatureValidatorMock<JWTRegisteredPayload>!

  private var validator: JWSValidator!

  private static func createJws(from payload: JWTRegisteredPayload) -> JWS<JWTRegisteredPayload> {
    JWS(payload: payload, rawPayload: "rawPayload", rawJWS: "rawJWS", header: JWSHeader(algorithm: JWTAlgorithm.ES256))
  }
}

// swiftlint:enable all
