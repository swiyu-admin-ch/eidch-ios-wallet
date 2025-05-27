// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITJWT
@testable import BITOca
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITSdJWTMocks
@testable import BITTestingCore

// MARK: - FetchVcSdJwtCredentialUseCaseTests

final class FetchVcSdJwtCredentialUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    success()
    useCase = FetchVcSdJwtCredentialUseCase()
  }

  func testExecute_success_returnsVcSdJwt() async throws {
    let credential = try await useCase.execute(for: fetchCredentialContextMock)

    XCTAssertEqual(credential.raw, vcSdJwtMock.raw)
    XCTAssertEqual(credential as? SdJWS<VcSdJwtPayload>, vcSdJwtMock)
  }

  func testExecute_success_argumentsPassed() async throws {
    let _ = try await useCase.execute(for: fetchCredentialContextMock)

    if let fetchArguments = repositorySpy.fetchCredentialFromCredentialRequestBodyAcccessTokenReceivedArguments {
      XCTAssertEqual(fetchArguments.url, fetchCredentialContextMock.credentialEndpoint)
      XCTAssertEqual(fetchArguments.acccessToken, fetchCredentialContextMock.accessToken)
      XCTAssertEqual(fetchArguments.credentialRequestBody.format, fetchCredentialContextMock.format)
      XCTAssertEqual(fetchArguments.credentialRequestBody.proof?.proofType, "jwt")
      XCTAssertEqual(fetchArguments.credentialRequestBody.proof?.jwt, Self.jwtStringMock)
    } else {
      XCTFail("fetchCredential no arguments received")
    }

    XCTAssertEqual(jwsEncoderMock.receivedKeyPair, fetchCredentialContextMock.keyPair)
    XCTAssertEqual(jwsEncoderMock.receivedValue?.audience, fetchCredentialContextMock.credentialIssuer)
    XCTAssertEqual(jwsEncoderMock.receivedValue?.nonce, fetchCredentialContextMock.accessToken.cNonce)
    XCTAssertEqual(jwsSignatureValidatorMock.validateJwsDidReceivedJws as? VcSdJwt, vcSdJwtMock)
    XCTAssertEqual(jwsSignatureValidatorMock.validateJwsDidReceivedDid, Self.issuerMock)
  }

  func testExecute_withoutHolderBinding_returnsVcSdJwt() async throws {
    let context = FetchCredentialContext.Mock.sampleVcSdJwtWithoutHolderBinding

    let credential = try await useCase.execute(for: context)

    XCTAssertEqual(credential.raw, vcSdJwtMock.raw)
    XCTAssertEqual(credential as? SdJWS<VcSdJwtPayload>, vcSdJwtMock)
  }

  func testExecute_withoutHolderBinding_argumentsPassed() async throws {
    let context = FetchCredentialContext.Mock.sampleVcSdJwtWithoutHolderBinding

    _ = try await useCase.execute(for: context)

    if let fetchArguments = repositorySpy.fetchCredentialFromCredentialRequestBodyAcccessTokenReceivedArguments {
      XCTAssertEqual(fetchArguments.url, fetchCredentialContextMock.credentialEndpoint)
      XCTAssertEqual(fetchArguments.acccessToken, fetchCredentialContextMock.accessToken)
      XCTAssertEqual(fetchArguments.credentialRequestBody.format, fetchCredentialContextMock.format)
      XCTAssertNil(fetchArguments.credentialRequestBody.proof)
    } else {
      XCTFail("fetchCredential no arguments received")
    }

    XCTAssertNil(jwsEncoderMock.receivedKeyPair)
    XCTAssertNil(jwsEncoderMock.receivedValue?.audience)
    XCTAssertNil(jwsEncoderMock.receivedValue?.nonce)
    XCTAssertEqual(jwsSignatureValidatorMock.validateJwsDidReceivedJws as? VcSdJwt, vcSdJwtMock)
  }

  func testExecute_proofEncodingFailure_throwsError() async throws {
    jwsEncoderMock.encodeUsingThrowableError = TestingError.error
    useCase = FetchVcSdJwtCredentialUseCase()

    do {
      _ = try await useCase.execute(for: fetchCredentialContextMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_fetchCredentialFailure_throwsError() async throws {
    repositorySpy.fetchCredentialFromCredentialRequestBodyAcccessTokenThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: fetchCredentialContextMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_credentialDecodingFailure_throwsError() async throws {
    sdJwsDecoderMock.throwingError = TestingError.error
    useCase = FetchVcSdJwtCredentialUseCase()

    do {
      _ = try await useCase.execute(for: fetchCredentialContextMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? FetchAnyVerifiableCredentialError, .validationFailed)
    }
  }

  func testExecute_validationReturnsFalse_throwsError() async throws {
    jwsSignatureValidatorMock.validateJwsDidReturnValue = false
    useCase = FetchVcSdJwtCredentialUseCase()

    do {
      _ = try await useCase.execute(for: fetchCredentialContextMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? FetchAnyVerifiableCredentialError, .validationFailed)
    }
  }

  func testExecute_validationFailure_throwsError() async throws {
    jwsSignatureValidatorMock.validateJwsDidThrowableError = TestingError.error
    useCase = FetchVcSdJwtCredentialUseCase()

    do {
      _ = try await useCase.execute(for: fetchCredentialContextMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_cannotResolveDid_throwsErrors() async throws {
    jwsSignatureValidatorMock.validateJwsDidThrowableError = JWSSignatureValidatorError.cannotResolveDid(TestingError.error)
    useCase = FetchVcSdJwtCredentialUseCase()

    do {
      _ = try await useCase.execute(for: fetchCredentialContextMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? FetchAnyVerifiableCredentialError, .unknownIssuer)
    }
  }

  // MARK: Private

  private static let jwtStringMock = "mockJwt"
  private static let jwtDataMock = jwtStringMock.data(using: .utf8)!
  private static let issuerMock = "did:tdw:example"

  private let vcSdJwtMock = VcSdJwtPayload.Mock.sample
  private let credentialResponseMock = CredentialResponse.Mock.sample
  private var fetchCredentialContextMock: FetchCredentialContext = .Mock.sampleVcSdJwt

  private var useCase = FetchVcSdJwtCredentialUseCase()
  private var jwsEncoderMock = JWSEncoderMock<JWTProofPayload>()
  private var repositorySpy = OpenIDRepositoryProtocolSpy()
  private var sdJwsDecoderMock = SdJWSDecoderMock<VcSdJwtPayload>()
  private var jwsSignatureValidatorMock = JWSSignatureValidatorMock()

  private func registerMocks() {
    jwsEncoderMock = JWSEncoderMock()
    repositorySpy = OpenIDRepositoryProtocolSpy()
    sdJwsDecoderMock = SdJWSDecoderMock()
    jwsSignatureValidatorMock = JWSSignatureValidatorMock()

    Container.shared.jwsEncoder.register { self.jwsEncoderMock }
    Container.shared.openIDRepository.register { self.repositorySpy }
    Container.shared.sdJwsDecoder.register { self.sdJwsDecoderMock }
    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidatorMock }
  }

  private func success() {
    jwsEncoderMock.encodeUsingReturnValue = Self.jwtDataMock
    repositorySpy.fetchCredentialFromCredentialRequestBodyAcccessTokenReturnValue = credentialResponseMock
    sdJwsDecoderMock.decodeReturnValue = vcSdJwtMock
    jwsSignatureValidatorMock.validateJwsDidReturnValue = true
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
