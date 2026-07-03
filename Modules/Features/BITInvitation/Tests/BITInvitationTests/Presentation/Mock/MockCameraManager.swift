@testable import BITQRCode

final class MockCameraManager: CameraManager {
  private(set) var startCallCount = 0
  private(set) var configureCallCount = 0

  override func start() {
    startCallCount += 1
  }

  override func configure() throws {
    configureCallCount += 1
  }
}
