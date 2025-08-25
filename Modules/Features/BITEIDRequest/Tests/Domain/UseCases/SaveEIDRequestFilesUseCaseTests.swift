import Factory
import Foundation
import XCTest
@testable import BITEIDRequest

final class SaveEIDRequestFilesUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    repository = EIDRequestCaseRepositoryProtocolSpy()
    Container.shared.eIDRequestCaseRepository.register { self.repository }
    useCase = SaveEIDRequestFilesUseCase()
  }

  @MainActor
  func testHappyPath() async throws {
    let files = EIDRequestCaseFile.Mock.sampleArray
    let caseId = UUID().uuidString

    try await useCase.execute(files, forRequestCaseId: caseId)

    XCTAssertEqual(repository.saveFilesForRequestCaseIdCallsCount, 1)
    XCTAssertEqual(repository.saveFilesForRequestCaseIdReceivedArguments?.files, files)
    XCTAssertEqual(repository.saveFilesForRequestCaseIdReceivedArguments?.id, caseId)
  }

  // MARK: Private

  // swiftlint:disable all
  private var repository: EIDRequestCaseRepositoryProtocolSpy!
  private var useCase: SaveEIDRequestFilesUseCase!
  // swiftlint:enable all

}
