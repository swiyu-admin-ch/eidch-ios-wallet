import Factory
import Foundation
import Testing
@testable import BITAnalytics
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

// MARK: - RefreshVerifiableCredentialsUseCaseTests

@Suite(.serialized)
struct RefreshVerifiableCredentialsUseCaseTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let refreshCredentialUseCase = ThreadSafeRefreshVerifiableCredentialUseCaseSpy(returnValue: VerifiableCredential.Mock.diploma)
    let getCredentialRefreshThresholdUseCase = GetCredentialRefreshThresholdUseCaseProtocolSpy()
    getCredentialRefreshThresholdUseCase.callAsFunctionForReturnValue = 2
    let analyticsProvider = MockProvider()
    let analytics = AnalyticsSpy()
    analytics.register(analyticsProvider)

    Container.shared.analytics.register { analytics }
    Container.shared.refreshCredentialUseCase.register { refreshCredentialUseCase }
    Container.shared.getCredentialRefreshThresholdUseCase.register { getCredentialRefreshThresholdUseCase }
    Container.shared.maxConcurrentVerifiableCredentialRefreshes.register { Self.maxConcurrentRefreshes }

    self.refreshCredentialUseCase = refreshCredentialUseCase
    self.getCredentialRefreshThresholdUseCase = getCredentialRefreshThresholdUseCase
    self.analyticsProvider = analyticsProvider
    useCase = RefreshVerifiableCredentialsUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_freshCredentialCountAtThreshold_refreshesCredential() async {
    let credential = refreshableCredential(freshCredentialCount: 2, batchSize: 10)

    await useCase([credential])

    #expect(await refreshCredentialUseCase.callAsFunctionCallsCount == 1)
    #expect(await refreshCredentialUseCase.callAsFunctionReceivedCredential == credential)
    #expect(getCredentialRefreshThresholdUseCase.callAsFunctionForReceivedBatchSize == 10)
  }

  @Test
  func callAsFunction_freshCredentialCountAboveThreshold_doesNotRefreshCredential() async {
    let credential = refreshableCredential(freshCredentialCount: 3, batchSize: 10)

    await useCase([credential])

    #expect(await refreshCredentialUseCase.callAsFunctionCalled == false)
  }

  @Test
  func callAsFunction_withoutRefreshToken_doesNotRefreshCredential() async {
    var credential = refreshableCredential(freshCredentialCount: 1, batchSize: 10)
    credential.authentication = CredentialAuthentication(accessToken: "access-token")

    await useCase([credential])

    #expect(await refreshCredentialUseCase.callAsFunctionCalled == false)
  }

  @Test
  func callAsFunction_unacceptedCredential_doesNotRefreshCredential() async {
    var credential = refreshableCredential(freshCredentialCount: 1, batchSize: 10)
    credential.progressionState = .unaccepted

    await useCase([credential])

    #expect(await refreshCredentialUseCase.callAsFunctionCalled == false)
  }

  @Test
  func callAsFunction_refreshFails_doesNotThrow() async {
    let credential = refreshableCredential(freshCredentialCount: 2, batchSize: 10)
    await refreshCredentialUseCase.setCallAsFunctionThrowableError(TestingError.error)

    await useCase([credential])

    #expect(await refreshCredentialUseCase.callAsFunctionCallsCount == 1)
    #expect(analyticsProvider.logCounter == 1)
  }

  @Test
  func callAsFunction_refreshesCredentialsInParallelWithLimit() async {
    let refreshConcurrencyTracker = RefreshConcurrencyTracker()
    await refreshCredentialUseCase.setCallAsFunctionClosure { credential in
      try await refreshConcurrencyTracker.refresh(credential)
    }
    let credentials = (0..<4).map { _ in
      refreshableCredential(freshCredentialCount: 2, batchSize: 10)
    }

    await useCase(credentials)

    let maxActiveRefreshCount = await refreshConcurrencyTracker.maxActiveRefreshCount
    #expect(maxActiveRefreshCount > 1)
    #expect(maxActiveRefreshCount <= Self.maxConcurrentRefreshes)
    #expect(await refreshCredentialUseCase.callAsFunctionCallsCount == 4)
  }

  // MARK: Private

  private static let maxConcurrentRefreshes = 2

  private let useCase: RefreshVerifiableCredentialsUseCase
  private let refreshCredentialUseCase: ThreadSafeRefreshVerifiableCredentialUseCaseSpy
  private let getCredentialRefreshThresholdUseCase: GetCredentialRefreshThresholdUseCaseProtocolSpy
  private let analyticsProvider: MockProvider

  private func refreshableCredential(freshCredentialCount: Int, batchSize: Int) -> VerifiableCredential {
    let presentedCount = batchSize - freshCredentialCount
    let bundleItems = (0..<batchSize).map { index in
      BundleItem(
        payload: Data("payload-\(index)".utf8),
        presented: index < presentedCount)
    }

    var credential = VerifiableCredential.Mock.sample
    credential.progressionState = .accepted
    credential.bundleItems = bundleItems
    credential.nextPresentableBundleItemId = bundleItems[min(presentedCount, batchSize - 1)].id
    credential.batchData = BatchData(batchSize: batchSize)
    credential.authentication = CredentialAuthentication(
      accessToken: "access-token",
      refreshToken: "refresh-token")
    return credential
  }
}

// MARK: - ThreadSafeRefreshVerifiableCredentialUseCaseSpy

private actor ThreadSafeRefreshVerifiableCredentialUseCaseSpy: RefreshVerifiableCredentialUseCaseProtocol {

  // MARK: Lifecycle

  init(returnValue: VerifiableCredential) {
    callAsFunctionReturnValue = returnValue
  }

  // MARK: Internal

  var callAsFunctionCallsCount: Int {
    callAsFunctionReceivedInvocations.count
  }

  var callAsFunctionCalled: Bool {
    callAsFunctionCallsCount > 0
  }

  var callAsFunctionReceivedCredential: VerifiableCredential? {
    callAsFunctionReceivedInvocations.last
  }

  func setCallAsFunctionThrowableError(_ error: Error?) {
    callAsFunctionThrowableError = error
  }

  func setCallAsFunctionClosure(_ closure: @escaping (VerifiableCredential) async throws -> VerifiableCredential) {
    callAsFunctionClosure = closure
  }

  func callAsFunction(_ credential: VerifiableCredential) async throws -> VerifiableCredential {
    callAsFunctionReceivedInvocations.append(credential)

    if let callAsFunctionThrowableError {
      throw callAsFunctionThrowableError
    }

    if let callAsFunctionClosure {
      return try await callAsFunctionClosure(credential)
    }

    return callAsFunctionReturnValue
  }

  // MARK: Private

  private var callAsFunctionReceivedInvocations = [VerifiableCredential]()
  private let callAsFunctionReturnValue: VerifiableCredential
  private var callAsFunctionThrowableError: Error?
  private var callAsFunctionClosure: ((VerifiableCredential) async throws -> VerifiableCredential)?

}

// MARK: - RefreshConcurrencyTracker

private actor RefreshConcurrencyTracker {

  // MARK: Internal

  private(set) var maxActiveRefreshCount = 0

  func refresh(_ credential: VerifiableCredential) async throws -> VerifiableCredential {
    activeRefreshCount += 1
    maxActiveRefreshCount = max(maxActiveRefreshCount, activeRefreshCount)
    try await Task.sleep(nanoseconds: 50_000_000)
    activeRefreshCount -= 1
    return credential
  }

  // MARK: Private

  private var activeRefreshCount = 0

}
