import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAppInfo

class GetAppVersionUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    repository = AppVersionRepositoryProtocolSpy()
    Container.shared.appVersionRepository.register { self.repository }

    useCase = GetAppVersionUseCase()
  }

  func test_init() {
    XCTAssertFalse(repository.getVersionCalled)
  }

  func test_getVersion_happyPath() throws {
    let expectedVersion = AppVersion.Mock.sample
    repository.getVersionReturnValue = expectedVersion.rawValue

    let version = try useCase.execute()

    XCTAssertEqual(expectedVersion, version)
    XCTAssertEqual(expectedVersion.major, version.major)
    XCTAssertEqual(expectedVersion.minor, version.minor)
    XCTAssertEqual(expectedVersion.patch, version.patch)

    XCTAssertTrue(repository.getVersionCalled)
    XCTAssertEqual(repository.getVersionCallsCount, 1)
  }

  func test_getVersion_failurePath() throws {
    repository.getVersionThrowableError = AppVersionError.notFound
    XCTAssertThrowsError(try useCase.execute())
    XCTAssertTrue(repository.getVersionCalled)
  }

  // MARK: Private

  // swiftlint:disable all
  private var repository = AppVersionRepositoryProtocolSpy()
  private var useCase: GetAppVersionUseCaseProtocol!
  // swiftlint:enable all

}
