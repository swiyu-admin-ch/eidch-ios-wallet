// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import RealmSwift
import XCTest
@testable import BITActivity
@testable import BITEntities

final class ActivityListItemFactoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    factory = ActivityListItemFactory()
    createSuccessState()
  }

  func testCallAsFunction_success_returnsItem() throws {
    let actorDisplay = try ActivityActorDisplayEntity.Mock.create(locale: "locale", createParent: false)
    let entity = try CredentialActivityEntity.Mock.create(id: idMock, type: typeMock.rawValue, createdAt: createdAtMock, actorDisplays: [actorDisplay])

    let item = factory(entity)

    XCTAssertEqual(item.id, idMock)
    XCTAssertEqual(item.type, typeMock)
    XCTAssertEqual(item.createdAt, createdAtMock)
    XCTAssertEqual(item.actorDisplay, actorDisplayMock)

    XCTAssertEqual(actorDisplayFactorySpy.callAsFunctionReceivedEntity?.locale, actorDisplay.locale)
  }

  func testCallAsFunction_unknownType_returnsItemWithDefault() throws {
    let entity = try CredentialActivityEntity.Mock.create(type: "other")

    let item = factory(entity)

    XCTAssertEqual(item.type, .issuance)
  }

  func testCallAsFunction_noActorDisplay_returnsItemWithoutDipslay() throws {
    let entity = try CredentialActivityEntity.Mock.create()

    let item = factory(entity)

    XCTAssertNil(item.actorDisplay)
    XCTAssertFalse(actorDisplayFactorySpy.callAsFunctionCalled)
  }

  // MARK: Private

  private let localeMock = "locale"
  private let idMock = UUID()
  private let typeMock = ActivityType.presentationAccepted
  private let createdAtMock = Date()
  private let actorDisplayMock = ActivityActorDisplay.Mock.default

  private var actorDisplayFactorySpy: ActivityActorDisplayFactoryProtocolSpy!

  private var factory: ActivityListItemFactory!

  private func registerMocks() {
    Container.shared.configureInMemoryDataStore()
    Container.shared.preferredUserLanguageCodes.register { [self.localeMock] }
    actorDisplayFactorySpy = ActivityActorDisplayFactoryProtocolSpy()
    Container.shared.activityActorDisplayFactory.register { self.actorDisplayFactorySpy }
  }

  private func createSuccessState() {
    actorDisplayFactorySpy.callAsFunctionReturnValue = actorDisplayMock
  }
}
