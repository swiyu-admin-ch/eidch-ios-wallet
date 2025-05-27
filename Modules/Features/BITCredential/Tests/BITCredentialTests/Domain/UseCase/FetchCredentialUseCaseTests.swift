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
    super.setUp()
    Container.shared.reset()
    registerMocks()

    useCase = FetchCredentialUseCase()

    success()
  }

  func testExecute_validResultCredentialAndTrustStatement_returnsBoth() async throws {
    let (resultCredential, trustStatement) = try await useCase.execute(from: offer)

    XCTAssertEqual(resultCredential, updatedCredential)
    XCTAssertEqual(trustStatement, TrustStatementPayload.Mock.validSample)
  }

  func testExecute_validResultCredentialAndTrustStatement_callsCount() async throws {
    _ = try await useCase.execute(from: offer)

    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.executeFromCallsCount, 1)
    XCTAssertEqual(fetchVcMetadataUseCase.executeForCallsCount, 0)
    XCTAssertEqual(credentialGenerator.generateForKeyPairOcaBundleMetadataWrapperCallsCount, 1)
    XCTAssertEqual(credentialRepository.createCredentialCallsCount, 1)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForCallsCount, 1)
    XCTAssertEqual(fetchTrustStatementUseCase.executeIssuerCallsCount, 1)
  }

  func testExecute_validResultCredentialAndTrustStatement_argumentsPassed() async throws {
    let _ = try await useCase.execute(from: offer)

    XCTAssertEqual(fetchAnyVerifiableCredentialUseCase.executeFromReceivedOffer, offer)
//    XCTAssertEqual(fetchVcMetadataUseCase.executeForReceivedAnyCredential?.raw, anyCredential.raw)

    XCTAssertEqual(credentialGenerator.generateForKeyPairOcaBundleMetadataWrapperReceivedArguments?.anyCredential.raw, anyCredential.raw)
    XCTAssertEqual(credentialGenerator.generateForKeyPairOcaBundleMetadataWrapperReceivedArguments?.keyPair, keyPair)
    XCTAssertNil(credentialGenerator.generateForKeyPairOcaBundleMetadataWrapperReceivedArguments?.ocaBundle)
    XCTAssertEqual(credentialGenerator.generateForKeyPairOcaBundleMetadataWrapperReceivedArguments?.metadataWrapper.selectedCredential.claims, metadataWrapper.selectedCredential.claims)

    XCTAssertEqual(credentialRepository.createCredentialReceivedCredential, generatedCredential)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForReceivedCredential, repositoryCredential)
    XCTAssertEqual(fetchTrustStatementUseCase.executeIssuerReceivedIssuer, anyCredential.issuer)
  }

  func testExecute_fetchOCAReturnsNil_passesNilAndReturnsBoth() async throws {
    fetchVcMetadataUseCase.executeForReturnValue = nil

    let (resultCredential, trustStatement) = try await useCase.execute(from: offer)

    XCTAssertEqual(credentialRepository.createCredentialReceivedCredential, generatedCredential)
    XCTAssertNil(credentialGenerator.generateForKeyPairOcaBundleMetadataWrapperReceivedArguments?.ocaBundle)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeForReceivedCredential, repositoryCredential)
    XCTAssertEqual(resultCredential, updatedCredential)
    XCTAssertEqual(trustStatement, TrustStatementPayload.Mock.validSample)
  }

  func testExecute_fetchAnyVerifiableCredential_throwsError() async throws {
    fetchAnyVerifiableCredentialUseCase.executeFromThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

//  func testExecute_fetchVcMetadataFailure_throwsError() async throws {
//    fetchVcMetadataUseCase.executeForThrowableError = TestingError.error
//
//    do {
//      _ = try await useCase.execute(from: offer)
//      XCTFail("Expected a TestingError.error instead")
//    } catch {
//      XCTAssertEqual(error as? TestingError, .error)
//    }
//  }

  func testExecute_credentialGeneratorFailure_throwsError() async throws {
    credentialGenerator.generateForKeyPairOcaBundleMetadataWrapperThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_credentialRepositoryFailure_throwsError() async throws {
    credentialRepository.createCredentialThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: offer)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_checkAndUpdateCredentialStatusFailure_returnsValidCredentialAndTrustStatement() async throws {
    checkAndUpdateCredentialStatusUseCase.executeForThrowableError = TestingError.error

    let (resultCredential, trustStatement) = try await useCase.execute(from: offer)
    XCTAssertEqual(resultCredential, repositoryCredential)
    XCTAssertEqual(trustStatement, TrustStatementPayload.Mock.validSample)
  }

  func testExecute_fetchTrustStatementFailure_returnsValidCredentialAndNilStatement() async throws {
    fetchTrustStatementUseCase.executeIssuerThrowableError = TestingError.error

    let (resultCredential, trustStatement) = try await useCase.execute(from: offer)
    XCTAssertEqual(resultCredential, updatedCredential)
    XCTAssertNil(trustStatement)
  }

  func testExecute_fetchTrustStatementReturnsNil_returnsValidCredentialAndNilStatement() async throws {
    fetchTrustStatementUseCase.executeIssuerReturnValue = nil

    let (resultCredential, trustStatement) = try await useCase.execute(from: offer)
    XCTAssertEqual(resultCredential, updatedCredential)
    XCTAssertNil(trustStatement)
  }

  // MARK: Private

  private var fetchAnyVerifiableCredentialUseCase: FetchAnyVerifiableCredentialUseCaseProtocolSpy!
  private var fetchVcMetadataUseCase: FetchVcMetadataUseCaseProtocolSpy!
  private var credentialGenerator: CredentialGeneratorProtocolSpy!
  private var credentialRepository: CredentialRepositoryProtocolSpy!
  private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocolSpy!
  private var fetchTrustStatementUseCase: FetchTrustStatementUseCaseProtocolSpy!
  private var useCase: FetchCredentialUseCase!
  private lazy var keyPair: KeyPair = {
    let identifier = UUID()
    let algorithm = "keyAlgorithm"
    let privateKey: SecKey = SecKeyTestsHelper.createPrivateKey()

    return KeyPair(identifier: identifier, algorithm: algorithm, privateKey: privateKey)
  }()

  private let generatedCredential: Credential = .Mock.sample
  private let repositoryCredential: Credential = .Mock.sampleWithoutKeyBinding
  private let updatedCredential: Credential = .Mock.sampleDisplaysEmpty
  private let metadataWrapper: CredentialMetadataWrapper = .Mock.sample
  private let anyCredential: AnyCredential = MockAnyCredential()
  private let offer: CredentialOffer = .Mock.sample
  private let ocaBundleMock: OcaBundle = .Mock.simpleSample

  private func registerMocks() {
    fetchAnyVerifiableCredentialUseCase = FetchAnyVerifiableCredentialUseCaseProtocolSpy()
    fetchVcMetadataUseCase = FetchVcMetadataUseCaseProtocolSpy()
    credentialGenerator = CredentialGeneratorProtocolSpy()
    credentialRepository = CredentialRepositoryProtocolSpy()
    checkAndUpdateCredentialStatusUseCase = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
    fetchTrustStatementUseCase = FetchTrustStatementUseCaseProtocolSpy()

    Container.shared.fetchAnyVerifiableCredentialUseCase.register { self.fetchAnyVerifiableCredentialUseCase }
    Container.shared.fetchVcMetadataUseCase.register { self.fetchVcMetadataUseCase }
    Container.shared.credentialGenerator.register { self.credentialGenerator }
    Container.shared.databaseCredentialRepository.register { self.credentialRepository }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { self.checkAndUpdateCredentialStatusUseCase }
    Container.shared.fetchTrustStatementUseCase.register { self.fetchTrustStatementUseCase }
  }

  private func success() {
    fetchAnyVerifiableCredentialUseCase.executeFromReturnValue = (metadataWrapper, anyCredential, keyPair)
    fetchVcMetadataUseCase.executeForReturnValue = ocaBundleMock
    credentialGenerator.generateForKeyPairOcaBundleMetadataWrapperReturnValue = generatedCredential
    credentialRepository.createCredentialReturnValue = repositoryCredential
    checkAndUpdateCredentialStatusUseCase.executeForReturnValue = updatedCredential
    fetchTrustStatementUseCase.executeIssuerReturnValue = TrustStatementPayload.Mock.validSample
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
