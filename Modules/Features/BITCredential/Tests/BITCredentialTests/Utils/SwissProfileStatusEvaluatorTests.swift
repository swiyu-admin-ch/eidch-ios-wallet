// swiftlint:disable implicitly_unwrapped_optional force_try

import Factory
import Foundation
import Testing
@testable import BITAnyCredentialFormat
@testable import BITAppInfo
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

@Suite
struct SwissProfileStatusEvaluatorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()
    registerMocks()
    swissProfileLifecycleRepository.fetchSwissProfilesReturnValue = [profileMock]
    createAnyCredentialUseCase.executeFromFormatReturnValue = anyCredentialMock
    evaluator = SwissProfileStatusEvaluator()
  }

  // MARK: Internal

  @Test
  func callAsFunction_matchingProfile_returnsProfileStatus() async {
    let result = await evaluator(credentialMock)

    #expect(result == .deprecated)

    #expect(swissProfileLifecycleRepository.fetchSwissProfilesCallsCount == 1)
    #expect(swissProfileLifecycleRepository.fetchSwissProfilesReceivedType == .verifiableCredential)

    #expect(createAnyCredentialUseCase.executeFromFormatCallsCount == 1)
    #expect(createAnyCredentialUseCase.executeFromFormatReceivedArguments?.payload == credentialMock.bundleItems.first?.payload)
    #expect(createAnyCredentialUseCase.executeFromFormatReceivedArguments?.format == credentialMock.format)
  }

  @Test
  func callAsFunction_anyCredential_returnsProfileStatus() async {
    let result = await evaluator(anyCredential: anyCredentialMock)

    #expect(result == .deprecated)

    #expect(swissProfileLifecycleRepository.fetchSwissProfilesCallsCount == 1)
    #expect(swissProfileLifecycleRepository.fetchSwissProfilesReceivedType == .verifiableCredential)

    #expect(!createAnyCredentialUseCase.executeFromFormatCalled)
  }

  @Test
  func callAsFunction_multipleProfiles_returnsCorrectProfileStatus() async {
    let olderProfile = SwissProfile(type: .verifiableCredential, status: .endOfLife, version: "0.1")
    swissProfileLifecycleRepository.fetchSwissProfilesReturnValue = [olderProfile, profileMock]

    let result = await evaluator(credentialMock)

    #expect(result == .deprecated)
  }

  @Test
  func callAsFunction_repositoryReturnsEmptyList_returnsCurrent() async {
    swissProfileLifecycleRepository.fetchSwissProfilesReturnValue = []

    let result = await evaluator(credentialMock)

    #expect(result == .current)
  }

  @Test
  func callAsFunction_repositoryFails_returnsCurrent() async {
    swissProfileLifecycleRepository.fetchSwissProfilesThrowableError = TestingError.error

    let result = await evaluator(credentialMock)

    #expect(result == .current)
  }

  @Test
  func callAsFunction_noVerifiableCredentialProfile_returnsCurrent() async {
    swissProfileLifecycleRepository.fetchSwissProfilesReturnValue = [profileMock.changing(\.type, to: .issuance)]

    let result = await evaluator(credentialMock)

    #expect(result == .current)
  }

  @Test
  func callAsFunction_noBundleItems_returnsNil() async {
    var credential = credentialMock
    credential.bundleItems = []

    let result = await evaluator(credential)

    #expect(result == nil)
  }

  @Test
  func callAsFunction_createAnyCredentialFails_returnsNil() async {
    createAnyCredentialUseCase.executeFromFormatThrowableError = TestingError.error

    let result = await evaluator(credentialMock)

    #expect(result == nil)
  }

  @Test
  func callAsFunction_noMatchingProfileVersion_returnsNil() async {
    createAnyCredentialUseCase.executeFromFormatReturnValue = anyCredentialMock.changing(\.swissProfileVersion, to: "2.0")

    let result = await evaluator(credentialMock)

    #expect(result == nil)
  }

  @Test
  func callAsFunction_noProfileVersion_returnsNil() async {
    createAnyCredentialUseCase.executeFromFormatReturnValue = anyCredentialMock.changing(\.swissProfileVersion, to: nil)

    let result = await evaluator(credentialMock)

    #expect(result == nil)
  }

  @Test
  func callAsFunction_versionWithoutPrefix_returnsNil() async {
    createAnyCredentialUseCase.executeFromFormatReturnValue = anyCredentialMock.changing(\.swissProfileVersion, to: "1.0")

    let result = await evaluator(credentialMock)

    #expect(result == nil)
  }

  @Test
  func callAsFunction_versionWithWrongPrefix_returnsNil() async {
    createAnyCredentialUseCase.executeFromFormatReturnValue = anyCredentialMock.changing(\.swissProfileVersion, to: "swiss-profile-issuance:1.0")

    let result = await evaluator(credentialMock)

    #expect(result == nil)
  }

  // MARK: Private

  private static let versionMock = "1.0"
  private static let rawProfileMock = "\(SwissProfile.ProfileType.verifiableCredential.rawValue):\(versionMock)"

  private let credentialMock = VerifiableCredential.Mock.sample
  private let profileMock = SwissProfile(type: .verifiableCredential, status: .deprecated, version: versionMock)
  private let anyCredentialMock = MockAnyCredential(swissProfileVersion: rawProfileMock)

  private var evaluator: SwissProfileStatusEvaluator!

  private var createAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocolSpy!
  private var swissProfileLifecycleRepository: SwissProfileLifecycleRepositoryProtocolSpy!

  private mutating func registerMocks() {
    let createAnyCredentialUseCase = CreateAnyCredentialUseCaseProtocolSpy()
    let swissProfileLifecycleRepository = SwissProfileLifecycleRepositoryProtocolSpy()

    self.createAnyCredentialUseCase = createAnyCredentialUseCase
    self.swissProfileLifecycleRepository = swissProfileLifecycleRepository

    Container.shared.createAnyCredentialUseCase.register { createAnyCredentialUseCase }
    Container.shared.swissProfileLifecycleRepository.register { swissProfileLifecycleRepository }
  }
}
