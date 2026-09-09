// swiftlint:disable implicitly_unwrapped_optional

import Factory
import Foundation
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

@Suite(.serialized)
struct RefreshVerifiableCredentialsUseCaseTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()
    registerMocks()
    createSuccessState()
    useCase = RefreshVerifiableCredentialsUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_freshCredentialCountAtThreshold_refreshesCredential() async {
    let credential = Self.refreshableCredential(freshCredentialCount: 2, batchSize: 10)

    await useCase([credential])

    #expect(await refreshCredentialUseCase.callAsFunctionCallsCount == 1)
    #expect(await refreshCredentialUseCase.callAsFunctionReceivedCredential == credential)
    #expect(getCredentialRefreshThresholdUseCase.callAsFunctionForReceivedBatchSize == 10)
  }

  @Test(arguments: [SwissProfile.Status.deprecated, .sunset, .endOfLife])
  func callAsFunction_profileIsNotCurrent_refreshesCredential(status: SwissProfile.Status) async {
    swissProfileLifecycleRepository.fetchSwissProfilesReturnValue = [SwissProfile(type: .verifiableCredential, status: status, version: versionMock)]

    await useCase([credentialMock])

    #expect(await refreshCredentialUseCase.callAsFunctionCallsCount == 1)
    #expect(await refreshCredentialUseCase.callAsFunctionReceivedCredential == credentialMock)
    #expect(getCredentialRefreshThresholdUseCase.callAsFunctionForReceivedBatchSize == 1)
  }

  @Test
  func callAsFunction_createAnyCredentialFails_refreshesCredential() async {
    createAnyCredentialUseCase.executeFromFormatThrowableError = TestingError.error

    await useCase([credentialMock])

    #expect(await refreshCredentialUseCase.callAsFunctionCallsCount == 1)
  }

  @Test
  func callAsFunction_noSwissProfileVersion_refreshesCredential() async {
    createAnyCredentialUseCase.executeFromFormatReturnValue = Self.createVcSdJwt(profileVersion: nil)

    await useCase([credentialMock])

    #expect(await refreshCredentialUseCase.callAsFunctionCallsCount == 1)
  }

  @Test
  func callAsFunction_wrongSwissProfileVersion_refreshesCredential() async {
    createAnyCredentialUseCase.executeFromFormatReturnValue = Self.createVcSdJwt(profileVersion: "swiss-profile-issuance:1.0.0")

    await useCase([credentialMock])

    #expect(await refreshCredentialUseCase.callAsFunctionCallsCount == 1)
  }

  @Test
  func callAsFunction_expired_refreshesCredential() async {
    var credential = credentialMock
    credential.validUntil = Self.testDate

    await useCase([credential])

    #expect(await refreshCredentialUseCase.callAsFunctionCallsCount == 1)
  }

  @Test
  func callAsFunction_willExpire_refreshesCredential() async {
    var credential = credentialMock
    credential.validUntil = Self.testDate.addingTimeInterval(Self.expiryRange)

    await useCase([credential])

    #expect(await refreshCredentialUseCase.callAsFunctionCallsCount == 1)
  }

  @Test
  func callAsFunction_justNotExpired_refreshesCredential() async {
    var credential = credentialMock
    credential.validUntil = Self.testDate.addingTimeInterval(Self.expiryRange + 1)

    await useCase([credential])

    #expect(await refreshCredentialUseCase.callAsFunctionCalled == false)
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
  func callAsFunction_withoutRefreshToken_doesNotRefreshCredential() async {
    var credential = credentialRefreshMock
    credential.authentication = CredentialAuthentication(accessToken: "access-token")

    await useCase([credential])

    #expect(await refreshCredentialUseCase.callAsFunctionCalled == false)
  }

  @Test
  func callAsFunction_unacceptedCredential_doesNotRefreshCredential() async {
    var credential = credentialRefreshMock
    credential.progressionState = .unaccepted

    await useCase([credential])

    #expect(await refreshCredentialUseCase.callAsFunctionCalled == false)
  }

  @Test
  func callAsFunction_swissProfileFetchFails_doesNotRefresh() async {
    swissProfileLifecycleRepository.fetchSwissProfilesThrowableError = TestingError.error

    await useCase([credentialMock])

    #expect(await refreshCredentialUseCase.callAsFunctionCalled == false)
  }

  @Test
  func callAsFunction_swissProfileFetchWithoutVcProfile_doesNotRefresh() async {
    swissProfileLifecycleRepository.fetchSwissProfilesReturnValue = [SwissProfile(type: .issuance, status: .deprecated, version: "1.0.0")]

    await useCase([credentialMock])

    #expect(await refreshCredentialUseCase.callAsFunctionCalled == false)
  }

  @Test
  func callAsFunction_refreshFails_doesNotThrow() async {
    await refreshCredentialUseCase.setCallAsFunctionThrowableError(TestingError.error)

    await useCase([credentialRefreshMock])

    #expect(await refreshCredentialUseCase.callAsFunctionCallsCount == 1)
    #expect(analyticsProvider.logCounter == 1)
  }

  @Test
  func callAsFunction_refreshesCredentialsInParallelWithLimit() async {
    let tracker = ConcurrencyTracker()
    await refreshCredentialUseCase.setCallAsFunctionClosure { credential in
      await tracker.track { credential }
    }
    let credentials = (0..<4).map { _ in
      credentialRefreshMock
    }

    let task = Task {
      await useCase(credentials)
    }

    await tracker.waitUntilPausedTasks(count: 2)
    let maxActive = await tracker.maxActiveTaskCount
    #expect(maxActive == Self.maxConcurrentRefreshes)
    await tracker.resumeAll()

    await tracker.waitUntilPausedTasks(count: 2)
    await tracker.resumeAll()
    await task.value

    let callsCount = await refreshCredentialUseCase.callAsFunctionCallsCount
    #expect(callsCount == 4)
  }

  // MARK: Private

  private static let maxConcurrentRefreshes = 2
  private static let expiryRange: TimeInterval = 60 * 60
  private static let testDate = Date()

  private let versionMock = "1.0.0"
  private let credentialMock = refreshableCredential(freshCredentialCount: 1, batchSize: 1)
  private let credentialRefreshMock = refreshableCredential(freshCredentialCount: 2, batchSize: 10)

  private var useCase: RefreshVerifiableCredentialsUseCase!
  private var refreshCredentialUseCase: ThreadSafeRefreshVerifiableCredentialUseCaseSpy!
  private var getCredentialRefreshThresholdUseCase: GetCredentialRefreshThresholdUseCaseProtocolSpy!
  private var swissProfileLifecycleRepository: SwissProfileLifecycleRepositoryProtocolSpy!
  private var createAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocolSpy!
  private var analyticsProvider: MockProvider!

  private static func createVcSdJwt(profileVersion: String?) -> VcSdJWS {
    let payload = VcSdJwt(vct: "vct")
    let jws = JWS(payload: payload, rawPayload: "rawPayload", rawJWS: "rawJWS", header: JWSHeader(algorithm: .ES256, profileVersion: profileVersion))
    return VcSdJWS(jws: jws, payload: payload, resolvedJSON: [:], rawSdJWS: "rawSdJWS", disclosures: [], rawKeyBinding: nil, keyIdentifierDid: "keyIdentifierDid")
  }

  private static func refreshableCredential(freshCredentialCount: Int, batchSize: Int) -> VerifiableCredential {
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

  private mutating func registerMocks() {
    let refreshCredentialUseCase = ThreadSafeRefreshVerifiableCredentialUseCaseSpy(returnValue: VerifiableCredential.Mock.diploma)
    let getCredentialRefreshThresholdUseCase = GetCredentialRefreshThresholdUseCaseProtocolSpy()
    let swissProfileLifecycleRepository = SwissProfileLifecycleRepositoryProtocolSpy()
    let createAnyCredentialUseCase = CreateAnyCredentialUseCaseProtocolSpy()
    let analyticsProvider = MockProvider()
    let analytics = AnalyticsSpy()
    analytics.register(analyticsProvider)

    self.refreshCredentialUseCase = refreshCredentialUseCase
    self.getCredentialRefreshThresholdUseCase = getCredentialRefreshThresholdUseCase
    self.analyticsProvider = analyticsProvider
    self.swissProfileLifecycleRepository = swissProfileLifecycleRepository
    self.createAnyCredentialUseCase = createAnyCredentialUseCase

    Container.shared.analytics.register { analytics }
    Container.shared.refreshCredentialUseCase.register { refreshCredentialUseCase }
    Container.shared.getCredentialRefreshThresholdUseCase.register { getCredentialRefreshThresholdUseCase }
    Container.shared.swissProfileLifecycleRepository.register { swissProfileLifecycleRepository }
    Container.shared.createAnyCredentialUseCase.register { createAnyCredentialUseCase }
    Container.shared.maxConcurrentVerifiableCredentialRefreshes.register { Self.maxConcurrentRefreshes }
    Container.shared.credentialExpiryRefreshRange.register { Self.expiryRange }
    Container.shared.currentDate.register { Self.testDate }
  }

  private func createSuccessState() {
    getCredentialRefreshThresholdUseCase.callAsFunctionForReturnValue = 2
    swissProfileLifecycleRepository.fetchSwissProfilesReturnValue = [SwissProfile(type: .verifiableCredential, status: .current, version: versionMock)]
    createAnyCredentialUseCase.executeFromFormatReturnValue = Self.createVcSdJwt(profileVersion: "swiss-profile-vc:\(versionMock)")
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
