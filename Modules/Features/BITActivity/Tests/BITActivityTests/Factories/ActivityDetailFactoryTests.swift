import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITActivity
@testable import BITEntities

// MARK: - ActivityDetailFactoryTests

@MainActor
@Suite(.container)
struct ActivityDetailFactoryTests {

  // MARK: Lifecycle

  init() {
    let actorDisplayFactorySpy = ActivityActorDisplayFactoryProtocolSpy()
    let reasonDisplayFactorySpy = NonComplianceReasonDisplayFactoryProtocolSpy()
    let credentialFactorySpy = ActivityDetailCredentialFactoryProtocolSpy()
    actorDisplayFactorySpy.callAsFunctionReturnValue = Self.actorDisplayMock
    reasonDisplayFactorySpy.callAsFunctionReturnValue = Self.reasonDisplayMock
    credentialFactorySpy.callAsFunctionPathsReturnValue = Self.credentialMock

    let localeMock = Self.localeMock
    Container.shared.configureInMemoryDataStore()
    Container.shared.preferredUserLanguageCodes.register { [localeMock] }
    Container.shared.activityActorDisplayFactory.register { actorDisplayFactorySpy }
    Container.shared.nonComplianceReasonDisplayFactory.register { reasonDisplayFactorySpy }
    Container.shared.activityDetailCredentialFactory.register { credentialFactorySpy }

    self.actorDisplayFactorySpy = actorDisplayFactorySpy
    self.reasonDisplayFactorySpy = reasonDisplayFactorySpy
    self.credentialFactorySpy = credentialFactorySpy
    factory = ActivityDetailFactory()
  }

  // MARK: Internal

  @Test
  func callAsFunction_success_returnsActivity() throws {
    let actorDisplay = try ActivityActorDisplayEntity.Mock.create(locale: Self.localeMock, createParent: false)
    let reasonDisplay = try NonComplianceReasonDisplayEntity.Mock.create(locale: Self.localeMock, createParent: false)
    let activity = try CredentialActivityEntity.Mock.create(
      id: idMock,
      type: ActivityType.presentationAccepted.rawValue,
      createdAt: createdAtMock,
      actorTrust: ActorTrust.trusted.rawValue,
      vcSchemaTrust: VcSchemaTrust.trusted.rawValue,
      actorCompliance: ActorComplianceStatus.compliant.rawValue,
      actorDisplays: [actorDisplay],
      nonComplianceReasonDisplays: [reasonDisplay])

    let result = try factory(activity)

    #expect(result.id == idMock)
    #expect(result.type == .presentationAccepted)
    #expect(result.createdAt == createdAtMock)
    #expect(result.actorDisplay == Self.actorDisplayMock)
    #expect(result.actorTrust == .trusted)
    #expect(result.vcSchemaTrust == .trusted)
    #expect(result.actorCompliance == .compliant)
    #expect(result.nonComplianceReasonDisplay == Self.reasonDisplayMock)
    #expect(result.credential == Self.credentialMock)
  }

  @Test
  func callAsFunction_success_passesArguments() throws {
    let claim1 = try ActivityClaimEntity.Mock.create(path: pathMock1, createParent: false)
    let claim2 = try ActivityClaimEntity.Mock.create(path: pathMock2, createParent: false)
    let actorDisplay = try ActivityActorDisplayEntity.Mock.create(locale: Self.localeMock, createParent: false)
    let reasonDisplay = try NonComplianceReasonDisplayEntity.Mock.create(locale: Self.localeMock, createParent: false)
    let activity = try CredentialActivityEntity.Mock.create(actorDisplays: [actorDisplay], nonComplianceReasonDisplays: [reasonDisplay], claims: [claim1, claim2], createParent: false)

    _ = try factory(activity)

    #expect(actorDisplayFactorySpy.callAsFunctionReceivedEntity?.locale == actorDisplay.locale)
    #expect(reasonDisplayFactorySpy.callAsFunctionReceivedEntity?.locale == reasonDisplay.locale)
    #expect(credentialFactorySpy.callAsFunctionPathsReceivedArguments?.entity == activity)
    #expect(credentialFactorySpy.callAsFunctionPathsReceivedArguments?.paths == [pathMock1, pathMock2])
  }

  @Test
  func callAsFunction_wrongEnums_returnsActivityWithDefaults() throws {
    let activity = try CredentialActivityEntity.Mock.create(type: "other", actorTrust: "other", vcSchemaTrust: "other", actorCompliance: "other")

    let result = try factory(activity)

    #expect(result.type == .issuance)
    #expect(result.actorTrust == .unknown)
    #expect(result.vcSchemaTrust == .notProtected)
    #expect(result.actorCompliance == .unknown)
  }

  // MARK: Private

  private static let localeMock = "locale"
  private static let actorDisplayMock = ActivityActorDisplay.Mock.default
  private static let reasonDisplayMock = NonComplianceReasonDisplay(locale: nil, reason: "reason")
  private static let credentialMock = ActivityDetailCredential(id: UUID(), displays: [], environment: .swiyu, clusters: [])

  private let idMock = UUID()
  private let createdAtMock = Date()
  private let pathMock1 = "[\"firstName\"]"
  private let pathMock2 = "[\"lastName\"]"

  private let actorDisplayFactorySpy: ActivityActorDisplayFactoryProtocolSpy
  private let reasonDisplayFactorySpy: NonComplianceReasonDisplayFactoryProtocolSpy
  private let credentialFactorySpy: ActivityDetailCredentialFactoryProtocolSpy
  private let factory: ActivityDetailFactory
}
