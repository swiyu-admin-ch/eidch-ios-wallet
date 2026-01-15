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

    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidatorMock }
    Container.shared.currentDate.register { self.dateMock }

    validator = JWSValidator()
  }

  func testValidate_validJws_argumentsPassed() async throws {
    try await validator.validate(jwsMock)

    XCTAssertEqual(jwsSignatureValidatorMock.validateIssuerDidCallsCount, 1)
    XCTAssertEqual(jwsSignatureValidatorMock.validateIssuerDidReceivedJws, jwsMock)
    XCTAssertEqual(jwsSignatureValidatorMock.validateIssuerDidReceivedDid, didIssuer)
  }

  func testValidate_validActivatedAtAndExpiredAt_doesNotThrow() async throws {
    let jws = Self.createJws(from: RegisteredClaimsJWT(expiredAt: dateMock, activatedAt: dateMock))

    do {
      try await validator.validate(jws)
    } catch {
      XCTFail("Expected to not to throw.")
    }
  }

  func testValidate_validActivatedAtAndInvalidExpiredAt_throwsExpired() async throws {
    let jws = Self.createJws(from: RegisteredClaimsJWT(expiredAt: dateMock.addingTimeInterval(-1), activatedAt: dateMock))

    do {
      try await validator.validate(jws)
      XCTFail("Expected to throw.")
    } catch {
      XCTAssertEqual(error as? JWSValidatorError, .expired)
    }

    XCTAssertEqual(jwsSignatureValidatorMock.validateIssuerDidCallsCount, 0)
  }

  func testValidate_invalidActivatedAtAndValidExpiredAt_throwsNotYetActivated() async throws {
    let jws = Self.createJws(from: RegisteredClaimsJWT(expiredAt: dateMock, activatedAt: dateMock.addingTimeInterval(1)))

    do {
      try await validator.validate(jws)
      XCTFail("Expected to throw.")
    } catch {
      XCTAssertEqual(error as? JWSValidatorError, .notYetActivated)
    }

    XCTAssertEqual(jwsSignatureValidatorMock.validateIssuerDidCallsCount, 0)
  }

  func testValidate_invalidActivatedAtAndInvalidExpiredAt_throwsNotYetActivated() async throws {
    let jws = Self.createJws(from: RegisteredClaimsJWT(expiredAt: dateMock.addingTimeInterval(-1), activatedAt: dateMock.addingTimeInterval(1)))

    do {
      try await validator.validate(jws)
      XCTFail("Expected to throw.")
    } catch {
      XCTAssertEqual(error as? JWSValidatorError, .notYetActivated)
    }
  }

  func testValidate_validActivatedAt_doesNotThrow() async throws {
    let jws = Self.createJws(from: RegisteredClaimsJWT(activatedAt: dateMock))

    do {
      try await validator.validate(jws)
    } catch {
      XCTFail("Expected not to throw.")
    }
  }

  func testValidate_validActivatedAtWithBuffer_doesNotThrow() async throws {
    let jws = Self.createJws(from: RegisteredClaimsJWT(activatedAt: dateMock.addingTimeInterval(10)))

    do {
      try await validator.validate(jws, activationBuffer: 10)
    } catch {
      XCTFail("Expected not to throw.")
    }
  }

  func testValidate_invalidActivatedAt_throwsNotYetActivated() async throws {
    let jws = Self.createJws(from: RegisteredClaimsJWT(activatedAt: dateMock.addingTimeInterval(1)))

    do {
      try await validator.validate(jws)
      XCTFail("Expected to throw.")
    } catch {
      XCTAssertEqual(error as? JWSValidatorError, .notYetActivated)
    }
  }

  func testValidate_invalidActivatedAtWithBuffer_doesNotThrow() async throws {
    let jws = Self.createJws(from: RegisteredClaimsJWT(activatedAt: dateMock.addingTimeInterval(9)))

    do {
      try await validator.validate(jws, activationBuffer: 10)
    } catch {
      XCTFail("Expected not to throw.")
    }
  }

  func testValidate_validIssuedAt_doesNotThrow() async throws {
    let jws = Self.createJws(from: RegisteredClaimsJWT(issuedAt: dateMock.addingTimeInterval(-1)))

    do {
      try await validator.validate(jws)
    } catch {
      XCTFail("Expected not to throw.")
    }
  }

  func testValidate_invalidIssuedAt_throwsIssuedAtInFuture() async throws {
    let jws = Self.createJws(from: RegisteredClaimsJWT(issuedAt: dateMock.addingTimeInterval(1)))

    do {
      try await validator.validate(jws)
      XCTFail("Expected to throw.")
    } catch {
      XCTAssertEqual(error as? JWSValidatorError, .issuedAtInFuture)
    }

    XCTAssertEqual(jwsSignatureValidatorMock.validateIssuerDidCallsCount, 0)
  }

  func testValidate_validIssuedAtWithBuffer_doesNotThrow() async throws {
    let jws = Self.createJws(from: RegisteredClaimsJWT(issuedAt: dateMock.addingTimeInterval(9)))

    do {
      try await validator.validate(jws, activationBuffer: 10)
    } catch {
      XCTFail("Expected not to throw.")
    }
  }

  func testValidate_validExpiredAt_doesNotThrow() async throws {
    let jws = Self.createJws(from: RegisteredClaimsJWT(expiredAt: dateMock))

    do {
      try await validator.validate(jws)
    } catch {
      XCTFail("Expected not to throw.")
    }
  }

  func testValidate_invalidExpiredAt_throwsExpired() async throws {
    let jws = Self.createJws(from: RegisteredClaimsJWT(expiredAt: dateMock.addingTimeInterval(-1)))

    do {
      try await validator.validate(jws)
      XCTFail("Expected to throw.")
    } catch {
      XCTAssertEqual(error as? JWSValidatorError, .expired)
    }
  }

  func testValidate_noDatesButValidSignature_doesNotThrow() async throws {
    let jws = Self.createJws(from: RegisteredClaimsJWT())

    do {
      try await validator.validate(jws)
    } catch {
      XCTFail("Expected not to throw.")
    }
  }

  func testValidate_jwsSignatureValidatorThrows_throws() async throws {
    jwsSignatureValidatorMock.validateIssuerDidThrowableError = TestingError.error

    do {
      try await validator.validate(jwsMock)
      XCTFail("Expected to throw.")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testValidate_issuerKidMismatch_throwsInvalidKeyIdentifier() async throws {
    let header = JWSHeader(algorithm: JWTAlgorithm.ES256, keyIdentifier: "did:tdw:example.com-mismatch#key-id")
    let jws = JWS(payload: RegisteredClaimsJWT(issuer: didIssuer), rawPayload: "rawPayload", rawJWS: "rawJWS", header: header)

    do {
      try await validator.validate(jws)
      XCTFail("Expected to throw.")
    } catch {
      XCTAssertEqual(error as? JWSValidatorError, .invalidKeyIdentifier)
    }

    XCTAssertEqual(jwsSignatureValidatorMock.validateIssuerDidCallsCount, 0)
  }

  // MARK: Private

  private let didIssuer = "did:tdw:example.com"
  private let jwsMock = createJws(from: RegisteredClaimsJWT(issuer: "did:tdw:example.com"))
  private let dateMock = Date()

  private var jwsSignatureValidatorMock: JWSSignatureValidatorMock<RegisteredClaimsJWT>!

  private var validator: JWSValidator!

  private static func createJws(from payload: RegisteredClaimsJWT) -> JWS<RegisteredClaimsJWT> {
    JWS(payload: payload, rawPayload: "rawPayload", rawJWS: "rawJWS", header: JWSHeader(algorithm: JWTAlgorithm.ES256, keyIdentifier: "did:tdw:example.com#key-id"))
  }
}

// swiftlint:enable all
