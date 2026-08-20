import Factory
import Foundation
import Testing
@testable import BITAppInfo

struct FetchVersionEnforcementUseCaseTests {

  // MARK: Lifecycle

  init() {
    let versionEnforcementRepository = VersionEnforcementRepositoryProtocolSpy()
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = .Mock.make()

    let getAppVersionUseCase = GetAppVersionUseCaseProtocolSpy()
    getAppVersionUseCase.callAsFunctionReturnValue = Self.appVersion2

    let deviceInfoProvider = DeviceInfoProviderProtocolSpy()
    deviceInfoProvider.systemVersion = Self.iOS16
    deviceInfoProvider.modelDescription = device1Description

    Container.shared.currentDate.register { Date() }
    Container.shared.versionEnforcementRepository.register { versionEnforcementRepository }
    Container.shared.getAppVersionUseCase.register { getAppVersionUseCase }
    Container.shared.deviceInfoProvider.register { deviceInfoProvider }

    useCase = FetchVersionEnforcementUseCase()
    self.versionEnforcementRepository = versionEnforcementRepository
    self.getAppVersionUseCase = getAppVersionUseCase
    self.deviceInfoProvider = deviceInfoProvider
  }

  // MARK: Internal

  @Test
  func enforcement_whenOutdatedOS() async throws {
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = .Mock.make(minimumOsVersion: Self.iOS16.rawValue)
    deviceInfoProvider.systemVersion = Self.iOS15

    let enforcement = try await useCase()

    #expect(enforcement?.type == .outdatedOsVersion)
  }

  @Test(arguments: [iOS16, iOS17])
  func noEnforcement_whenUpToDateOS(osVersion: Version) async throws {
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = .Mock.make(minimumOsVersion: Self.iOS16.rawValue)
    deviceInfoProvider.systemVersion = osVersion

    let enforcement = try await useCase()

    #expect(enforcement == nil)
  }

  @Test
  func enforcement_whenBlacklistedDevice() async throws {
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = .Mock.make(blacklistedDevice: device1Description)
    deviceInfoProvider.modelDescription = device1Description

    let enforcement = try await useCase()

    #expect(enforcement?.type == .blacklistedDevice)
  }

  @Test
  func noEnforcement_whenNotBlacklistedDevice() async throws {
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = .Mock.make(blacklistedDevice: device1Description)
    deviceInfoProvider.modelDescription = device2Description

    let enforcement = try await useCase()

    #expect(enforcement == nil)
  }

  @Test
  func forcedEnforcement() async throws {
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = .Mock.forced(version: Self.appVersion2)
    getAppVersionUseCase.callAsFunctionReturnValue = Self.appVersion1

    let enforcement = try await useCase()

    #expect(enforcement?.type == .forced)
  }

  @Test
  func noForcedEnforcement_whenOnMatchingAppVersion() async throws {
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = .Mock.forced(version: Self.appVersion2)
    getAppVersionUseCase.callAsFunctionReturnValue = Self.appVersion2

    let enforcement = try await useCase()

    #expect(enforcement == nil)
  }

  @Test(arguments: [
    appVersion1,
    appVersion2,
  ], [
    VersionEnforcement.Response.Mock.optionalSupport(expired: false, version: appVersion2),
    VersionEnforcement.Response.Mock.optionalLifetime(expired: false, version: appVersion2),
  ])
  func optionalEnforcement_whenOptionalVersionIsValid(appVersion: Version, response: VersionEnforcement.Response) async throws {
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = response
    getAppVersionUseCase.callAsFunctionReturnValue = appVersion

    let enforcement = try await useCase()

    #expect(enforcement?.type == .optional)
  }

  @Test(arguments: [
    appVersion1,
    appVersion2,
  ], [
    VersionEnforcement.Response.Mock.optionalSupport(expired: true, version: appVersion2),
    VersionEnforcement.Response.Mock.optionalLifetime(expired: true, version: appVersion2),
  ])
  func forcedEnforcement_whenOptionalVersionExpired(appVersion: Version, response: VersionEnforcement.Response) async throws {
    getAppVersionUseCase.callAsFunctionReturnValue = appVersion
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = response

    let enforcement = try await useCase()

    #expect(enforcement?.type == .forced)
  }

  @Test(arguments: [
    VersionEnforcement.Response.Mock.optionalSupport(expired: true, version: appVersion1),
    VersionEnforcement.Response.Mock.optionalSupport(expired: false, version: appVersion1),
    VersionEnforcement.Response.Mock.optionalLifetime(expired: true, version: appVersion1),
    VersionEnforcement.Response.Mock.optionalLifetime(expired: false, version: appVersion1),
  ])
  func noEnforcement_whenGreaterAppVersionThanOptionalVersion(response: VersionEnforcement.Response) async throws {
    getAppVersionUseCase.callAsFunctionReturnValue = Self.appVersion2
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = response

    let enforcement = try await useCase()

    #expect(enforcement == nil)
  }

  // MARK: Private

  private static let iOS15 = Version("15.0.0")
  private static let iOS16 = Version("16.0.0")
  private static let iOS17 = Version("17.0.0")
  private static let appVersion1 = Version("1.0.0")
  private static let appVersion2 = Version("2.0.0")

  private let device1Description = "Device 1"
  private let device2Description = "Device 2"

  private let useCase: FetchVersionEnforcementUseCase

  private let versionEnforcementRepository: VersionEnforcementRepositoryProtocolSpy
  private let getAppVersionUseCase: GetAppVersionUseCaseProtocolSpy
  private let deviceInfoProvider: DeviceInfoProviderProtocolSpy
}
