// swiftlint:disable implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

final class RequestObjectValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    success()
    validator = RequestObjectValidator()
  }

  func testValidate_validJws_validates() async throws {
    let jws = RequestObjectJWS.Mock.sample

    do {
      try await validator.validate(jws)
    } catch {
      XCTFail("Expected no throw, but got: \(error)")
    }
    XCTAssertEqual(requestObjectEncryptionValidatorSpy.validateCallsCount, 1)
    XCTAssertEqual(jwsValidatorMock.validateActivationBufferCallsCount, 1)
  }

  func testValidate_withoutHolderBindingAndWithState_validates() async throws {
    let jws = RequestObjectJWS.Mock.sample

    do {
      try await validator.validate(jws)
    } catch {
      XCTFail("Expected no throw, but got: \(error)")
    }
  }

  func testValidate_didPrefixClientIdMatchesKid_validates() async {
    let jws = RequestObjectJWS.Mock.clientIdDIDPrefix

    do {
      try await validator.validate(jws)
    } catch {
      XCTFail("Expected no throw, but got: \(error)")
    }
  }

  func testValidateJWS_noAudience_validates() async {
    let jws = RequestObjectJWS.Mock.noAudience

    do {
      try await validator.validate(jws)
    } catch {
      XCTFail("Expected no throw, but got: \(error)")
    }
  }

  func testValidate_withUnsupportedAlgorithm_throwsInvalidJWSSignatureAlgorithm() async {
    let jws = RequestObjectJWS.Mock.unsupportedAlgorithm

    await XCTAssertThrowsErrorAsync(try await validator.validate(jws)) { error in
      XCTAssertEqual(error as? RequestObjectValidationError, .invalidJWSSignatureAlgorithm)
    }
  }

  func testValidate_withClientIdMismatch_throwsInvalidClientId() async {
    let jws = RequestObjectJWS.Mock.clientIdMismatch

    await XCTAssertThrowsErrorAsync(try await validator.validate(jws)) { error in
      XCTAssertEqual(error as? RequestObjectValidationError, .invalidClientId)
    }
  }

  func testValidate_kidMismatch_throwsInvalidClientId() async {
    didResolverSpy.getDidFromReturnValue = "did:example:mismatch"
    let jws = RequestObjectJWS.Mock.kidMismatch

    await XCTAssertThrowsErrorAsync(try await validator.validate(jws)) { error in
      XCTAssertEqual(error as? RequestObjectValidationError, .invalidClientId)
    }
  }

  func testValidate_clientIdNotADid_throwsInvalidClientId() async {
    let jws = RequestObjectJWS.Mock.clientIdNotADid

    await XCTAssertThrowsErrorAsync(try await validator.validate(jws)) { error in
      XCTAssertEqual(error as? RequestObjectValidationError, .invalidClientId)
    }
  }

  func testValidate_jwsValidatorThrows_rethrowsError() async {
    let jws = RequestObjectJWS.Mock.sample
    jwsValidatorMock.validateThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await validator.validate(jws)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testValidate_requestObjectEncryptionValidatorThrows_rethrowsError() async {
    let jws = RequestObjectJWS.Mock.sample
    requestObjectEncryptionValidatorSpy.validateThrowableError = RequestObjectEncryptionError.missingClientMetadata

    await XCTAssertThrowsErrorAsync(try await validator.validate(jws)) { error in
      XCTAssertEqual(error as? RequestObjectEncryptionError, .missingClientMetadata)
    }
  }

  func testValidate_withUnsupportedResponseType_throwsInvalidResponseType() async throws {
    let jws = RequestObjectJWS.Mock.unsupportedResponseType

    await XCTAssertThrowsErrorAsync(try await validator.validate(jws)) { error in
      XCTAssertEqual(error as? RequestObjectValidationError, .invalidResponseType)
    }
  }

  func testValidate_withUnsupportedClientId_throwsInvalidClientId() async throws {
    let jws = RequestObjectJWS.Mock.unsupportedClientId

    await XCTAssertThrowsErrorAsync(try await validator.validate(jws)) { error in
      XCTAssertEqual(error as? RequestObjectValidationError, .invalidClientId)
    }
  }

  func testValidate_withTransactionData_throwsTransactionDataNotSupported() async throws {
    let jws = RequestObjectJWS.Mock.transactionData

    await XCTAssertThrowsErrorAsync(try await validator.validate(jws)) { error in
      XCTAssertEqual(error as? RequestObjectValidationError, .transactionDataNotSupported)
    }
  }

  func testValidate_withoutHolderBindingAndWithoutState_throwsInvalidState() async throws {
    let jws = RequestObjectJWS.Mock.missingState

    await XCTAssertThrowsErrorAsync(try await validator.validate(jws)) { error in
      XCTAssertEqual(error as? RequestObjectValidationError, .invalidState)
    }
  }

  func testValidate_audienceIssuerMismatch_throwsInvalidAudience() async {
    let jws = RequestObjectJWS.Mock.audienceIssuerMismatch

    await XCTAssertThrowsErrorAsync(try await validator.validate(jws)) { error in
      XCTAssertEqual(error as? RequestObjectValidationError, .invalidAudience)
    }
  }

  // MARK: Private

  private var validator = RequestObjectValidator()
  private var jwsValidatorMock: JWSValidatorMock<RequestObjectJWT>!
  private var didResolverSpy: DidResolverHelperProtocolSpy!
  private var requestObjectEncryptionValidatorSpy: RequestObjectEncryptionValidatorProtocolSpy!

  private func registerMocks() {
    jwsValidatorMock = JWSValidatorMock()
    didResolverSpy = DidResolverHelperProtocolSpy()
    requestObjectEncryptionValidatorSpy = RequestObjectEncryptionValidatorProtocolSpy()

    Container.shared.jwsValidator.register { self.jwsValidatorMock }
    Container.shared.didResolverHelper.register { self.didResolverSpy }
    Container.shared.requestObjectEncryptionValidator.register { self.requestObjectEncryptionValidatorSpy }
  }

  private func success() {
    didResolverSpy.getDidFromReturnValue = "did:example:12345"
  }
}
