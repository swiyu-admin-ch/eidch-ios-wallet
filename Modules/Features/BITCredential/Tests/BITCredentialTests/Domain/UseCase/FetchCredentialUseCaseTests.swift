import BITCrypto
import Factory
import Spyable
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOca
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class FetchCredentialUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    fetchAnyVerifiableCredentialUseCase = FetchAnyVerifiableCredentialUseCaseProtocolSpy()
    saveCredentialUseCase = SaveCredentialUseCaseProtocolSpy()
    checkAndUpdateCredentialStatusUseCase = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
    fetchTrustStatementUseCase = FetchTrustStatementUseCaseProtocolSpy()

    Container.shared.fetchAnyVerifiableCredentialUseCase.register { self.fetchAnyVerifiableCredentialUseCase }
    Container.shared.saveCredentialUseCase.register { self.saveCredentialUseCase }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { self.checkAndUpdateCredentialStatusUseCase }
    Container.shared.fetchTrustStatementUseCase.register { self.fetchTrustStatementUseCase }

    useCase = FetchCredentialUseCase()
  }

  func testExecute_validResultCredentialAndTrustStatement_returnsBoth() async throws {
    fetchAnyVerifiableCredentialUseCase.executeFromReturnValue = (metadataWrapper, anyCredential, nil, mockRawOcaBundle)
    saveCredentialUseCase.executeCredentialKeyPairMetadataWrapperReturnValue = credential
    checkAndUpdateCredentialStatusUseCase.executeForReturnValue = credential
    fetchTrustStatementUseCase.executeIssuerReturnValue = TrustStatementPayload.Mock.validSample

    let (resultCredential, trustStatement) = try await useCase.execute(from: offer)
    XCTAssertEqual(resultCredential, credential)
    XCTAssertEqual(trustStatement, TrustStatementPayload.Mock.validSample)

    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.executeFromCallsCount, 1)
    XCTAssertEqual(saveCredentialUseCase.executeCredentialKeyPairMetadataWrapperCallsCount, 1)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForCallsCount, 1)
    XCTAssertEqual(fetchTrustStatementUseCase.executeIssuerCallsCount, 1)
  }

  func testExecute_validResultCredentialAndTrustStatement_assertUseCasesArguments() async throws {
    fetchAnyVerifiableCredentialUseCase.executeFromReturnValue = (metadataWrapper, anyCredential, keyPair, mockRawOcaBundle)
    saveCredentialUseCase.executeCredentialKeyPairMetadataWrapperReturnValue = credential
    checkAndUpdateCredentialStatusUseCase.executeForReturnValue = credential
    fetchTrustStatementUseCase.executeIssuerReturnValue = TrustStatementPayload.Mock.validSample

    let (_, _) = try await useCase.execute(from: offer)

    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.executeFromReceivedInvocations, [offer])

    XCTAssertEqual(anyCredential.raw, saveCredentialUseCase.executeCredentialKeyPairMetadataWrapperReceivedArguments?.credential.raw)
    XCTAssertEqual(saveCredentialUseCase.executeCredentialKeyPairMetadataWrapperReceivedArguments?.keyPair?.identifier, keyPair.identifier)
    XCTAssertEqual(saveCredentialUseCase.executeCredentialKeyPairMetadataWrapperReceivedArguments?.keyPair?.algorithm, keyPair.algorithm)

    // ADD OCA CHECKS WHEN OCA IS IMPLEMENTED IN THE USECASE

    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForReceivedInvocations, [credential])

    XCTAssertEqual(fetchTrustStatementUseCase.executeIssuerReceivedInvocations, [anyCredential.issuer])
  }

  func testExecute_fetchAnyVerifiableCredentialUseCase_throwsError() async throws {
    fetchAnyVerifiableCredentialUseCase.executeFromThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_saveCredentialUseCase_throwsError() async throws {
    fetchAnyVerifiableCredentialUseCase.executeFromReturnValue = (metadataWrapper, anyCredential, nil, mockRawOcaBundle)
    saveCredentialUseCase.executeCredentialKeyPairMetadataWrapperThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_checkAndUpdateCredentialStatusUseCaseFailure_returnsValidCredentialAndTrustStatement() async throws {
    fetchAnyVerifiableCredentialUseCase.executeFromReturnValue = (metadataWrapper, anyCredential, nil, mockRawOcaBundle)
    saveCredentialUseCase.executeCredentialKeyPairMetadataWrapperReturnValue = credential
    checkAndUpdateCredentialStatusUseCase.executeForThrowableError = TestingError.error
    fetchTrustStatementUseCase.executeIssuerReturnValue = TrustStatementPayload.Mock.validSample

    let (resultCredential, trustStatement) = try await useCase.execute(from: offer)
    XCTAssertEqual(resultCredential, credential)
    XCTAssertEqual(trustStatement, TrustStatementPayload.Mock.validSample)
  }

  func testExecute_trustStatementUseCaseFailure_returnsValidCredentialAndNilStatement() async throws {
    fetchAnyVerifiableCredentialUseCase.executeFromReturnValue = (metadataWrapper, anyCredential, nil, mockRawOcaBundle)
    saveCredentialUseCase.executeCredentialKeyPairMetadataWrapperReturnValue = credential
    checkAndUpdateCredentialStatusUseCase.executeForReturnValue = credential
    fetchTrustStatementUseCase.executeIssuerThrowableError = TestingError.error

    let (resultCredential, trustStatement) = try await useCase.execute(from: offer)
    XCTAssertEqual(resultCredential, credential)
    XCTAssertNil(trustStatement)
  }

  func testExecute_trustStatementUseCaseNil_returnsValidCredentialAndNilStatement() async throws {
    fetchAnyVerifiableCredentialUseCase.executeFromReturnValue = (metadataWrapper, anyCredential, nil, mockRawOcaBundle)
    saveCredentialUseCase.executeCredentialKeyPairMetadataWrapperReturnValue = credential
    checkAndUpdateCredentialStatusUseCase.executeForReturnValue = credential
    fetchTrustStatementUseCase.executeIssuerReturnValue = nil

    let (resultCredential, trustStatement) = try await useCase.execute(from: offer)
    XCTAssertEqual(resultCredential, credential)
    XCTAssertNil(trustStatement)
  }

  func testExecute_withoutOCA_returnsValidCredentialAndTrustStatement() async throws {
    fetchAnyVerifiableCredentialUseCase.executeFromReturnValue = (metadataWrapper, anyCredential, nil, nil)
    saveCredentialUseCase.executeCredentialKeyPairMetadataWrapperReturnValue = credential
    checkAndUpdateCredentialStatusUseCase.executeForReturnValue = credential
    fetchTrustStatementUseCase.executeIssuerReturnValue = TrustStatementPayload.Mock.validSample

    let (resultCredential, trustStatement) = try await useCase.execute(from: offer)
    XCTAssertEqual(resultCredential, credential)
    XCTAssertEqual(trustStatement, TrustStatementPayload.Mock.validSample)
  }

  // MARK: Private

  private var fetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocolSpy!
  private var saveCredentialUseCase: SaveCredentialUseCaseProtocolSpy!
  private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocolSpy!
  private var fetchTrustStatementUseCase: FetchTrustStatementUseCaseProtocolSpy!
  private var useCase: FetchCredentialUseCase!
  private lazy var keyPair: KeyPair = {
    let identifier = UUID()
    let algorithm = "keyAlgorithm"
    let privateKey: SecKey = SecKeyTestsHelper.createPrivateKey()

    return KeyPair(identifier: identifier, algorithm: algorithm, privateKey: privateKey)
  }()

  private let credential: Credential = .Mock.sample
  private let metadataWrapper: CredentialMetadataWrapper = .Mock.sample
  private let anyCredential: AnyCredential = MockAnyCredential()
  private let offer: CredentialOffer = .Mock.sample
  private let mockRawOcaBundle = RawOcaBundle()
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
