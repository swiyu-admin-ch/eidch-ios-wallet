// swiftlint:disable implicitly_unwrapped_optional

import Factory
import Foundation
import Spyable
import Testing
@testable import BITAnalytics
@testable import BITAnyCredentialFormat
@testable import BITAppInfo
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITJWT
@testable import BITSdJWT
@testable import BITTestingCore

// MARK: - RefreshVerifiableCredentialsUseCaseTests

@Suite
struct RefreshVerifiableCredentialsUseCaseTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()
    registerMocks()
    createSuccessState()
    useCase = RefreshVerifiableCredentialsUseCase()
  }

  // MARK: Internal

  struct RefreshIntervalTestCase {
    let status: SwissProfile.Status?
    let days: Double
  }

  @Test
  func callAsFunction_freshCredentialCountAtThreshold_refreshesCredential() async {
    let credential = Self.refreshableCredential(freshCredentialCount: 2, batchSize: 10)

    await useCase([credential])

    #expect(refreshCredentialUseCase.callAsFunctionCallsCount == 1)
    #expect(refreshCredentialUseCase.callAsFunctionReceivedCredential == credential)
    #expect(getCredentialRefreshThresholdUseCase.callAsFunctionForReceivedBatchSize == 10)
  }

  @Test
  func callAsFunction_singleCredential_doesNotRefreshCredential() async {
    let credential = Self.refreshableCredential(freshCredentialCount: 1, batchSize: 1)

    await useCase([credential])

    #expect(await refreshCredentialUseCase.callAsFunctionCalled == false)
  }

  @Test
  func callAsFunction_singleUsedCredential_doesNotRefreshCredential() async {
    let credential = Self.refreshableCredential(freshCredentialCount: 0, batchSize: 1)

    await useCase([credential])

    #expect(await refreshCredentialUseCase.callAsFunctionCalled == false)
  }

  @Test
  func callAsFunction_freshCredentialCountAboveThreshold_doesNotRefreshCredential() async {
    let credential = Self.refreshableCredential(freshCredentialCount: 3, batchSize: 10)

    await useCase([credential])

    #expect(await refreshCredentialUseCase.callAsFunctionCalled == false)
  }

  @Test
  func callAsFunction_lastAttemptIsNil_refreshesCredential() async {
    swissProfileStatusEvaluator.callAsFunctionReturnValue = .deprecated
    let credential = Self.refreshableCredential(lastAttempt: nil)

    await useCase([credential])

    #expect(refreshCredentialUseCase.callAsFunctionCalled)
  }

  @Test(arguments: refreshIntervalTestCases)
  func callAsFunction_justInsideRefreshInterval_doesNotRefreshCredential(testCase: RefreshIntervalTestCase) async {
    swissProfileStatusEvaluator.callAsFunctionReturnValue = testCase.status
    let lastAttempt = Self.testDate.addingTimeInterval(-.days(testCase.days) + 1)
    let credential = Self.refreshableCredential(lastAttempt: lastAttempt)

    await useCase([credential])

    #expect(!refreshCredentialUseCase.callAsFunctionCalled)
  }

  @Test(arguments: refreshIntervalTestCases)
  func callAsFunction_atRefreshInterval_refreshesCredential(testCase: RefreshIntervalTestCase) async {
    swissProfileStatusEvaluator.callAsFunctionReturnValue = testCase.status
    let lastAttempt = Self.testDate.addingTimeInterval(-.days(testCase.days))
    var credential = Self.refreshableCredential(lastAttempt: lastAttempt)
    credential.validUntil = Self.testDate

    await useCase([credential])

    #expect(refreshCredentialUseCase.callAsFunctionCalled)
  }

  @Test(arguments: refreshIntervalTestCases)
  func callAsFunction_justAfterRefreshInterval_refreshesCredential(testCase: RefreshIntervalTestCase) async {
    swissProfileStatusEvaluator.callAsFunctionReturnValue = testCase.status
    let lastAttempt = Self.testDate.addingTimeInterval(-.days(testCase.days) - 1)
    var credential = Self.refreshableCredential(lastAttempt: lastAttempt)
    credential.validUntil = Self.testDate

    await useCase([credential])

    #expect(refreshCredentialUseCase.callAsFunctionCalled)
  }

  @Test
  func callAsFunction_batchThresholdReachedAndInsideRefreshInterval_refreshesCredential() async {
    let lastAttempt = Self.testDate.addingTimeInterval(-1)
    let credential = Self.refreshableCredential(freshCredentialCount: 2, batchSize: 10, lastAttempt: lastAttempt)

    await useCase([credential])

    #expect(refreshCredentialUseCase.callAsFunctionCalled)
  }

  @Test(arguments: SwissProfile.Status.allCases.filter { $0 != .current })
  func callAsFunction_notCurrentProfile_refreshesCredential(status: SwissProfile.Status) async {
    swissProfileStatusEvaluator.callAsFunctionReturnValue = status
    let credential = Self.refreshableCredential()

    await useCase([credential])

    #expect(refreshCredentialUseCase.callAsFunctionCalled)
  }

  @Test
  func callAsFunction_expired_refreshesCredential() async {
    var credential = credentialMock
    credential.validUntil = Self.testDate

    await useCase([credential])

    #expect(refreshCredentialUseCase.callAsFunctionCalled)
  }

  @Test
  func callAsFunction_willExpire_refreshesCredential() async {
    var credential = credentialMock
    credential.validUntil = Self.testDate.addingTimeInterval(Self.expiryRange)

    await useCase([credential])

    #expect(refreshCredentialUseCase.callAsFunctionCalled)
  }

  @Test
  func callAsFunction_justNotExpired_doesNotRefreshCredential() async {
    var credential = credentialMock
    credential.validUntil = Self.testDate.addingTimeInterval(Self.expiryRange + 1)

    await useCase([credential])

    #expect(!refreshCredentialUseCase.callAsFunctionCalled)
  }

  @Test
  func callAsFunction_noExpiry_doesNotRefreshCredential() async {
    var credential = credentialMock
    credential.validUntil = nil

    await useCase([credential])

    #expect(!refreshCredentialUseCase.callAsFunctionCalled)
  }

  @Test
  func callAsFunction_refreshFails_doesNotThrow() async {
    refreshCredentialUseCase.callAsFunctionThrowableError = TestingError.error

    await useCase([credentialRefreshMock])

    #expect(analyticsProvider.logCounter == 1)
  }

  @Test
  func callAsFunction_refreshMultipleCredentialsMixedSuccessAndFailure_completesAndLogsError() async {
    let checkpoint = TestCheckpoint()

    let credential1 = credentialRefreshMock
    let credential2 = Self.refreshableCredential(freshCredentialCount: 2, batchSize: 10)
    let credential3 = Self.refreshableCredential(freshCredentialCount: 2, batchSize: 10)
    let credentials = [credential1, credential2, credential3]

    Container.shared.refreshCredentialUseCase.register { RefreshCredentialUseCaseMock(checkpoint: checkpoint, failingId: credential2.id) }
    let useCase = RefreshVerifiableCredentialsUseCase()

    let task = Task {
      await useCase(credentials)
    }

    await checkpoint.waitUntilPausedTasks(count: 3)
    await checkpoint.resumeAll()
    await task.value
    #expect(analyticsProvider.logCounter == 1)
  }

  // MARK: Private

  private static let expiryRange: TimeInterval = 60 * 60
  private static let testDate = Date(timeIntervalSince1970: 1_700_000_000)
  private static let refreshIntervalTestCases: [RefreshIntervalTestCase] = [
    RefreshIntervalTestCase(status: .current, days: 7),
    RefreshIntervalTestCase(status: .deprecated, days: 5),
    RefreshIntervalTestCase(status: .sunset, days: 2),
    RefreshIntervalTestCase(status: .endOfLife, days: 1),
    RefreshIntervalTestCase(status: nil, days: 1),
  ]

  private let credentialMock = refreshableCredential(freshCredentialCount: 1, batchSize: 1)
  private let credentialRefreshMock = refreshableCredential(freshCredentialCount: 2, batchSize: 10)

  private var useCase: RefreshVerifiableCredentialsUseCase!
  private var refreshCredentialUseCase: RefreshVerifiableCredentialUseCaseProtocolSpy!
  private var getCredentialRefreshThresholdUseCase: GetCredentialRefreshThresholdUseCaseProtocolSpy!
  private var swissProfileStatusEvaluator: SwissProfileStatusEvaluatorProtocolSpy!
  private var analyticsProvider: MockProvider!

  private static func createVcSdJwt(profileVersion: String?) -> VcSdJWS {
    let payload = VcSdJwt(vct: "vct")
    let jws = JWS(payload: payload, rawPayload: "rawPayload", rawJWS: "rawJWS", header: JWSHeader(algorithm: .ES256, profileVersion: profileVersion))
    return VcSdJWS(jws: jws, payload: payload, resolvedJSON: [:], rawSdJWS: "rawSdJWS", disclosures: [], rawKeyBinding: nil, keyIdentifierDid: "keyIdentifierDid")
  }

  private static func refreshableCredential(id: UUID = UUID(), freshCredentialCount: Int = 1, batchSize: Int = 1, lastAttempt: Date? = nil) -> VerifiableCredential {
    let presentedCount = batchSize - freshCredentialCount
    let bundleItems = (0..<batchSize).map { index in
      BundleItem(
        payload: Data("payload-\(index)".utf8),
        presented: index < presentedCount)
    }

    var credential = VerifiableCredential.Mock.sample
    credential.id = id
    credential.progressionState = .accepted
    credential.lastRefreshAttemptAt = lastAttempt
    credential.bundleItems = bundleItems
    credential.nextPresentableBundleItemId = bundleItems[min(presentedCount, batchSize - 1)].id
    credential.batchData = BatchData(batchSize: batchSize)
    credential.authentication = CredentialAuthentication(
      accessToken: "access-token",
      refreshToken: "refresh-token")
    return credential
  }

  private mutating func registerMocks() {
    let refreshCredentialUseCase = RefreshVerifiableCredentialUseCaseProtocolSpy()
    let getCredentialRefreshThresholdUseCase = GetCredentialRefreshThresholdUseCaseProtocolSpy()
    let swissProfileStatusEvaluator = SwissProfileStatusEvaluatorProtocolSpy()
    let analyticsProvider = MockProvider()
    let analytics = AnalyticsSpy()
    analytics.register(analyticsProvider)

    self.refreshCredentialUseCase = refreshCredentialUseCase
    self.getCredentialRefreshThresholdUseCase = getCredentialRefreshThresholdUseCase
    self.analyticsProvider = analyticsProvider
    self.swissProfileStatusEvaluator = swissProfileStatusEvaluator

    Container.shared.analytics.register { analytics }
    Container.shared.refreshCredentialUseCase.register { refreshCredentialUseCase }
    Container.shared.getCredentialRefreshThresholdUseCase.register { getCredentialRefreshThresholdUseCase }
    Container.shared.swissProfileStatusEvaluator.register { swissProfileStatusEvaluator }
    Container.shared.credentialExpiryRefreshRange.register { Self.expiryRange }
    Container.shared.currentDate.register { Self.testDate }
  }

  private func createSuccessState() {
    refreshCredentialUseCase.callAsFunctionReturnValue = VerifiableCredential.Mock.sample
    getCredentialRefreshThresholdUseCase.callAsFunctionForReturnValue = 2
    swissProfileStatusEvaluator.callAsFunctionReturnValue = .current
  }
}

// MARK: - RefreshCredentialUseCaseMock

actor RefreshCredentialUseCaseMock: RefreshVerifiableCredentialUseCaseProtocol {
  let checkpoint: TestCheckpoint
  let failingId: UUID

  init(checkpoint: TestCheckpoint, failingId: UUID) {
    self.checkpoint = checkpoint
    self.failingId = failingId
  }

  func callAsFunction(_ credential: VerifiableCredential) async throws -> VerifiableCredential {
    await checkpoint.pause()
    if credential.id == failingId {
      throw TestingError.error
    }
    return credential
  }
}
