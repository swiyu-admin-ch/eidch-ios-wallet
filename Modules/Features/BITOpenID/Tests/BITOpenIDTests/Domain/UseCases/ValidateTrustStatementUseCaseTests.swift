import Factory
import XCTest
@testable import BITCrypto
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

final class ValidateTrustStatementUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    jwsSignatureValidator = JWSSignatureValidatorMock()

    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidator }
    Container.shared.trustRegistryRepository.register { self.trustRegistryRepository }
    Container.shared.tokenStatusListValidator.register { self.tokenStatusListValidator }

    useCase = ValidateTrustStatementUseCase()
  }

  func testValidateTrustStatement() async throws {
    trustRegistryRepository.getTrustedDidsReturnValue = trustedDids
    jwsSignatureValidator.validateJwsDidReturnValue = true
    tokenStatusListValidator.validateIssuerReturnValue = .valid

    let result = await useCase.execute(trustStatementMock)

    XCTAssertTrue(result)
    XCTAssertTrue(trustRegistryRepository.getTrustedDidsCalled)
    XCTAssertEqual(jwsSignatureValidator.validateJwsDidReceivedJws?.rawJWS, trustStatementMock.rawJWS)
    XCTAssertEqual(jwsSignatureValidator.validateJwsDidReceivedDid, trustStatementMock.payload.issuer)
    XCTAssertEqual(tokenStatusListValidator.validateIssuerReceivedArguments?.anyStatus.type, trustStatementMock.payload.statusList.type)
  }

  func testValidateNotTrustedStatement() async throws {
    trustRegistryRepository.getTrustedDidsReturnValue = []
    jwsSignatureValidator.validateJwsDidReturnValue = true

    let result = await useCase.execute(trustStatementMock)

    XCTAssertFalse(result)
    XCTAssertTrue(trustRegistryRepository.getTrustedDidsCalled)
  }

  func testValidateNotValidSignatureTrustStatement() async throws {
    trustRegistryRepository.getTrustedDidsReturnValue = trustedDids
    jwsSignatureValidator.validateJwsDidReturnValue = false

    let result = await useCase.execute(trustStatementMock)

    XCTAssertFalse(result)
    XCTAssertTrue(trustRegistryRepository.getTrustedDidsCalled)
    XCTAssertEqual(jwsSignatureValidator.validateJwsDidReceivedJws?.rawJWS, trustStatementMock.rawJWS)
    XCTAssertEqual(jwsSignatureValidator.validateJwsDidReceivedDid, trustStatementMock.payload.issuer)
  }

  func testValidateValidatorThrowsTrustStatement() async throws {
    trustRegistryRepository.getTrustedDidsReturnValue = trustedDids
    jwsSignatureValidator.validateJwsDidThrowableError = TestingError.error

    let result = await useCase.execute(trustStatementMock)

    XCTAssertFalse(result)
    XCTAssertTrue(trustRegistryRepository.getTrustedDidsCalled)
    XCTAssertEqual(jwsSignatureValidator.validateJwsDidReceivedJws?.rawJWS, trustStatementMock.rawJWS)
    XCTAssertEqual(jwsSignatureValidator.validateJwsDidReceivedDid, trustStatementMock.payload.issuer)
  }

  func testValidateTrustStatementWithNotValidStatus() async throws {
    jwsSignatureValidator.validateJwsDidReturnValue = true
    trustRegistryRepository.getTrustedDidsReturnValue = trustedDids
    tokenStatusListValidator.validateIssuerReturnValue = .revoked

    let result = await useCase.execute(trustStatementMock)

    XCTAssertFalse(result)
    XCTAssertTrue(trustRegistryRepository.getTrustedDidsCalled)
    XCTAssertEqual(jwsSignatureValidator.validateJwsDidReceivedJws?.rawJWS, trustStatementMock.rawJWS)
    XCTAssertEqual(jwsSignatureValidator.validateJwsDidReceivedDid, trustStatementMock.payload.issuer)
    XCTAssertEqual(tokenStatusListValidator.validateIssuerReceivedArguments?.issuer, trustStatementMock.payload.issuer)
    XCTAssertEqual(tokenStatusListValidator.validateIssuerReceivedArguments?.anyStatus.type, trustStatementMock.payload.statusList.type)
  }

  // MARK: Private

  // swiftlint:disable all
  private var jwsSignatureValidator = JWSSignatureValidatorMock()
  private var useCase: ValidateTrustStatementUseCase!
  private var trustRegistryRepository = TrustRegistryRepositoryProtocolSpy()
  private var tokenStatusListValidator = AnyStatusCheckValidatorProtocolSpy()
  private let trustStatementMock: TrustStatement = TrustStatementPayload.Mock.validSample
  // swiftlint:enable all

  private let trustedDids: [String] = [
    "did:tdw:another-example",
    TrustStatementPayload.Mock.validSamplePayload.issuer,
  ]

}
