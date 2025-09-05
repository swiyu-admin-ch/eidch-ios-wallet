import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITEIDRequest
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try

final class PairWalletUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    useCase = PairWalletUseCase()
    createSuccessState()
  }

  func testExecute_success_assertCount() async throws {
    try await useCase.execute(for: caseId)

    XCTAssertEqual(eIDRequestRepository.pairWalletCaseIdCallsCount, 1)
    XCTAssertEqual(validateCredentialOfferInvitationUrlUseCase.executeCallsCount, 1)
    XCTAssertEqual(fetchCredentialUseCase.executeFromCallsCount, 1)
    XCTAssertEqual(deferredCredentialRepository.createCallsCount, 1)
  }

  func testExecute_success_assertParameters() async throws {
    try await useCase.execute(for: caseId)

    XCTAssertEqual(eIDRequestRepository.pairWalletCaseIdReceivedCaseId, caseId)
    XCTAssertEqual(validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl, mockWalletPairingResponse.credentialOfferLink)
    XCTAssertEqual(fetchCredentialUseCase.executeFromReceivedOffer, mockCredentialOffer)

    if case .deferred(let credential) = mockFetchCredentialResult {
      XCTAssertEqual(deferredCredentialRepository.createReceivedDeferredCredential, credential)
    }
  }

  func testExecute_receiveCredential_throws() async throws {
    fetchCredentialUseCase.executeFromReturnValue = .credential(.Mock.sample, nil)

    do {
      try await useCase.execute(for: caseId)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? FetchCredentialUseCaseError, .invalidCredential)
    }
  }

  func testExecute_pairWalletThrowsError_throwsError() async throws {
    eIDRequestRepository.pairWalletCaseIdThrowableError = TestingError.error

    do {
      try await useCase.execute(for: caseId)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_validateOfferThrowsError_throwsError() async throws {
    validateCredentialOfferInvitationUrlUseCase.executeThrowableError = TestingError.error

    do {
      try await useCase.execute(for: caseId)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_fetchCredentialThrowsError_throwsError() async throws {
    fetchCredentialUseCase.executeFromThrowableError = TestingError.error

    do {
      try await useCase.execute(for: caseId)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_createDeferredCredentialThrowsError_throwsError() async throws {
    deferredCredentialRepository.createThrowableError = TestingError.error

    do {
      try await useCase.execute(for: caseId)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let caseId = "caseId"
  private let mockCredentialOffer = CredentialOffer.Mock.sample
  private var mockFetchCredentialResult: FetchCredentialResult!
  private let mockWalletPairingResponse = WalletPairingResponse.Mock.sample

  private var useCase: PairWalletUseCase!

  private var eIDRequestRepository: EIDRequestRepositoryProtocolSpy!
  private var fetchCredentialUseCase: FetchCredentialUseCaseProtocolSpy!
  private var deferredCredentialRepository: DeferredCredentialRepositoryProtocolSpy!
  private var validateCredentialOfferInvitationUrlUseCase: ValidateCredentialOfferInvitationUrlUseCaseProtocolSpy!

  private func registerMocks() {
    eIDRequestRepository = EIDRequestRepositoryProtocolSpy()
    fetchCredentialUseCase = FetchCredentialUseCaseProtocolSpy()
    deferredCredentialRepository = DeferredCredentialRepositoryProtocolSpy()
    validateCredentialOfferInvitationUrlUseCase = ValidateCredentialOfferInvitationUrlUseCaseProtocolSpy()

    Container.shared.eIDRequestRepository.register { self.eIDRequestRepository }
    Container.shared.fetchCredentialUseCase.register { self.fetchCredentialUseCase }
    Container.shared.deferredCredentialRepository.register { self.deferredCredentialRepository }
    Container.shared.validateCredentialOfferInvitationUrlUseCase.register { self.validateCredentialOfferInvitationUrlUseCase }
  }

  private func createSuccessState() {
    mockFetchCredentialResult = .deferred(.Mock.sample)
    eIDRequestRepository.pairWalletCaseIdReturnValue = mockWalletPairingResponse
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromReturnValue = mockFetchCredentialResult
    deferredCredentialRepository.createReturnValue = DeferredCredential.Mock.sample
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
