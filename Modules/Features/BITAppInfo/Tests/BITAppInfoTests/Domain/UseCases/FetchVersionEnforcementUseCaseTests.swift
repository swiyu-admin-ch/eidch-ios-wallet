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
    deviceInfoProvider.modelDescription = Self.iPhone13MiniDescription

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
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = .Mock.make(blacklistedDevice: Self.iPhone13MiniDescription)
    deviceInfoProvider.modelDescription = Self.iPhone13MiniDescription

    let enforcement = try await useCase()

    #expect(enforcement?.type == .blacklistedDevice)
  }

  @Test
  func noEnforcement_whenNotBlacklistedDevice() async throws {
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = .Mock.make(blacklistedDevice: Self.iPhone13MiniDescription)
    deviceInfoProvider.modelDescription = Self.iPhone16ProDescription

    let enforcement = try await useCase()

    #expect(enforcement == nil)
  }

  @Test
  func enforcement_whenForced() async throws {
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = .Mock.make(updateType: .forced, version: Self.appVersion2)
    getAppVersionUseCase.callAsFunctionReturnValue = Self.appVersion1

    let enforcement = try await useCase()

    #expect(enforcement?.type == .forced)
  }

  @Test
  func noEnforcement_whenForced_onMatchingAppVersion() async throws {
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = .Mock.make(updateType: .forced, version: Self.appVersion2)
    getAppVersionUseCase.callAsFunctionReturnValue = Self.appVersion2

    let enforcement = try await useCase()

    #expect(enforcement == nil)
  }

  @Test(arguments: [appVersion1, appVersion2])
  mutating func enforcement_whenOptional_expiredGaranteedSupport_versionGreaterOrEqual(to appVersion: Version) async throws {
    let currentDate = Date()
    let supportGuarantyExpiration = currentDate.addingTimeInterval(-100)
    Container.shared.currentDate.register { currentDate }
    useCase = FetchVersionEnforcementUseCase()
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = .Mock
      .make(supportGuaranteedUntil: supportGuarantyExpiration, updateType: .optional, version: Self.appVersion2)
    getAppVersionUseCase.callAsFunctionReturnValue = appVersion

    let enforcement = try await useCase()

    #expect(enforcement?.type == .optional)
  }

  @Test(arguments: [true, false])
  mutating func noEnforcement_whenOptional(hasSupportGarantyExpired: Bool) async throws {
    let currentDate = Date()
    let supportGuarantyExpiration = currentDate.addingTimeInterval(hasSupportGarantyExpired ? -100 : 100)
    Container.shared.currentDate.register { currentDate }
    useCase = FetchVersionEnforcementUseCase()
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = .Mock
      .make(supportGuaranteedUntil: supportGuarantyExpiration, updateType: .optional, version: Self.appVersion1)
    getAppVersionUseCase.callAsFunctionReturnValue = Self.appVersion2

    let enforcement = try await useCase()

    #expect(enforcement == nil)
  }

  @Test(arguments: [appVersion1, appVersion2])
  func enforcement_whenOptional_noSupportGaranty_lastReleaseSupportExpired_versionGreaterOrEqual(to appVersion: Version) async throws {
    let currentDate = Date()
    let releaseSupportDays = 30
    let releaseDate = try #require(
      Calendar.current.date(byAdding: .day, value: -releaseSupportDays, to: currentDate)?.addingTimeInterval(-100))
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = .Mock
      .make(
        releaseDate: releaseDate,
        defaultReleaseSupportDays: releaseSupportDays,
        supportGuaranteedUntil: nil,
        updateType: .optional,
        version: Self.appVersion2)
    getAppVersionUseCase.callAsFunctionReturnValue = appVersion

    let enforcement = try await useCase()

    #expect(enforcement?.type == .optional)
  }

  @Test(arguments: [true, false])
  func noEnforcement_whenOptional_noSupportGaranty_versionGreaterOrEqual(hasReleaseSupportExpired: Bool) async throws {
    let currentDate = Date()
    let releaseSupportDays = 30
    let releaseDate = try #require(
      Calendar.current.date(byAdding: .day, value: -releaseSupportDays, to: currentDate)?.addingTimeInterval(hasReleaseSupportExpired ? -100 : 100))
    versionEnforcementRepository.fetchVersionEnforcementReturnValue = .Mock
      .make(
        releaseDate: releaseDate,
        defaultReleaseSupportDays: releaseSupportDays,
        supportGuaranteedUntil: nil,
        updateType: .optional,
        version: Self.appVersion1)
    getAppVersionUseCase.callAsFunctionReturnValue = Self.appVersion2

    let enforcement = try await useCase()

    #expect(enforcement == nil)
  }

  // MARK: Private

  private static let iOS15 = Version("15.0.0")
  private static let iOS16 = Version("16.0.0")
  private static let iOS17 = Version("17.0.0")
  private static let iPhone13MiniDescription = "iPhone 13 mini"
  private static let iPhone16ProDescription = "iPhone 16 Pro"
  private static let appVersion1 = Version("1.0.0")
  private static let appVersion2 = Version("2.0.0")

  private var useCase: FetchVersionEnforcementUseCase
  private let versionEnforcementRepository: VersionEnforcementRepositoryProtocolSpy
  private let getAppVersionUseCase: GetAppVersionUseCaseProtocolSpy
  private let deviceInfoProvider: DeviceInfoProviderProtocolSpy
}
