// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITActivity
@testable import BITEntities

final class ActivityActorDisplayFactoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    Container.shared.configureInMemoryDataStore()
    factory = ActivityActorDisplayFactory()
  }

  func testCallAsFunction_success_returnsDisplay() throws {
    _ = try ImageEntity.Mock.create(imageHash: imageHashMock, data: imageDataMock)
    let entity = try ActivityActorDisplayEntity.Mock.create(name: nameMock, locale: localeMock, imageHash: imageHashMock)

    let display = factory(entity)

    XCTAssertEqual(display.name, nameMock)
    XCTAssertEqual(display.locale, localeMock)
    XCTAssertEqual(display.image, imageDataMock)
  }

  // MARK: Private

  private let nameMock = "issuer"
  private let localeMock = "locale"
  private let imageDataMock = "image".data(using: .utf8)!
  private let imageHashMock = "imageHash"

  private var factory: ActivityActorDisplayFactory!
}
