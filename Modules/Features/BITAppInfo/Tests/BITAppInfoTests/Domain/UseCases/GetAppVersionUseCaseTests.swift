import Factory
import Foundation
import Spyable
import Testing
@testable import BITAppInfo

struct GetAppVersionUseCaseTests {

  // MARK: Lifecycle

  init() {
    let repository = AppVersionRepositoryProtocolSpy()

    Container.shared.appVersionRepository.register { repository }

    self.repository = repository
    useCase = GetAppVersionUseCase()
  }

  // MARK: Internal

  @Test
  func initialState() {
    #expect(repository.getVersionCalled == false)
  }

  @Test
  func getVersion_happyPath() throws {
    let expectedVersion = Version.Mock.sample
    repository.getVersionReturnValue = expectedVersion.rawValue

    let version = try useCase()

    #expect(expectedVersion == version)
    #expect(expectedVersion.major == version.major)
    #expect(expectedVersion.minor == version.minor)
    #expect(expectedVersion.patch == version.patch)

    #expect(repository.getVersionCalled == true)
    #expect(repository.getVersionCallsCount == 1)
  }

  @Test
  func getVersion_failurePath() {
    repository.getVersionThrowableError = AppVersionError.notFound
    #expect(throws: Error.self, performing: useCase.callAsFunction)
    #expect(repository.getVersionCalled == true)
  }

  // MARK: Private

  private let repository: AppVersionRepositoryProtocolSpy
  private let useCase: GetAppVersionUseCaseProtocol

}
