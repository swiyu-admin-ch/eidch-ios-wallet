@testable import BITQRCode

final class MockCameraManager: CameraManager {
  private(set) var startCallCount = 0
  private(set) var startCalled = false
  private(set) var configureCallCount = 0
  private(set) var configureCalled = false

  override func start() {
    startCallCount += 1
    startCalled = true
  }

  override func configure() throws {
    configureCallCount += 1
    configureCalled = true
  }
}
