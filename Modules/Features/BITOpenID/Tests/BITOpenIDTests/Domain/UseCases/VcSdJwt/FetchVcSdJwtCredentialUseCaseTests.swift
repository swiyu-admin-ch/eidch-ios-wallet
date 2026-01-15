import Factory
import XCTest
@testable import BITJWT
@testable import BITOca
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITSdJWTMocks
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

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
    let result = try await useCase.execute(for: fetchCredentialContextMock)

    if case .credential(let credential) = result {
      XCTAssertEqual(credential.raw, vcSdJWSMock.raw)
      XCTAssertEqual(credential as? SdJWS<VcSdJwt>, vcSdJWSMock)
    }
  }

  func testExecute_success_returnsDeferredCredential() async throws {
    repositorySpy.fetchCredentialWithCredentialRequestReturnValue = .deferred(mockDeferredCrendentialRequest)

    let result = try await useCase.execute(for: fetchCredentialContextMock)

    if case .deferred(let deferredCrendentialRequest) = result {
      XCTAssertEqual(deferredCrendentialRequest.transactionId, mockDeferredCrendentialRequest.transactionId)
      XCTAssertEqual(deferredCrendentialRequest.accessToken, mockDeferredCrendentialRequest.accessToken)
      XCTAssertEqual(deferredCrendentialRequest.endpoint, mockDeferredCrendentialRequest.endpoint)
      XCTAssertEqual(deferredCrendentialRequest.format, mockDeferredCrendentialRequest.format)
      XCTAssertEqual(deferredCrendentialRequest.interval, mockDeferredCrendentialRequest.interval)
      XCTAssertEqual(jwsSignatureValidatorMock.validateIssuerDidCallsCount, 0)
    }
  }

  func testExecute_success_argumentsPassed() async throws {
    _ = try await useCase.execute(for: fetchCredentialContextMock)

    if let fetchArguments = repositorySpy.fetchCredentialWithCredentialRequestReceivedArguments {
      XCTAssertEqual(fetchArguments.context.credentialEndpoint, fetchCredentialContextMock.credentialEndpoint)
      XCTAssertEqual(fetchArguments.context.accessToken, fetchCredentialContextMock.accessToken)
      XCTAssertEqual(fetchArguments.credentialRequest.credentialConfigurationId, fetchCredentialContextMock.credentialConfigurationId)
      XCTAssertEqual(fetchArguments.credentialRequest.proofs?.jwt.first, Self.jwtStringMock)
    } else {
      XCTFail("fetchCredential no arguments received")
    }

    XCTAssertEqual(jwsEncoderMock.receivedKeyPair, fetchCredentialContextMock.holderBindingContext?.keyPair)
    XCTAssertEqual(jwsEncoderMock.receivedAdditionalHeaderParameters["key_attestation"] as? String, fetchCredentialContextMock.holderBindingContext?.keyAttestationJWS)
    XCTAssertEqual(jwsEncoderMock.receivedValue?.audience, fetchCredentialContextMock.credentialIssuer)
    XCTAssertEqual(jwsEncoderMock.receivedValue?.nonce, fetchCredentialContextMock.nonce?.cNonce)
    XCTAssertEqual(jwsSignatureValidatorMock.validateIssuerDidReceivedJws as? VcSdJWS, vcSdJWSMock)
  }

  func testExecute_withoutHolderBinding_returnsVcSdJwt() async throws {
    let context = FetchCredentialContext.Mock.sampleVcSdJwtWithoutHolderBinding

    let result = try await useCase.execute(for: context)

    if case .credential(let credential) = result {
      XCTAssertEqual(credential.raw, vcSdJWSMock.raw)
      XCTAssertEqual(credential as? SdJWS<VcSdJwt>, vcSdJWSMock)
    }
  }

  func testExecute_withoutHolderBinding_argumentsPassed() async throws {
    let context = FetchCredentialContext.Mock.sampleVcSdJwtWithoutHolderBinding

    _ = try await useCase.execute(for: context)

    if let fetchArguments = repositorySpy.fetchCredentialWithCredentialRequestReceivedArguments {
      XCTAssertEqual(fetchArguments.context.credentialEndpoint, context.credentialEndpoint)
      XCTAssertEqual(fetchArguments.context.accessToken, context.accessToken)
      XCTAssertEqual(fetchArguments.credentialRequest.credentialConfigurationId, context.credentialConfigurationId)
      XCTAssertNil(fetchArguments.credentialRequest.proofs)
    } else {
      XCTFail("fetchCredential no arguments received")
    }

    XCTAssertNil(jwsEncoderMock.receivedKeyPair)
    XCTAssertTrue(jwsEncoderMock.receivedAdditionalHeaderParameters.isEmpty)
    XCTAssertNil(jwsEncoderMock.receivedValue?.audience)
    XCTAssertNil(jwsEncoderMock.receivedValue?.nonce)
    XCTAssertEqual(jwsSignatureValidatorMock.validateIssuerDidReceivedJws as? VcSdJWS, vcSdJWSMock)
  }

  func testExecute_withHolderBindingWithoutKeyAttestation_jwsEncoderArgumentsPassed() async throws {
    let context = FetchCredentialContext.Mock.sampleVcSdJwtWithoutKeyAttestation

    _ = try await useCase.execute(for: context)

    XCTAssertEqual(jwsEncoderMock.receivedKeyPair, context.holderBindingContext?.keyPair)
    XCTAssertTrue(jwsEncoderMock.receivedAdditionalHeaderParameters.isEmpty)
    XCTAssertEqual(jwsEncoderMock.receivedValue?.audience, context.credentialIssuer)
    XCTAssertEqual(jwsEncoderMock.receivedValue?.nonce, context.nonce?.cNonce)
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
    repositorySpy.fetchCredentialWithCredentialRequestThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: fetchCredentialContextMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_validationReturnsFalse_throwsError() async throws {
    jwsSignatureValidatorMock.validateIssuerDidThrowableError = TestingError.error
    useCase = FetchVcSdJwtCredentialUseCase()

    do {
      _ = try await useCase.execute(for: fetchCredentialContextMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_validationFailure_throwsError() async throws {
    jwsSignatureValidatorMock.validateIssuerDidThrowableError = TestingError.error
    useCase = FetchVcSdJwtCredentialUseCase()

    do {
      _ = try await useCase.execute(for: fetchCredentialContextMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_cannotResolveDid_throwsErrors() async throws {
    jwsSignatureValidatorMock.validateIssuerDidThrowableError = JWSSignatureValidatorError.cannotResolveDid(TestingError.error)
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
  private static let vctMock = "elfa-sdjwt"

  private let vcSdJWSMock = VcSdJWS.Mock.sample
  private let credentialResponseMock = CredentialResponseImmediate.Mock.sample
  private var fetchCredentialContextMock: FetchCredentialContext = .Mock.sampleVcSdJwt

  private let mockDeferredCrendentialRequest = DeferredCredentialRequest(
    transactionId: "transactionId",
    accessToken: "accessToken",
    endpoint: "endpoint",
    format: "format",
    interval: 5)

  private var useCase = FetchVcSdJwtCredentialUseCase()
  private var jwsEncoderMock = JWSEncoderMock<ProofJWT>()
  private var repositorySpy = OpenIDRepositoryProtocolSpy()
  private var jwsSignatureValidatorMock: JWSSignatureValidatorMock<VcSdJwt>!

  private func registerMocks() {
    jwsEncoderMock = JWSEncoderMock()
    repositorySpy = OpenIDRepositoryProtocolSpy()
    jwsSignatureValidatorMock = JWSSignatureValidatorMock()

    Container.shared.jwsEncoder.register { self.jwsEncoderMock }
    Container.shared.openIDRepository.register { self.repositorySpy }
    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidatorMock }
  }

  private func success() {
    jwsEncoderMock.encodeUsingReturnValue = Self.jwtDataMock
    repositorySpy.fetchCredentialWithCredentialRequestReturnValue = .credential(vcSdJWSMock)
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
