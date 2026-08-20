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

    if case .credential(let credentials) = result {
      XCTAssertEqual(credentials.count, 1)
      XCTAssertEqual(credentials.first?.raw, vcSdJWSMock.raw)
      XCTAssertEqual(credentials.first as? SdJWS<VcSdJwt>, vcSdJWSMock)
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
      XCTAssertEqual(fetchArguments.credentialRequest.credentialConfigurationId, fetchCredentialContextMock.credentialConfigurationId)
      XCTAssertEqual(fetchArguments.credentialRequest.proofs?.jwt.count, 1)
      XCTAssertEqual(fetchArguments.credentialRequest.proofs?.jwt.first, Self.jwtStringMock)
      XCTAssertEqual(fetchArguments.credentialRequest.credentialResponseEncryption.enc, fetchCredentialContextMock.credentialEncryptionContext.credentialResponseEncryptionAlgorithm.rawValue)
      XCTAssertEqual(fetchArguments.credentialRequest.credentialResponseEncryption.zip, fetchCredentialContextMock.credentialEncryptionContext.credentialResponseEncryptionZipValue?.rawValue)
    } else {
      XCTFail("fetchCredential no arguments received")
    }

    XCTAssertEqual(jwsEncoderMock.receivedKeyPair, fetchCredentialContextMock.holderBindings?.first?.keyPair)
    XCTAssertEqual(jwsEncoderMock.receivedAdditionalHeaderParameters["key_attestation"] as? String, fetchCredentialContextMock.holderBindings?.first?.keyAttestationJWS)
    XCTAssertEqual(jwsEncoderMock.receivedValue?.audience, fetchCredentialContextMock.credentialIssuer.absoluteString)
    XCTAssertEqual(jwsEncoderMock.receivedValue?.nonce, fetchCredentialContextMock.nonce?.cNonce)
    XCTAssertEqual(jwsSignatureValidatorMock.validateReceivedJws as? VcSdJWS, vcSdJWSMock)
  }

  func testExecute_withoutHolderBinding_returnsVcSdJwt() async throws {
    let context = FetchCredentialContext.Mock.sampleWithoutHolderBinding

    let result = try await useCase.execute(for: context)

    if case .credential(let credentials) = result {
      XCTAssertEqual(credentials.count, 1)
      XCTAssertEqual(credentials.first?.raw, vcSdJWSMock.raw)
      XCTAssertEqual(credentials.first as? SdJWS<VcSdJwt>, vcSdJWSMock)
    }
  }

  func testExecute_withoutHolderBinding_argumentsPassed() async throws {
    let context = FetchCredentialContext.Mock.sampleWithoutHolderBinding

    _ = try await useCase.execute(for: context)

    if let fetchArguments = repositorySpy.fetchCredentialWithCredentialRequestReceivedArguments {
      XCTAssertEqual(fetchArguments.context.credentialEndpoint, context.credentialEndpoint)
      XCTAssertEqual(fetchArguments.context.accessToken, context.accessToken)
      XCTAssertEqual(fetchArguments.credentialRequest.credentialConfigurationId, fetchCredentialContextMock.credentialConfigurationId)
      XCTAssertNil(fetchArguments.credentialRequest.proofs)
      XCTAssertEqual(fetchArguments.credentialRequest.credentialResponseEncryption.enc, fetchCredentialContextMock.credentialEncryptionContext.credentialResponseEncryptionAlgorithm.rawValue)
      XCTAssertEqual(fetchArguments.credentialRequest.credentialResponseEncryption.zip, fetchCredentialContextMock.credentialEncryptionContext.credentialResponseEncryptionZipValue?.rawValue)
    } else {
      XCTFail("fetchCredential no arguments received")
    }

    XCTAssertNil(jwsEncoderMock.receivedKeyPair)
    XCTAssertTrue(jwsEncoderMock.receivedAdditionalHeaderParameters.isEmpty)
    XCTAssertNil(jwsEncoderMock.receivedValue?.audience)
    XCTAssertNil(jwsEncoderMock.receivedValue?.nonce)
    XCTAssertEqual(jwsSignatureValidatorMock.validateReceivedJws as? VcSdJWS, vcSdJWSMock)
  }

  func testExecute_withSoftwareHolderBinding_jwsEncoderArgumentsPassed() async throws {
    let context = FetchCredentialContext.Mock.sampleWithSoftwareHolderBinding

    _ = try await useCase.execute(for: context)

    XCTAssertEqual(jwsEncoderMock.receivedKeyPair, context.holderBindings?.first?.keyPair)
    XCTAssertTrue(jwsEncoderMock.receivedAdditionalHeaderParameters.isEmpty)
    XCTAssertEqual(jwsEncoderMock.receivedValue?.audience, context.credentialIssuer.absoluteString)
    XCTAssertEqual(jwsEncoderMock.receivedValue?.nonce, context.nonce?.cNonce)
  }

  func testExecute_batchCredential_returnsValidatedBatch() async throws {
    let context = FetchCredentialContext.Mock.sampleBatch
    repositorySpy.fetchCredentialWithCredentialRequestReturnValue = .credential([vcSdJWSMock, vcSdJWSMock])

    let result = try await useCase.execute(for: context)

    if case .credential(let credentials) = result {
      XCTAssertEqual(credentials.count, 2)
      XCTAssertEqual(credentials[0].raw, vcSdJWSMock.raw)
      XCTAssertEqual(credentials[1].raw, vcSdJWSMock.raw)
      XCTAssertEqual(jwsSignatureValidatorMock.validateCallsCount, 2)
    } else {
      XCTFail("Expected batch result")
    }
  }

  func testExecute_batchHolderBinding_generatesOneProofPerBinding() async throws {
    let context = FetchCredentialContext.Mock.sampleBatch
    repositorySpy.fetchCredentialWithCredentialRequestReturnValue = .credential([vcSdJWSMock, vcSdJWSMock])

    _ = try await useCase.execute(for: context)

    XCTAssertEqual(repositorySpy.fetchCredentialWithCredentialRequestReceivedArguments?.credentialRequest.proofs?.jwt.count, 2)
    XCTAssertEqual(jwsEncoderMock.receivedKeyPair, context.holderBindings?.last?.keyPair)
  }

  func testExecute_batchCredential_validationFails_throwsError() async throws {
    repositorySpy.fetchCredentialWithCredentialRequestReturnValue = .credential([vcSdJWSMock, vcSdJWSMock])
    jwsSignatureValidatorMock.validateThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: FetchCredentialContext.Mock.sampleBatch)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(jwsSignatureValidatorMock.validateCallsCount, 1)
    }
  }

  func testExecute_batchCredential_withInvalidBatchConsistency_throwsValidationFailed() async throws {
    repositorySpy.fetchCredentialWithCredentialRequestReturnValue = .credential([vcSdJWSMock, vcSdJWSMock])
    sdJwtBatchCredentialConsistencyValidator.validateThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: FetchCredentialContext.Mock.sampleBatch)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(jwsSignatureValidatorMock.validateCallsCount, 2)
    }
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
  private var fetchCredentialContextMock: FetchCredentialContext = .Mock.sample

  private let mockDeferredCrendentialRequest = DeferredCredentialContext(
    transactionId: "transactionId",
    accessToken: AccessToken.Mock.sample,
    endpoint: "endpoint",
    format: .vcSdJwt,
    interval: 5)

  private var useCase = FetchVcSdJwtCredentialUseCase()
  private var jwsEncoderMock = JWSEncoderMock<ProofJWT>()
  private var repositorySpy = OpenIDRepositoryProtocolSpy()
  private var jwsSignatureValidatorMock: JWSSignatureValidatorMock<VcSdJwt>!
  private var sdJwtBatchCredentialConsistencyValidator = SdJwtBatchCredentialConsistencyValidatorProtocolSpy()

  private func registerMocks() {
    jwsEncoderMock = JWSEncoderMock()
    repositorySpy = OpenIDRepositoryProtocolSpy()
    jwsSignatureValidatorMock = JWSSignatureValidatorMock()

    Container.shared.jwsEncoder.register { self.jwsEncoderMock }
    Container.shared.openIDRepository.register { self.repositorySpy }
    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidatorMock }
    Container.shared.sdJwtBatchCredentialConsistencyValidator.register { self.sdJwtBatchCredentialConsistencyValidator }
  }

  private func success() {
    jwsEncoderMock.encodeUsingReturnValue = Self.jwtDataMock
    repositorySpy.fetchCredentialWithCredentialRequestReturnValue = .credential([vcSdJWSMock])
  }
}
