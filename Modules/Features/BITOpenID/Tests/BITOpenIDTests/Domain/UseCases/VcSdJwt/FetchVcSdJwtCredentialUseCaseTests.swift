import Factory
import Foundation
import XCTest
@testable import BITJWT
@testable import BITOca
@testable import BITOpenID
@testable import BITSdJWT
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
      XCTAssertEqual(jwsSignatureValidatorMock.validateCallsCount, 0)
    }
  }

  func testExecute_success_argumentsPassed() async throws {
    _ = try await useCase.execute(for: fetchCredentialContextMock)

    if let fetchArguments = repositorySpy.fetchCredentialWithCredentialRequestReceivedArguments {
      XCTAssertEqual(fetchArguments.context.credentialEndpoint, fetchCredentialContextMock.credentialEndpoint)
      XCTAssertEqual(fetchArguments.context.accessToken, fetchCredentialContextMock.accessToken)
      guard case .json(let request) = fetchArguments.credentialRequest else {
        XCTFail("Expected json credential request body")
        return
      }
      XCTAssertEqual(request.credentialConfigurationId, fetchCredentialContextMock.credentialConfigurationId)
      XCTAssertEqual(request.proofs?.jwt.first, Self.jwtStringMock)
    } else {
      XCTFail("fetchCredential no arguments received")
    }

    XCTAssertTrue(credentialRequestBodyGeneratorSpy.generateForProofsReceivedArguments?.context === fetchCredentialContextMock)
    XCTAssertEqual(credentialRequestBodyGeneratorSpy.generateForProofsReceivedArguments?.proofs?.jwt.first, Self.jwtStringMock)
    XCTAssertEqual(jwsEncoderMock.receivedKeyPair, fetchCredentialContextMock.holderBindings?.first?.keyPair)
    XCTAssertEqual(jwsEncoderMock.receivedAdditionalHeaderParameters["key_attestation"] as? String, fetchCredentialContextMock.holderBindings?.first?.keyAttestationJWS)
    XCTAssertEqual(jwsEncoderMock.receivedValue?.audience, fetchCredentialContextMock.credentialIssuer)
    XCTAssertEqual(jwsEncoderMock.receivedValue?.nonce, fetchCredentialContextMock.nonce?.cNonce)
    XCTAssertEqual(jwsSignatureValidatorMock.validateReceivedJws as? VcSdJWS, vcSdJWSMock)
  }

  func testExecute_withoutHolderBinding_returnsVcSdJwt() async throws {
    let context = FetchCredentialContext.Mock.sampleVcSdJwtWithoutHolderBinding

    let result = try await useCase.execute(for: context)

    if case .credential(let credential) = result {
      XCTAssertEqual(credential.raw, vcSdJWSMock.raw)
      XCTAssertEqual(credential as? SdJWS<VcSdJwt>, vcSdJWSMock)
    }
  }

  func testExecute_batchCredential_returnsValidatedBatch() async throws {
    let context = FetchCredentialContext.Mock.sampleVcSdJwtBatch
    repositorySpy.fetchCredentialWithCredentialRequestReturnValue = .batch(
      credentials: [vcSdJWSMock, vcSdJWSMock])

    let result = try await useCase.execute(for: context)

    if case .batch(let credentials) = result {
      XCTAssertEqual(credentials.count, 2)
      XCTAssertEqual(credentials[0].raw, vcSdJWSMock.raw)
      XCTAssertEqual(credentials[1].raw, vcSdJWSMock.raw)
      XCTAssertEqual(jwsSignatureValidatorMock.validateCallsCount, 2)
    } else {
      XCTFail("Expected batch result")
    }
  }

  func testExecute_batchHolderBinding_generatesOneProofPerBinding() async throws {
    let context = FetchCredentialContext.Mock.sampleVcSdJwtBatch
    repositorySpy.fetchCredentialWithCredentialRequestReturnValue = .batch(
      credentials: [vcSdJWSMock, vcSdJWSMock])

    _ = try await useCase.execute(for: context)

    XCTAssertEqual(credentialRequestBodyGeneratorSpy.generateForProofsReceivedArguments?.proofs?.jwt.count, 2)
    XCTAssertEqual(jwsEncoderMock.receivedKeyPair, context.holderBindings?.last?.keyPair)
  }

  func testExecute_batchCredential_validationFails_throwsError() async throws {
    repositorySpy.fetchCredentialWithCredentialRequestReturnValue = .batch(
      credentials: [vcSdJWSMock, vcSdJWSMock])
    jwsSignatureValidatorMock.validateThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: FetchCredentialContext.Mock.sampleVcSdJwtBatch)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(jwsSignatureValidatorMock.validateCallsCount, 1)
    }
  }

  func testExecute_batchCredential_withInvalidBatchConsistency_throwsValidationFailed() async throws {
    repositorySpy.fetchCredentialWithCredentialRequestReturnValue = .batch(
      credentials: [vcSdJWSMock, vcSdJWSMock])
    sdJwtBatchCredentialConsistencyValidator.validateThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: FetchCredentialContext.Mock.sampleVcSdJwtBatch)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(jwsSignatureValidatorMock.validateCallsCount, 2)
    }
  }

  func testExecute_withoutHolderBinding_argumentsPassed() async throws {
    let context = FetchCredentialContext.Mock.sampleVcSdJwtWithoutHolderBinding
    credentialRequestBodyGeneratorSpy.generateForProofsReturnValue = .json(
      CredentialRequest(
        credentialConfigurationId: fetchCredentialContextMock.credentialConfigurationId,
        proofs: nil,
        credentialResponseEncryption: nil))

    _ = try await useCase.execute(for: context)

    if let fetchArguments = repositorySpy.fetchCredentialWithCredentialRequestReceivedArguments {
      XCTAssertEqual(fetchArguments.context.credentialEndpoint, context.credentialEndpoint)
      XCTAssertEqual(fetchArguments.context.accessToken, context.accessToken)
      guard case .json(let request) = fetchArguments.credentialRequest else {
        XCTFail("Expected json credential request body")
        return
      }
      XCTAssertEqual(request.credentialConfigurationId, context.credentialConfigurationId)
      XCTAssertNil(request.proofs)
    } else {
      XCTFail("fetchCredential no arguments received")
    }

    XCTAssertTrue(credentialRequestBodyGeneratorSpy.generateForProofsReceivedArguments?.context === context)
    XCTAssertNil(credentialRequestBodyGeneratorSpy.generateForProofsReceivedArguments?.proofs)
    XCTAssertNil(jwsEncoderMock.receivedKeyPair)
    XCTAssertTrue(jwsEncoderMock.receivedAdditionalHeaderParameters.isEmpty)
    XCTAssertNil(jwsEncoderMock.receivedValue?.audience)
    XCTAssertNil(jwsEncoderMock.receivedValue?.nonce)
    XCTAssertEqual(jwsSignatureValidatorMock.validateReceivedJws as? VcSdJWS, vcSdJWSMock)
  }

  func testExecute_withHolderBindingWithoutKeyAttestation_jwsEncoderArgumentsPassed() async throws {
    let context = FetchCredentialContext.Mock.sampleVcSdJwtWithoutKeyAttestation

    _ = try await useCase.execute(for: context)

    XCTAssertEqual(jwsEncoderMock.receivedKeyPair, context.holderBindings?.first?.keyPair)
    XCTAssertTrue(jwsEncoderMock.receivedAdditionalHeaderParameters.isEmpty)
    XCTAssertEqual(jwsEncoderMock.receivedValue?.audience, context.credentialIssuer)
    XCTAssertEqual(jwsEncoderMock.receivedValue?.nonce, context.nonce?.cNonce)
  }

  func testExecute_proofEncodingFailure_throwsError() async throws {
    jwsEncoderMock.encodeUsingThrowableError = TestingError.error

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

  func testExecute_credentialRequestBodyGeneratorFailure_throwsError() async throws {
    credentialRequestBodyGeneratorSpy.generateForProofsThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: fetchCredentialContextMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_validationReturnsFalse_throwsError() async throws {
    jwsSignatureValidatorMock.validateThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: fetchCredentialContextMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_validationFailure_throwsError() async throws {
    jwsSignatureValidatorMock.validateThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: fetchCredentialContextMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_cannotResolveDid_throwsErrors() async throws {
    jwsSignatureValidatorMock.validateThrowableError = JWSSignatureValidatorError.cannotResolveDid(TestingError.error)

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

  private let vcSdJWSMock = VcSdJWS.Mock.sample
  private let credentialResponseMock = CredentialResponseImmediate.Mock.sample
  private var fetchCredentialContextMock: FetchCredentialContext = .Mock.sampleVcSdJwt

  private let mockDeferredCrendentialRequest = DeferredCredentialContext(
    transactionId: "transactionId",
    accessToken: AccessToken.Mock.sample,
    endpoint: "endpoint",
    format: "format",
    interval: 5)

  private var useCase = FetchVcSdJwtCredentialUseCase()
  private var jwsEncoderMock = JWSEncoderMock<ProofJWT>()
  private var repositorySpy = OpenIDRepositoryProtocolSpy()
  private var jwsSignatureValidatorMock: JWSSignatureValidatorMock<VcSdJwt>!
  private var credentialRequestBodyGeneratorSpy = CredentialRequestBodyGeneratorProtocolSpy()
  private var sdJwtBatchCredentialConsistencyValidator = SdJwtBatchCredentialConsistencyValidatorProtocolSpy()

  private func registerMocks() {
    jwsEncoderMock = JWSEncoderMock()
    repositorySpy = OpenIDRepositoryProtocolSpy()
    jwsSignatureValidatorMock = JWSSignatureValidatorMock()
    credentialRequestBodyGeneratorSpy = CredentialRequestBodyGeneratorProtocolSpy()

    Container.shared.jwsEncoder.register { self.jwsEncoderMock }
    Container.shared.openIDRepository.register { self.repositorySpy }
    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidatorMock }
    Container.shared.credentialRequestBodyGenerator.register { self.credentialRequestBodyGeneratorSpy }
    Container.shared.sdJwtBatchCredentialConsistencyValidator.register { self.sdJwtBatchCredentialConsistencyValidator }
  }

  private func success() {
    jwsEncoderMock.encodeUsingReturnValue = Self.jwtDataMock
    repositorySpy.fetchCredentialWithCredentialRequestReturnValue = .credential(vcSdJWSMock)
    credentialRequestBodyGeneratorSpy.generateForProofsReturnValue = .json(
      CredentialRequest(
        credentialConfigurationId: fetchCredentialContextMock.credentialConfigurationId,
        proofs: CredentialRequest.Proofs(jwt: [Self.jwtStringMock]),
        credentialResponseEncryption: nil))
  }
}
