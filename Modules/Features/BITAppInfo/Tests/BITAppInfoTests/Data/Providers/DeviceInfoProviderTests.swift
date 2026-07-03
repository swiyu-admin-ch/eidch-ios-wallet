import DeviceKit
import Testing
@testable import BITAppInfo

struct DeviceInfoProviderTests {

  // MARK: Lifecycle

  init() {
    provider = DeviceInfoProvider()
  }

  // MARK: Internal

  @Test
  func testSystemVersion() throws {
    let expectedVersion = try Version(#require(Device.current.systemVersion))

    #expect(provider.systemVersion == expectedVersion)
  }

  @Test
  func testModelDescription() {
    #expect(provider.modelDescription == Device.current.description)
  }

  // MARK: Private

  private let provider: DeviceInfoProviderProtocol
}
