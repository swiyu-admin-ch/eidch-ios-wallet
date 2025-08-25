import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAppInfo

class GetBuildNumberUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    repository = AppVersionRepositoryProtocolSpy()

    Container.shared.appVersionRepository.register { self.repository }
    useCase = GetBuildNumberUseCase()
  }

  func test_init() {
    XCTAssertFalse(repository.getBuildNumberCalled)
    XCTAssertFalse(repository.getVersionCalled)
  }

  func test_getBuildNumber_happyPath() throws {
    let expectedNumber = BuildNumber.Mock.sample
    repository.getBuildNumberReturnValue = expectedNumber

    let number = try useCase.execute()

    XCTAssertEqual(expectedNumber, number)
    XCTAssertTrue(repository.getBuildNumberCalled)
    XCTAssertEqual(1, repository.getBuildNumberCallsCount)
  }

  func test_getVersion_failurePath() throws {
    repository.getBuildNumberThrowableError = AppVersionError.notFound
    XCTAssertThrowsError(try useCase.execute())
    XCTAssertTrue(repository.getBuildNumberCalled)
  }

  // MARK: Private

  // swiftlint:disable all
  private var repository = AppVersionRepositoryProtocolSpy()
  private var useCase: GetBuildNumberUseCaseProtocol!
  // swiftlint:enable all
}
