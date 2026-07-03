import Factory
import Foundation
import Spyable
import Testing
@testable import BITAppInfo

struct GetBuildNumberUseCaseTests {

  // MARK: Lifecycle

  init() {
    let repository = AppVersionRepositoryProtocolSpy()

    Container.shared.appVersionRepository.register { repository }

    self.repository = repository
    useCase = GetBuildNumberUseCase()
  }

  // MARK: Internal

  @Test
  func initialState() {
    #expect(repository.getBuildNumberCalled == false)
    #expect(repository.getVersionCalled == false)
  }

  @Test
  func getBuildNumber_happyPath() throws {
    let expectedNumber = BuildNumber.Mock.sample
    repository.getBuildNumberReturnValue = expectedNumber

    let number = try useCase()

    #expect(expectedNumber == number)
    #expect(repository.getBuildNumberCalled == true)
    #expect(repository.getBuildNumberCallsCount == 1)
  }

  @Test
  func getVersion_failurePath() {
    repository.getBuildNumberThrowableError = AppVersionError.notFound
    #expect(throws: Error.self, performing: useCase.callAsFunction)
    #expect(repository.getBuildNumberCalled == true)
  }

  // MARK: Private

  private let repository: AppVersionRepositoryProtocolSpy
  private let useCase: GetBuildNumberUseCaseProtocol
}
