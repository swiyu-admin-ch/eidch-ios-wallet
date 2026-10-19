import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITActivity
@testable import BITEntities

// MARK: - ActivityActorDisplayFactoryTests

@MainActor
@Suite(.container)
struct ActivityActorDisplayFactoryTests {

  // MARK: Lifecycle

  init() {
    Container.shared.configureInMemoryDataStore()
    factory = ActivityActorDisplayFactory()
  }

  // MARK: Internal

  @Test
  func callAsFunction_success_returnsDisplay() throws {
    _ = try ImageEntity.Mock.create(contentHash: imageHashMock, image: imageDataMock)
    let entity = try ActivityActorDisplayEntity.Mock.create(name: nameMock, locale: localeMock, imageHash: imageHashMock)

    let display = factory(entity)

    #expect(display.name == nameMock)
    #expect(display.locale == localeMock)
    #expect(display.image == imageDataMock)
  }

  // MARK: Private

  private let nameMock = "issuer"
  private let localeMock = "locale"
  private let imageDataMock = Data("image".utf8)
  private let imageHashMock = "imageHash"

  private let factory: ActivityActorDisplayFactory
}
