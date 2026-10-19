import XCTest
@testable import BITSettings

// swiftlint:disable implicitly_unwrapped_optional

@MainActor
final class LicencesListViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() async throws {
    try await super.setUp()
    fetchPackagesUseCase = FetchPackagesUseCaseProtocolSpy()
    viewModel = LicencesListViewModel(fetchPackagesUseCase: fetchPackagesUseCase)
  }

  func testInitialState() {
    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertNotNil(viewModel.packages)
  }

  func testFetchPackages_withResults() async {
    fetchPackagesUseCase.executeReturnValue = [PackageDependency.Mock.sample]
    await viewModel.send(event: .fetch)

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertEqual(viewModel.packages.count, 1)
    XCTAssertTrue(fetchPackagesUseCase.executeCalled)
    XCTAssertEqual(fetchPackagesUseCase.executeCallsCount, 1)
  }

  func testFetchPackages_withoutResults() async {
    fetchPackagesUseCase.executeReturnValue = []
    await viewModel.send(event: .fetch)

    XCTAssertEqual(viewModel.state, .empty)
    XCTAssertEqual(viewModel.packages.count, 0)
    XCTAssertTrue(fetchPackagesUseCase.executeCalled)
    XCTAssertEqual(fetchPackagesUseCase.executeCallsCount, 1)
  }

  func testFetchPackages_failure() async {
    fetchPackagesUseCase.executeThrowableError = FetchPackagesError.fileNotExisting
    await viewModel.send(event: .fetch)

    XCTAssertEqual(viewModel.state, .error)
    XCTAssertEqual(viewModel.stateError as? FetchPackagesError, FetchPackagesError.fileNotExisting)
    XCTAssertTrue(fetchPackagesUseCase.executeCalled)
    XCTAssertEqual(fetchPackagesUseCase.executeCallsCount, 1)
  }

  // MARK: Private

  private var viewModel: LicencesListViewModel!
  private var fetchPackagesUseCase: FetchPackagesUseCaseProtocolSpy!
}
