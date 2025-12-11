import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITEIDRequest
@testable import BITEIDRequestShared
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
    let result = try await useCase.execute(for: caseId)

    XCTAssertEqual(result, mockWalletPairingResponse.walletPairingId)
    XCTAssertEqual(eIDRequestRepository.pairWalletCaseIdCallsCount, 1)
    XCTAssertEqual(validateCredentialOfferInvitationUrlUseCase.executeCallsCount, 1)
    XCTAssertEqual(fetchCredentialUseCase.executeFromCallsCount, 1)
    XCTAssertEqual(eIDRequestCaseRepository.getIdCallsCount, 1)
    XCTAssertEqual(eIDRequestCaseRepository.updateCallsCount, 1)
  }

  func testExecute_success_assertParameters() async throws {
    _ = try await useCase.execute(for: caseId)

    XCTAssertEqual(eIDRequestRepository.pairWalletCaseIdReceivedCaseId, caseId)
    XCTAssertEqual(validateCredentialOfferInvitationUrlUseCase.executeReceivedUrl, mockWalletPairingResponse.credentialOfferLink)
    XCTAssertEqual(fetchCredentialUseCase.executeFromReceivedOffer, mockCredentialOffer)

    XCTAssertEqual(eIDRequestCaseRepository.getIdReceivedId, caseId)
    XCTAssertEqual(eIDRequestCaseRepository.updateReceivedEIDRequestCase?.deferredCredential, mockFetchCredentialResult.0)

  }

  func testExecute_receiveCredential_throws() async throws {
    fetchCredentialUseCase.executeFromReturnValue = (VerifiableCredential.Mock.sample, nil)

    do {
      _ = try await useCase.execute(for: caseId)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? FetchCredentialUseCaseError, .invalidCredential)
    }
  }

  func testExecute_pairWalletThrowsError_throwsError() async throws {
    eIDRequestRepository.pairWalletCaseIdThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: caseId)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_validateOfferThrowsError_throwsError() async throws {
    validateCredentialOfferInvitationUrlUseCase.executeThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: caseId)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_fetchCredentialThrowsError_throwsError() async throws {
    fetchCredentialUseCase.executeFromThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: caseId)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_getEidRequestCaseThrowsError_throwsError() async throws {
    eIDRequestCaseRepository.getIdThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: caseId)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_updateRequestCaseThrowsError_throwsError() async throws {
    eIDRequestCaseRepository.updateThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: caseId)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let caseId = "caseId"
  private let mockCredentialOffer = CredentialOffer.Mock.sample
  private var mockFetchCredentialResult: (DeferredCredential, TrustInformation?)!
  private let mockWalletPairingResponse = WalletPairingResponse.Mock.sample
  private let mockEIDRequestCase = EIDRequestCase.Mock.sampleAgentReview

  private var useCase: PairWalletUseCase!

  private var eIDRequestRepository: EIDRequestRepositoryProtocolSpy!
  private var fetchCredentialUseCase: FetchCredentialUseCaseProtocolSpy!
  private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocolSpy!
  private var validateCredentialOfferInvitationUrlUseCase: ValidateCredentialOfferInvitationUrlUseCaseProtocolSpy!

  private func registerMocks() {
    eIDRequestRepository = EIDRequestRepositoryProtocolSpy()
    fetchCredentialUseCase = FetchCredentialUseCaseProtocolSpy()
    eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    validateCredentialOfferInvitationUrlUseCase = ValidateCredentialOfferInvitationUrlUseCaseProtocolSpy()

    Container.shared.eIDRequestRepository.register { self.eIDRequestRepository }
    Container.shared.fetchCredentialUseCase.register { self.fetchCredentialUseCase }
    Container.shared.eIDRequestCaseRepository.register { self.eIDRequestCaseRepository }
    Container.shared.validateCredentialOfferInvitationUrlUseCase.register { self.validateCredentialOfferInvitationUrlUseCase }
  }

  private func createSuccessState() {
    mockFetchCredentialResult = (DeferredCredential.Mock.sample, nil)
    eIDRequestRepository.pairWalletCaseIdReturnValue = mockWalletPairingResponse
    validateCredentialOfferInvitationUrlUseCase.executeReturnValue = mockCredentialOffer
    fetchCredentialUseCase.executeFromReturnValue = mockFetchCredentialResult
    eIDRequestCaseRepository.getIdReturnValue = mockEIDRequestCase
    eIDRequestCaseRepository.updateReturnValue = mockEIDRequestCase
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
