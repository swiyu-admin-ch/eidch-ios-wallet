import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

@Suite(.container)
struct CompareWalletPairingUseCaseTests {

  // MARK: Lifecycle

  init() {
    let eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    eIDRequestCaseRepository.getPairingIdsForRequestCaseIdReturnValue = mockPairingIds
    self.eIDRequestCaseRepository = eIDRequestCaseRepository

    let sidRepository = SIDRepositoryProtocolSpy()
    sidRepository.fetchRequestStatusForReturnValue = EIDRequestStatus.Mock.sampleAutoVerification
    self.sidRepository = sidRepository

    Container.shared.eIDRequestCaseRepository.register { eIDRequestCaseRepository }
    Container.shared.sidRepository.register { sidRepository }

    useCase = CompareWalletPairingUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_success() async throws {
    try await useCase(for: mockCaseId)

    #expect(sidRepository.fetchRequestStatusForCallsCount == 1)
    #expect(sidRepository.fetchRequestStatusForReceivedCaseId == mockCaseId)

    #expect(eIDRequestCaseRepository.getPairingIdsForRequestCaseIdCallsCount == 1)
    #expect(eIDRequestCaseRepository.getPairingIdsForRequestCaseIdReceivedId == mockCaseId)
  }

  @Test
  func callAsFunction_fetchRequestStatusFails_throws() async throws {
    sidRepository.fetchRequestStatusForThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase(for: mockCaseId)
    }

    #expect(!eIDRequestCaseRepository.getPairingIdsForRequestCaseIdCalled)
  }

  @Test
  func callAsFunction_statusPairedWalletIsNil_throws() async throws {
    sidRepository.fetchRequestStatusForReturnValue = EIDRequestStatus.Mock.inQueueSample

    await #expect(throws: CompareWalletPairingUseCaseError.noDevicePaired) {
      try await useCase(for: mockCaseId)
    }

    #expect(!eIDRequestCaseRepository.getPairingIdsForRequestCaseIdCalled)
  }

  @Test
  func callAsFunction_statusPairedWalletIsEmpty_throws() async throws {
    sidRepository.fetchRequestStatusForReturnValue = EIDRequestStatus.Mock.sampleAutoVerificationWithoutPairedWallets

    await #expect(throws: CompareWalletPairingUseCaseError.noDevicePaired) {
      try await useCase(for: mockCaseId)
    }

    #expect(!eIDRequestCaseRepository.getPairingIdsForRequestCaseIdCalled)
  }

  @Test
  func callAsFunction_getPairingIdsFails_throws() async throws {
    eIDRequestCaseRepository.getPairingIdsForRequestCaseIdThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase(for: mockCaseId)
    }
  }

  @Test
  func callAsFunction_pairingsArentMatching_throws() async throws {
    eIDRequestCaseRepository.getPairingIdsForRequestCaseIdReturnValue = ["walletPairingId_1"]

    await #expect(throws: CompareWalletPairingUseCaseError.invalidPairingCount) {
      try await useCase(for: mockCaseId)
    }
  }

  // MARK: Private

  private let useCase: CompareWalletPairingUseCase

  private let mockCaseId = "caseId"
  private let mockPairingIds = ["walletPairingId_1", "walletPairingId_2"]

  private let sidRepository: SIDRepositoryProtocolSpy
  private let eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocolSpy
}
