// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import RealmSwift
import XCTest
@testable import BITActivity
@testable import BITEntities

final class ActivityDetailFactoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    factory = ActivityDetailFactory()
    createSuccessState()
  }

  func testCallAsFunction_success_returnsActivity() throws {
    let actorDisplay = try ActivityActorDisplayEntity.Mock.create(locale: localeMock, createParent: false)
    let reasonDisplay = try NonComplianceReasonDisplayEntity.Mock.create(locale: localeMock, createParent: false)
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

    XCTAssertEqual(result.id, idMock)
    XCTAssertEqual(result.type, .presentationAccepted)
    XCTAssertEqual(result.createdAt, createdAtMock)
    XCTAssertEqual(result.actorDisplay, actorDisplayMock)
    XCTAssertEqual(result.actorTrust, .trusted)
    XCTAssertEqual(result.vcSchemaTrust, .trusted)
    XCTAssertEqual(result.actorCompliance, .compliant)
    XCTAssertEqual(result.nonComplianceReasonDisplay, reasonDisplayMock)
    XCTAssertEqual(result.credential, credentialMock)
  }

  func testCallAsFunction_success_passesArguments() throws {
    let claimId1 = UUID()
    let claim1 = try ActivityClaimEntity.Mock.create(claimId: claimId1, createParent: false)
    let claimId2 = UUID()
    let claim2 = try ActivityClaimEntity.Mock.create(claimId: claimId2, createParent: false)
    let actorDisplay = try ActivityActorDisplayEntity.Mock.create(locale: localeMock, createParent: false)
    let reasonDisplay = try NonComplianceReasonDisplayEntity.Mock.create(locale: localeMock, createParent: false)
    let activity = try CredentialActivityEntity.Mock.create(actorDisplays: [actorDisplay], nonComplianceReasonDisplays: [reasonDisplay], claims: [claim1, claim2], createParent: false)
    let credential = try CredentialEntity.Mock.create(activities: [activity])

    _ = try factory(activity)

    XCTAssertEqual(actorDisplayFactorySpy.callAsFunctionReceivedEntity?.locale, actorDisplay.locale)
    XCTAssertEqual(reasonDisplayFactorySpy.callAsFunctionReceivedEntity?.locale, reasonDisplay.locale)
    XCTAssertEqual(credentialFactorySpy.callAsFunctionClaimIdsReceivedArguments?.entity, credential)
    XCTAssertEqual(credentialFactorySpy.callAsFunctionClaimIdsReceivedArguments?.claimIds, [claimId1, claimId2])
  }

  func testCallAsFunction_noCredential_throwsError() throws {
    let activity = try CredentialActivityEntity.Mock.create(createParent: false)

    XCTAssertThrowsError(try factory(activity)) { error in
      XCTAssertEqual(error as? ActivityDetailFactoryError, .noCredentialFound)
    }
  }

  func testCallAsFunction_wrongEnums_returnsActivityWithDefaults() throws {
    let activity = try CredentialActivityEntity.Mock.create(type: "other", actorTrust: "other", vcSchemaTrust: "other", actorCompliance: "other")

    let result = try factory(activity)

    XCTAssertEqual(result.type, .issuance)
    XCTAssertEqual(result.actorTrust, .unknown)
    XCTAssertEqual(result.vcSchemaTrust, .notProtected)
    XCTAssertEqual(result.actorCompliance, .unknown)
  }

  // MARK: Private

  private let idMock = UUID()
  private let createdAtMock = Date()
  private let localeMock = "locale"
  private let actorDisplayMock = ActivityActorDisplay.Mock.default
  private let reasonDisplayMock = NonComplianceReasonDisplay(locale: nil, value: "value")
  private let credentialMock = ActivityDetailCredential(id: UUID(), displays: [], environment: .swiyu, clusters: [])

  private var actorDisplayFactorySpy: ActivityActorDisplayFactoryProtocolSpy!
  private var reasonDisplayFactorySpy: NonComplianceReasonDisplayFactoryProtocolSpy!
  private var credentialFactorySpy: ActivityDetailCredentialFactoryProtocolSpy!

  private var factory: ActivityDetailFactory!

  private func registerMocks() {
    actorDisplayFactorySpy = ActivityActorDisplayFactoryProtocolSpy()
    reasonDisplayFactorySpy = NonComplianceReasonDisplayFactoryProtocolSpy()
    credentialFactorySpy = ActivityDetailCredentialFactoryProtocolSpy()

    Container.shared.configureInMemoryDataStore()
    Container.shared.preferredUserLanguageCodes.register { [self.localeMock] }
    Container.shared.activityActorDisplayFactory.register { self.actorDisplayFactorySpy }
    Container.shared.nonComplianceReasonDisplayFactory.register { self.reasonDisplayFactorySpy }
    Container.shared.activityDetailCredentialFactory.register { self.credentialFactorySpy }
  }

  private func createSuccessState() {
    actorDisplayFactorySpy.callAsFunctionReturnValue = actorDisplayMock
    reasonDisplayFactorySpy.callAsFunctionReturnValue = reasonDisplayMock
    credentialFactorySpy.callAsFunctionClaimIdsReturnValue = credentialMock
  }
}
